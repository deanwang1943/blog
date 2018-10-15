---
title: 基于 redis 的分布式锁
date: 2018-10-11 16:36:03
tags: [redis]
categories: [redis]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 http://ifeve.com/redis-lock-2/

# 1 介绍

这篇博文讲介绍如何一步步构建一个基于 Redis 的分布式锁。会从最原始的版本开始，然后根据问题进行调整，最后完成一个较为合理的分布式锁。

本篇文章会将分布式锁的实现分为两部分，一个是单机环境，另一个是集群环境下的 Redis 锁实现。在介绍分布式锁的实现之前，先来了解下分布式锁的一些信息。

# 2 分布式锁

## 2.1 什么是分布式锁？

分布式锁是控制分布式系统或不同系统之间共同访问共享资源的一种锁实现，如果不同的系统或同一个系统的不同主机之间共享了某个资源时，往往需要互斥来防止彼此干扰来保证一致性。

## 2.2 分布式锁需要具备哪些条件

1.  互斥性：在任意一个时刻，只有一个客户端持有锁。
2.  无死锁：即便持有锁的客户端崩溃或者其他意外事件，锁仍然可以被获取。
3.  容错：只要大部分 Redis 节点都活着，客户端就可以获取和释放锁

## 2.4 分布式锁的实现有哪些？

1.  数据库
2.  Memcached（add 命令）
3.  Redis（setnx 命令）
4.  Zookeeper（临时节点）
5.  等等

# 3 单机 Redis 的分布式锁

## 3.1 准备工作

### 3.1.1 定义常量类

```
public class LockConstants {
    public static final String OK = "OK";

    /** NX|XX, NX -- Only set the key if it does not already exist. XX -- Only set the key if it already exist. **/
    public static final String NOT_EXIST = "NX";
    public static final String EXIST = "XX";

    /** expx EX|PX, expire time units: EX = seconds; PX = milliseconds **/
    public static final String SECONDS = "EX";
    public static final String MILLISECONDS = "PX";

    private LockConstants() {}
}
复制代码
```

### 3.1.2 定义锁的抽象类

抽象类 RedisLock 实现 java.util.concurrent 包下的 Lock 接口，然后对一些方法提供默认实现，子类只需实现 lock 方法和 unlock 方法即可。代码如下

```
public abstract class RedisLock implements Lock {

    protected Jedis jedis;
    protected String lockKey;

    public RedisLock(Jedis jedis,String lockKey) {
        this(jedis, lockKey);
    }

    public void sleepBySencond(int sencond){
        try {
            Thread.sleep(sencond*1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void lockInterruptibly(){}

    @Override
    public Condition newCondition() {
        return null;
    }

    @Override
    public boolean tryLock() {
        return false;
    }

    @Override
    public boolean tryLock(long time, TimeUnit unit){
        return false;
    }

}
复制代码
```

## 3.2 最基础的版本 1

先来一个最基础的版本，代码如下

```
public class LockCase1 extends RedisLock {

    public LockCase1(Jedis jedis, String name) {
        super(jedis, name);
    }

    @Override
    public void lock() {
        while(true){
            String result = jedis.set(lockKey, "value", NOT_EXIST);
            if(OK.equals(result)){
                System.out.println(Thread.currentThread().getId()+"加锁成功!");
                break;
            }
        }
    }

    @Override
    public void unlock() {
        jedis.del(lockKey);
    }
}
复制代码
```

LockCase1 类提供了 lock 和 unlock 方法。
其中 lock 方法也就是在 reids 客户端执行如下命令

```
SET lockKey value NX
复制代码
```

而 unlock 方法就是调用 DEL 命令将键删除。
好了，方法介绍完了。现在来想想这其中会有什么问题？
假设有两个客户端 A 和 B，A 获取到分布式的锁。A 执行了一会，突然 A 所在的服务器断电了（或者其他什么的），也就是客户端 A 挂了。这时出现一个问题，这个锁一直存在，且不会被释放，其他客户端永远获取不到锁。如下示意图

