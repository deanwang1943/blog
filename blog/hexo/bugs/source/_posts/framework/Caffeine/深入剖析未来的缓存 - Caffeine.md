---
title: 深入剖析未来的缓存 - Caffeine
date: 2018-09-05 13:36:03
tags: [缓存,Caffeine]
categories: [缓存]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5b8df63c6fb9a019e04ebaf4?utm_source=gold_browser_extension

# 1\. 前言

读这篇文章之前希望你能好好的阅读: [你应该知道的缓存进化史](https://link.juejin.im?target=https%3A%2F%2Fjuejin.im%2Fpost%2F5b7593496fb9a009b62904fa) 和 [如何优雅的设计和使用缓存？](https://link.juejin.im?target=https%3A%2F%2Fjuejin.im%2Fpost%2F5b849878e51d4538c77a974a) 。这两篇文章主要从一些实战上面去介绍如何去使用缓存。在这两篇文章中我都比较推荐 Caffeine 这款本地缓存去代替你的 Guava Cache。本篇文章我将介绍 Caffeine 缓存的具体有哪些功能，以及内部的实现原理，让大家知其然，也要知其所以然。有人会问: 我不使用 Caffeine 这篇文章应该对我没啥用了，别着急，在 Caffeine 中的知识一定会对你在其他代码设计方面有很大的帮助。当然在介绍之前还是要贴一下他和其他缓存的一些比较图:

![](https://user-gold-cdn.xitu.io/2018/8/16/165406d9fff73da6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 可以看见 Caffeine 基本从各个维度都是相比于其他缓存都高，废话不多说，首先还是先看看如何使用吧。

## 1.1 如何使用

Caffeine 使用比较简单，API 和 Guava Cache 一致:

```
public static void main(String[] args) {
        Cache<String, String> cache = Caffeine.newBuilder()
                .expireAfterWrite(1, TimeUnit.SECONDS)
                .expireAfterAccess(1,TimeUnit.SECONDS)
                .maximumSize(10)
                .build();
        cache.put("hello","hello");
    }
 
```

# 2.Caffeine 原理简介

## 2.1W-TinyLFU

传统的 LFU 受时间周期的影响比较大。所以各种 LFU 的变种出现了，基于时间周期进行衰减，或者在最近某个时间段内的频率。同样的 LFU 也会使用额外空间记录每一个数据访问的频率，即使数据没有在缓存中也需要记录，所以需要维护的额外空间很大。

> 可以试想我们对这个维护空间建立一个 hashMap，每个数据项都会存在这个 hashMap 中，当数据量特别大的时候，这个 hashMap 也会特别大。

再回到 LRU，我们的 LRU 也不是那么一无是处，LRU 可以很好的应对突发流量的情况，因为他不需要累计数据频率。

所以 W-TinyLFU 结合了 LRU 和 LFU，以及其他的算法的一些特点。

### 2.1.1 频率记录

首先要说到的就是频率记录的问题，我们要实现的目标是利用有限的空间可以记录随时间变化的访问频率。在 W-TinyLFU 中使用 Count-Min Sketch 记录我们的访问频率，而这个也是布隆过滤器的一种变种。如下图所示:

![](https://user-gold-cdn.xitu.io/2018/8/16/1654122a489af624?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 如果需要记录一个值，那我们需要通过多种 Hash 算法对其进行处理 hash，然后在对应的 hash 算法的记录中 + 1，为什么需要多种 hash 算法呢？由于这是一个压缩算法必定会出现冲突，比如我们建立一个 Long 的数组，通过计算出每个数据的 hash 的位置。比如张三和李四，他们两有可能 hash 值都是相同，比如都是 1 那 Long[1] 这个位置就会增加相应的频率，张三访问 1 万次，李四访问 1 次那 Long[1] 这个位置就是 1 万零 1，如果取李四的访问评率的时候就会取出是 1 万零 1，但是李四命名只访问了 1 次啊，为了解决这个问题，所以用了多个 hash 算法可以理解为 long[][] 二维数组的一个概念，比如在第一个算法张三和李四冲突了，但是在第二个，第三个中很大的概率不冲突，比如一个算法大概有 1% 的概率冲突，那四个算法一起冲突的概率是 1% 的四次方。通过这个模式我们取李四的访问率的时候取所有算法中，李四访问最低频率的次数。所以他的名字叫 Count-Min Sketch。![](https://user-gold-cdn.xitu.io/2018/8/16/165415223707be02?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)![](https://user-gold-cdn.xitu.io/2018/8/16/165416fb2e8353cd?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这里和以前的做个对比，简单的举个例子: 如果一个 hashMap 来记录这个频率，如果我有 100 个数据，那这个 HashMap 就得存储 100 个这个数据的访问频率。哪怕我这个缓存的容量是 1，因为 Lfu 的规则我必须全部记录这个 100 个数据的访问频率。如果有更多的数据我就有记录更多的。

在 Count-Min Sketch 中，我这里直接说 caffeine 中的实现吧 (在 FrequencySketch 这个类中), 如果你的缓存大小是 100，他会生成一个 long 数组大小是和 100 最接近的 2 的幂的数，也就是 128。而这个数组将会记录我们的访问频率。在 caffeine 中规定频率最大为 15，15 的二进制位 1111，总共是 4 位，而 Long 型是 64 位。所以每个 Long 型可以放 16 种算法，但是 caffeine 并没有这么做，只用了四种 hash 算法，每个 Long 型被分为四段，每段里面保存的是四个算法的频率。这样做的好处是可以进一步减少 Hash 冲突，原先 128 大小的 hash，就变成了 128X4。

一个 Long 的结构如下:

![](https://user-gold-cdn.xitu.io/2018/8/16/16541c306627e1c6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 我们的 4 个段分为 A,B,C,D，在后面我也会这么叫它们。而每个段里面的四个算法我叫他 s1,s2,s3,s4。下面举个例子如果要添加一个访问 50 的数字频率应该怎么做？我们这里用 size=100 来举例。

1.  首先确定 50 这个 hash 是在哪个段里面，通过 hash & 3(3 的二进制是 11) 必定能获得小于 4 的数字，假设 hash & 3=0，那就在 A 段。
2.  对 50 的 hash 再用其他 hash 算法再做一次 hash，得到 long 数组的位置，也就是在长度 128 数组中的位置。假设用 s1 算法得到 1，s2 算法得到 3，s3 算法得到 4，s4 算法得到 0。
3.  因为 S1 算法得到的是 1，所以在 long[1] 的 A 段里面的 s1 位置进行 + 1, 简称 1As1 加 1，然后在 3As2 加 1，在 4As3 加 1，在 0As4 加 1。

![](https://user-gold-cdn.xitu.io/2018/8/16/16541d6338fcffdd?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这个时候有人会质疑频率最大为 15 的这个是否太小？没关系在这个算法中，比如 size 等于 100，如果他全局提升了 size*10 也就是 1000 次就会全局除以 2 衰减，衰减之后也可以继续增加，这个算法再 W-TinyLFU 的论文中证明了其可以较好的适应时间段的访问频率。

## 2.2 读写性能

在 guava cache 中我们说过其读写操作中夹杂着过期时间的处理，也就是你在一次 Put 操作中有可能还会做淘汰操作，所以其读写性能会受到一定影响，可以看上面的图中，caffeine 的确在读写操作上面完爆 guava cache。主要是因为在 caffeine，对这些事件的操作是通过异步操作，他将事件提交至队列，这里的队列的数据结构是 RingBuffer, 不清楚的可以看看这篇文章, [你应该知道的高性能无锁队列 Disruptor](https://link.juejin.im?target=https%3A%2F%2Fjuejin.im%2Fpost%2F5b5f10d65188251ad06b78e3)。然后会通过默认的 ForkJoinPool.commonPool()，或者自己配置线程池，进行取队列操作，然后在进行后续的淘汰，过期操作。

当然读写也是有不同的队列，在 caffeine 中认为缓存读比写多很多，所以对于写操作是所有线程共享一个 Ringbuffer。

![](https://user-gold-cdn.xitu.io/2018/8/16/16541f8f02eaff92?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

对于读操作比写操作更加频繁，进一步减少竞争，其为每个线程配备了一个 RingBuffer：

![](https://user-gold-cdn.xitu.io/2018/8/16/16541fbd7f949b50?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## 2.3 数据淘汰策略

在 caffeine 所有的数据都在 ConcurrentHashMap 中，这个和 guava cache 不同，guava cache 是自己实现了个类似 ConcurrentHashMap 的结构。在 caffeine 中有三个记录引用的 **LRU** 队列:

*   Eden 队列: 在 caffeine 中规定只能为缓存容量的 %1, 如果 size=100, 那这个队列的有效大小就等于 1。这个队列中记录的是新到的数据，防止突发流量由于之前没有访问频率，而导致被淘汰。比如有一部新剧上线，在最开始其实是没有访问频率的，防止上线之后被其他缓存淘汰出去，而加入这个区域。伊甸区，最舒服最安逸的区域，在这里很难被其他数据淘汰。

*   Probation 队列: 叫做缓刑队列，在这个队列就代表你的数据相对比较冷，马上就要被淘汰了。这个有效大小为 size 减去 eden 减去 protected。

*   Protected 队列: 在这个队列中，可以稍微放心一下了，你暂时不会被淘汰，但是别急，如果 Probation 队列没有数据了或者 Protected 数据满了，你也将会被面临淘汰的尴尬局面。当然想要变成这个队列，需要把 Probation 访问一次之后，就会提升为 Protected 队列。这个有效大小为 (size 减去 eden) X 80% 如果 size =100，就会是 79。

这三个队列关系如下:

![](https://user-gold-cdn.xitu.io/2018/8/16/1654222b063487e1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

1.  所有的新数据都会进入 Eden。
2.  Eden 满了，淘汰进入 Probation。
3.  如果在 Probation 中访问了其中某个数据，则这个数据升级为 Protected。
4.  如果 Protected 满了又会继续降级为 Probation。

对于发生数据淘汰的时候，会从 Probation 中进行淘汰。会把这个队列中的数据队头称为受害者，这个队头肯定是最早进入的，按照 LRU 队列的算法的话那他其实他就应该被淘汰，但是在这里只能叫他受害者，这个队列是缓刑队列，代表马上要给他行刑了。这里会取出队尾叫候选者，也叫攻击者。这里受害者会和攻击者皇城 PK 决出我们应该被淘汰的。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a289d47f1422d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 通过我们的 Count-Min Sketch 中的记录的频率数据有以下几个判断:

*   如果攻击者大于受害者，那么受害者就直接被淘汰。
*   如果攻击者 <=5，那么直接淘汰攻击者。这个逻辑在他的注释中有解释: ![](https://user-gold-cdn.xitu.io/2018/8/16/165422c9450da3ba?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 他认为设置一个预热的门槛会让整体命中率更高。
*   其他情况，随机淘汰。

# 3.Caffeine 功能剖析

在 Caffeine 中功能比较多，下面来剖析一下，这些 API 到底是如何生效的呢？

## 3.1 百花齐放 - Cache 工厂

在 Caffeine 中有个 LocalCacheFactory 类，他会根据你的配置进行具体 Cache 的创建。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a2afa76f05f30?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 可以看见他会根据你是否配置了过期时间, remove 监听器等参数，来进行字符串的拼装，最后会根据字符串来生成具体的 Cache，这里的 Cache 太多了，作者的源码并没有直接写这部分代码，而是通过 Java Poet 进行代码的生成:![](https://user-gold-cdn.xitu.io/2018/9/4/165a2b1bb4c75380?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## 3.2 转瞬即逝 - 过期策略

在 Caffeine 中分为两种缓存，一个是有界缓存，一个是无界缓存，无界缓存不需要过期并且没有界限。在有界缓存中提供了三个过期 API:

*   expireAfterWrite：代表着写了之后多久过期。
*   expireAfterAccess: 代表着最后一次访问了之后多久过期。
*   expireAfter: 在 expireAfter 中需要自己实现 Expiry 接口，这个接口支持 create,update, 以及 access 了之后多久过期。注意这个 API 和前面两个 API 是互斥的。这里和前面两个 API 不同的是，需要你告诉缓存框架，他应该在具体的某个时间过期，也就是通过前面的重写 create,update, 以及 access 的方法，获取具体的过期时间。

在 Caffeine 中有个 scheduleDrainBuffers 方法, 用来进行我们的过期任务的调度，在我们读写之后都会对其进行调用:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a2fcae3fd2337?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

首先他会进行加锁，如果锁失败说明有人已经在执行调度了。他会使用默认的线程池 ForkJoinPool 或者自定义线程池, 这里的 drainBuffersTask 其实是 Caffeine 中 PerformCleanupTask。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a2ffee3182095?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)![](https://user-gold-cdn.xitu.io/2018/9/4/165a303ca9066413?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 在 performCleanUp 方法中再次进行加锁，防止其他线程进行清理操作。然后我们进入到 maintenance 方法中:![](https://user-gold-cdn.xitu.io/2018/9/4/165a3075a461ed38?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

可以看见里面有挺多方法的，其他方法稍后再讨论，这里我们重点关注 expireEntries(), 也就是用来过期的方法:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a3098f3a9d468?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

*   首先获取当前时间。
*   第二步, 进行 expireAfterAccess 的过期:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a30c50ade6e02?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)![](https://user-gold-cdn.xitu.io/2018/9/4/165a30fc352ccb3b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 这里根据我们的配置 evicts() 方法为 true，所以会从三个队列都进行过期淘汰，上面已经说过了这三个队列都是 LRU 队列，所以我们的 expireAfterAccessEntries 方法，只需要把各个队列的头结点进行判断是否访问过期然后进行剔除即可。

*   第三步, 是 expireAfterWrite:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a3140de479251?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 可以看见这里依赖了一个队列 writeQrderDeque, 这个队列的数据是什么时候填充的呢？当然也是使用异步，具体方法在我们上面的 draninWriteBuffer 中，他会将我们之前放进 RingBuffer 的 Task 拿出来执行，其中也包括添加 writeQrderDeque。过期的策略很简单，直接循环弹出第一个判断其是否过期即可。

*   第四步，进行 expireVariableEntries 过期:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a34187b508ce5?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 在上面的方法中我们可以看见，是利用时间轮，来进行过期处理的，时间轮是什么呢？想必熟悉一些定时任务系统对其并不陌生，他是一个高效的处理定时任务的结构，可以简单的将其看做是一个多维数组。在 Caffeine 中是一个二层时间轮，也就是二维数组，其一维的数据表示较大的时间维度比如，秒，分，时，天等，其二维的数据表示该时间维度较小的时间维度，比如秒内的某个区间段。当定位到一个 TimeWhile[i][j] 之后，其数据结构其实是一个链表，记录着我们的 Node。在 Caffeine 利用时间轮记录我们在某个时间过期的数据，然后去处理。![](https://user-gold-cdn.xitu.io/2018/9/4/165a3759c71914de?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

在 Caffeine 中的时间轮如上面所示。在我们插入数据的时候，根据我们重写的方法计算出他应该过期的时间，比如他应该在 1536046571142 时间过期，上一次处理过期时间是 1536046571100，对其相减则得到 42ms，然后将其放入时间轮，由于其小于 1.07s，所以直接放入 1.07s 的位置，以及第二层的某个位置 (需要经过一定的算法算出)，使用尾插法插入链表。

处理过期时间的时候会算出上一次处理的时间和当前处理的时间的差值，需要将其这个时间范围之内的所有时间轮的时间都进行处理，如果某个 Node 其实没有过期，那么就需要将其重新插入进时间轮。

## 3.3\. 除旧布新 - 更新策略

Caffeine 提供了 refreshAfterWrite() 方法来让我们进行写后多久更新策略:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a38e2e06fe3e0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

上面的代码我们需要建立一个 CacheLodaer 来进行刷新, 这里是同步进行的，可以通过 buildAsync 方法进行异步构建。在实际业务中这里可以把我们代码中的 mapper 传入进去，进行数据源的刷新。

> 注意这里的刷新并不是到期就刷新，而是对这个数据再次访问之后，才会刷新。举个例子: 有个 key:'咖啡',value:'拿铁' 的数据，我们设置 1s 刷新，我们在添加数据之后，等待 1 分钟，按理说下次访问时他会刷新，获取新的值，可惜并没有，访问的时候还是返回'拿铁'。但是继续访问的话就会发现，他已经进行了刷新了。

我们来看看自动刷新他是怎么做的呢？自动刷新只存在读操作之后，也就是我们 afterRead() 这个方法，其中有个方法叫 refreshIfNeeded，他会根据你是同步还是异步然后进行刷新处理。

## 3.4 虚虚实实 - 软引用和弱引用

在 Java 中有四种引用类型: 强引用（StrongReference）、软引用（SoftReference）、弱引用（WeakReference）、虚引用（PhantomReference）。

*   强引用: 在我们代码中直接声明一个对象就是强引用。
*   软引用: 如果一个对象只具有软引用，如果内存空间足够，垃圾回收器就不会回收它；如果内存空间不足了，就会回收这些对象的内存。只要垃圾回收器没有回收它，该对象就可以被程序使用。软引用可以和一个引用队列（ReferenceQueue）联合使用，如果软引用所引用的对象被垃圾回收器回收，Java 虚拟机就会把这个软引用加入到与之关联的引用队列中。
*   弱引用: 在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存。弱引用可以和一个引用队列（ReferenceQueue）联合使用，如果弱引用所引用的对象被垃圾回收，Java 虚拟机就会把这个弱引用加入到与之关联的引用队列中。
*   虚引用: 如果一个对象仅持有虚引用，那么它就和没有任何引用一样，在任何时候都可能被垃圾回收器回收。虚引用必须和引用队列 （ReferenceQueue）联合使用。当垃圾回收器准备回收一个对象时，如果发现它还有虚引用，就会在回收对象的内存之前，把这个虚引用加入到与之 关联的引用队列中。

### 3.4.1 弱引用的淘汰策略

在 Caffeine 中支持弱引用的淘汰策略，其中有两个 api: weakKeys() 和 weakValues(), 用来设置 key 是弱引用还是 value 是弱引用。具体原理是在 put 的时候将 key 和 value 用虚引用进行包装并绑定至引用队列:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a3c9464740424?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)。

具体回收的时候，在我们前面介绍的 maintenance 方法中，有两个方法:

```
//处理key引用的
drainKeyReferences();
//处理value引用
drainValueReferences();
 
```

具体的处理的代码有:

![](https://user-gold-cdn.xitu.io/2018/9/4/165a3cd0c2623dff?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

因为我们的 key 已经被回收了，然后他会进入引用队列，通过这个引用队列，一直弹出到他为空为止。我们能根据这个队列中的运用获取到 Node, 然后对其进行驱逐。

> 注意: 很多同学以为在缓存中内部是存储的 Key-Value 的形式，其实存储的是 KeyReference - Node(Node 中包含 Value) 的形式。

### 3.4.2 软引用的淘汰策略

在 Caffeine 中还支持软引用的淘汰策略, 其 api 是 softValues(), 软引用只支持 Value 不支持 Key。我们可以看见在 Value 的回收策略中有：

![](https://user-gold-cdn.xitu.io/2018/9/4/165a3ec20b9f460a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) 和 key 引用回收相似，但是要说明的是这里的引用队列，有可能是软引用队列，也有可能是弱引用队列。

## 3.5 知己知彼 - 打点监控

在 Caffeine 中提供了一些的打点监控策略，通过 recordStats()Api 进行开启，默认是使用 Caffeine 自带的，也可以自己进行实现。 在 StatsCounter 接口中，定义了需要打点的方法目前来说有如下几个:

*   recordHits：记录缓存命中
*   recordMisses：记录缓存未命中
*   recordLoadSuccess：记录加载成功 (指的是 CacheLoader 加载成功)
*   recordLoadFailure：记录加载失败
*   recordEviction：记录淘汰数据

通过上面的监听，我们可以实时监控缓存当前的状态，以评估缓存的健康程度以及缓存命中率等，方便后续调整参数。

## 3.6 有始有终 - 淘汰监听

有很多时候我们需要知道 Caffeine 中的缓存为什么被淘汰了呢，从而进行一些优化？这个时候我们就需要一个监听器, 代码如下所示:

```
Cache<String, String> cache = Caffeine.newBuilder()
                .removalListener(((key, value, cause) -> {
                    System.out.println(cause);
                }))
                .build();
 
```

在 Caffeine 中被淘汰的原因有很多种:

*   EXPLICIT: 这个原因是，用户造成的，通过调用 remove 方法从而进行删除。
*   REPLACED: 更新的时候，其实相当于把老的 value 给删了。
*   COLLECTED: 用于我们的垃圾收集器，也就是我们上面减少的软引用，弱引用。
*   EXPIRED： 过期淘汰。
*   SIZE: 大小淘汰，当超过最大的时候就会进行淘汰。

当我们进行淘汰的时候就会进行回调，我们可以打印出日志，对数据淘汰进行实时监控。

# 4\. 最后

本文介绍了 Caffeine 的全部功能原理，其中的知识点涉及到: LFU,LRU, 时间轮，Java 的四种引用等等。如果你对 Caffeine 不感兴趣也没有关系，通过这些知识的介绍相信你也收获了不少。最后关于缓存系列基本也告一段落，如果还想了解更多可以关注我的公众号，加我好友或者加入技术交流微信群进行讨论。