![](https://user-gold-cdn.xitu.io/2018/8/15/1653b1ac513a9c62?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

可以通过设置过期时间来解决这个问题

## 3.3 版本 2 - 设置锁的过期时间

```
public void lock() {
    while(true){
        String result = jedis.set(lockKey, "value", NOT_EXIST,SECONDS,30);
        if(OK.equals(result)){
            System.out.println(Thread.currentThread().getId()+"加锁成功!");
            break;
        }
    }
}
复制代码
```

类似的 Redis 命令如下

```
SET lockKey value NX EX 30
复制代码
```

> 注：要保证设置过期时间和设置锁具有原子性

这时又出现一个问题，问题出现的步骤如下

1.  客户端 A 获取锁成功，过期时间 30 秒。
2.  客户端 A 在某个操作上阻塞了 50 秒。
3.  30 秒时间到了，锁自动释放了。
4.  客户端 B 获取到了对应同一个资源的锁。
5.  客户端 A 从阻塞中恢复过来，释放掉了客户端 B 持有的锁。

示意图如下

![](https://user-gold-cdn.xitu.io/2018/8/15/1653b1ac5129b682?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这时会有两个问题

1.  过期时间如何保证大于业务执行时间?
2.  如何保证锁不会被误删除?

先来解决如何保证锁不会被误删除这个问题。
这个问题可以通过设置 value 为当前客户端生成的一个随机字符串，且保证在足够长的一段时间内在所有客户端的所有获取锁的请求中都是唯一的。

版本 2 的完整代码：[Github 地址](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Frainbowda%2FlearnWay%2Fblob%2Fmaster%2FlearnRedis%2Fdistributed-locks%2Fsrc%2Fmain%2Fjava%2Fcom%2FlearnRedis%2Flock%2Fcase2%2FLockCase2.java)

## 3.4 版本 3 - 设置锁的 value

抽象类 RedisLock 增加 lockValue 字段，lockValue 字段的默认值为 UUID 随机值假设当前线程 ID。

```
public abstract class RedisLock implements Lock {

    //...
    protected String lockValue;

    public RedisLock(Jedis jedis,String lockKey) {
        this(jedis, lockKey, UUID.randomUUID().toString()+Thread.currentThread().getId());
    }

    public RedisLock(Jedis jedis, String lockKey, String lockValue) {
        this.jedis = jedis;
        this.lockKey = lockKey;
        this.lockValue = lockValue;
    }

    //...
}
复制代码
```

加锁代码

```
public void lock() {
    while(true){
        String result = jedis.set(lockKey, lockValue, NOT_EXIST,SECONDS,30);
        if(OK.equals(result)){
            System.out.println(Thread.currentThread().getId()+"加锁成功!");
            break;
        }
    }
}
复制代码
```

解锁代码

```
public void unlock() {
    String lockValue = jedis.get(lockKey);
    if (lockValue.equals(lockValue)){
        jedis.del(lockKey);
    }
}
复制代码
```

这时看看加锁代码，好像没有什么问题啊。
再来看看解锁的代码，这里的解锁操作包含三步操作：获取值、判断和删除锁。这时你有没有想到在多线程环境下的`i++`操作?

### 3.4.1 i++ 问题

`i++`操作也可分为三个步骤：读 i 的值，进行 i+1，设置 i 的值。
如果两个线程同时对 i 进行 i++ 操作，会出现如下情况

1.  i 设置值为 0
2.  线程 A 读到 i 的值为 0
3.  线程 B 也读到 i 的值为 0
4.  线程 A 执行了 + 1 操作，将结果值 1 写入到内存
5.  线程 B 执行了 + 1 操作，将结果值 1 写入到内存
6.  此时 i 进行了两次 i++ 操作，但是结果却为 1

在多线程环境下有什么方式可以避免这类情况发生?
解决方式有很多种，例如用 AtomicInteger、CAS、synchronized 等等。
这些解决方式的目的都是要确保`i++` 操作的原子性。那么回过头来看看解锁，同理我们也是要确保解锁的原子性。我们可以利用 Redis 的 lua 脚本来实现解锁操作的原子性。

版本 3 的完整代码：[Github 地址](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Frainbowda%2FlearnWay%2Fblob%2Fmaster%2FlearnRedis%2Fdistributed-locks%2Fsrc%2Fmain%2Fjava%2Fcom%2FlearnRedis%2Flock%2Fcase3%2FLockCase3.java)

## 3.5 版本 4 - 具有原子性的释放锁

lua 脚本内容如下

```
if redis.call("get",KEYS[1]) == ARGV[1] then
    return redis.call("del",KEYS[1])
else
    return 0
end
复制代码
```

这段 Lua 脚本在执行的时候要把的 lockValue 作为 ARGV[1] 的值传进去，把 lockKey 作为 KEYS[1] 的值传进去。现在来看看解锁的 java 代码

```
public void unlock() {
    // 使用lua脚本进行原子删除操作
    String checkAndDelScript = "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                                "return redis.call('del', KEYS[1]) " +
                                "else " +
                                "return 0 " +
                                "end";
    jedis.eval(checkAndDelScript, 1, lockKey, lockValue);
}
复制代码
```

好了，解锁操作也确保了原子性了，那么是不是单机 Redis 环境的分布式锁到此就完成了?
别忘了[版本 2 - 设置锁的过期时间](#%E7%89%88%E6%9C%AC2-%E8%AE%BE%E7%BD%AE%E9%94%81%E7%9A%84%E8%BF%87%E6%9C%9F%E6%97%B6%E9%97%B4)还有一个，过期时间如何保证大于业务执行时间问题没有解决。

版本 4 的完整代码：[Github 地址](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Frainbowda%2FlearnWay%2Fblob%2Fmaster%2FlearnRedis%2Fdistributed-locks%2Fsrc%2Fmain%2Fjava%2Fcom%2FlearnRedis%2Flock%2Fcase4%2FLockCase4.java)

## 3.6 版本 5 - 确保过期时间大于业务执行时间

抽象类 RedisLock 增加一个 boolean 类型的属性 isOpenExpirationRenewal，用来标识是否开启定时刷新过期时间。
在增加一个 scheduleExpirationRenewal 方法用于开启刷新过期时间的线程。

```
public abstract class RedisLock implements Lock {
	//...

    protected volatile boolean isOpenExpirationRenewal = true;

    /**
     * 开启定时刷新
     */
    protected void scheduleExpirationRenewal(){
        Thread renewalThread = new Thread(new ExpirationRenewal());
        renewalThread.start();
    }

    /**
     * 刷新key的过期时间
     */
    private class ExpirationRenewal implements Runnable{
        @Override
        public void run() {
            while (isOpenExpirationRenewal){
                System.out.println("执行延迟失效时间中...");

                String checkAndExpireScript = "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                        "return redis.call('expire',KEYS[1],ARGV[2]) " +
                        "else " +
                        "return 0 end";
                jedis.eval(checkAndExpireScript, 1, lockKey, lockValue, "30");

                //休眠10秒
                sleepBySencond(10);
            }
        }
    }
}
复制代码
```

加锁代码在获取锁成功后将 isOpenExpirationRenewal 置为 true，并且调用 scheduleExpirationRenewal 方法，开启刷新过期时间的线程。

```
public void lock() {
    while (true) {
        String result = jedis.set(lockKey, lockValue, NOT_EXIST, SECONDS, 30);
        if (OK.equals(result)) {
            System.out.println("线程id:"+Thread.currentThread().getId() + "加锁成功!时间:"+LocalTime.now());

            //开启定时刷新过期时间
            isOpenExpirationRenewal = true;
            scheduleExpirationRenewal();
            break;
        }
        System.out.println("线程id:"+Thread.currentThread().getId() + "获取锁失败，休眠10秒!时间:"+LocalTime.now());
        //休眠10秒
        sleepBySencond(10);
    }
}
复制代码
```

解锁代码增加一行代码，将 isOpenExpirationRenewal 属性置为 false，停止刷新过期时间的线程轮询。

```
public void unlock() {
    //...
    isOpenExpirationRenewal = false;
}

复制代码
```

版本 5 的完整代码：[Github 地址](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Frainbowda%2FlearnWay%2Fblob%2Fmaster%2FlearnRedis%2Fdistributed-locks%2Fsrc%2Fmain%2Fjava%2Fcom%2FlearnRedis%2Flock%2Fcase5%2FLockCase5.java)

## 3.7 测试

测试代码如下

```
public void testLockCase5() {
    //定义线程池
    ThreadPoolExecutor pool = new ThreadPoolExecutor(0, 10,
                                                    1, TimeUnit.SECONDS,
                                                    new SynchronousQueue<>());

    //添加10个线程获取锁
    for (int i = 0; i < 10; i++) {
        pool.submit(() -> {
            try {
                Jedis jedis = new Jedis("localhost");
                LockCase5 lock = new LockCase5(jedis, lockName);
                lock.lock();

                //模拟业务执行15秒
                lock.sleepBySencond(15);

                lock.unlock();
            } catch (Exception e){
                e.printStackTrace();
            }
        });
    }

    //当线程池中的线程数为0时，退出
    while (pool.getPoolSize() != 0) {}
}
复制代码
```

测试结果

![](https://user-gold-cdn.xitu.io/2018/8/15/1653b1ac51325e07?imageslim)

或许到这里基于单机 Redis 环境的分布式就介绍完了。但是使用 java 的同学有没有发现一个锁的重要特性

![](https://user-gold-cdn.xitu.io/2018/8/15/1653b1ac51e83db0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

那就是锁的重入，那么分布式锁的重入该如何实现呢？这里就留一个坑了

# 4 集群 Redis 的分布式锁

在 Redis 的分布式环境中，Redis 的作者提供了 RedLock 的算法来实现一个分布式锁。

## 4.1 加锁

RedLock 算法加锁步骤如下

1.  获取当前 Unix 时间，以毫秒为单位。
2.  依次尝试从 N 个实例，使用相同的 key 和随机值获取锁。在步骤 2，当向 Redis 设置锁时, 客户端应该设置一个网络连接和响应超时时间，这个超时时间应该小于锁的失效时间。例如你的锁自动失效时间为 10 秒，则超时时间应该在 5-50 毫秒之间。这样可以避免服务器端 Redis 已经挂掉的情况下，客户端还在死死地等待响应结果。如果服务器端没有在规定时间内响应，客户端应该尽快尝试另外一个 Redis 实例。
3.  客户端使用当前时间减去开始获取锁时间（步骤 1 记录的时间）就得到获取锁使用的时间。当且仅当从大多数（这里是 3 个节点）的 Redis 节点都取到锁，并且使用的时间小于锁失效时间时，锁才算获取成功。
4.  如果取到了锁，key 的真正有效时间等于有效时间减去获取锁所使用的时间（步骤 3 计算的结果）。
5.  如果因为某些原因，获取锁失败（_没有_在至少 N/2+1 个 Redis 实例取到锁或者取锁时间已经超过了有效时间），客户端应该在所有的 Redis 实例上进行解锁（即便某些 Redis 实例根本就没有加锁成功）。

## 4.2 解锁

向所有的 Redis 实例发送释放锁命令即可，不用关心之前有没有从 Redis 实例成功获取到锁.

* * *

关于 RedLock 算法，还有一个小插曲，就是 Martin Kleppmann 和 RedLock 作者 antirez 的对 RedLock 算法的互怼。 官网原话如下

> Martin Kleppmann [analyzed Redlock here](https://link.juejin.im?target=http%3A%2F%2Fmartin.kleppmann.com%2F2016%2F02%2F08%2Fhow-to-do-distributed-locking.html). I disagree with the analysis and posted [my reply to his analysis here](https://link.juejin.im?target=http%3A%2F%2Fantirez.com%2Fnews%2F101).

更多关于 RedLock 算法这里就不在说明，有兴趣的可以到官网阅读相关文章。

# 5 总结

这篇文章讲述了一个基于 Redis 的分布式锁的编写过程及解决问题的思路，但是本篇文章实现的分布式锁并不适合用于生产环境。java 环境有 [Redisson](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Fmrniko%2Fredisson) 可用于生产环境，但是分布式锁还是 Zookeeper 会比较好一些（可以看 Martin Kleppmann 和 RedLock 的分析）。

> Martin Kleppmann 对 RedLock 的分析：[martin.kleppmann.com/2016/02/08/…](https://link.juejin.im?target=http%3A%2F%2Fmartin.kleppmann.com%2F2016%2F02%2F08%2Fhow-to-do-distributed-locking.html)
>
> RedLock 作者 antirez 的回应：[antirez.com/news/101](https://link.juejin.im?target=http%3A%2F%2Fantirez.com%2Fnews%2F101)

整个项目的地址存放在 Github 上，有需要的可以看看：[Github 地址](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Frainbowda%2FlearnWay%2Ftree%2Fmaster%2FlearnRedis%2Fdistributed-locks)
