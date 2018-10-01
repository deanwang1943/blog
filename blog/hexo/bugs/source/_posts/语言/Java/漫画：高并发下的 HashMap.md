---
title: 漫画：高并发下的 HashMap
date: 2018-09-29 08:36:03
tags: [java]
categories: [java]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5a224e1551882535c56cb940

​上一期我们介绍了 HashMap 的基本原理，没看过的小伙伴们可以点击下面的链接：

[漫画：什么是 HashMap？](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzIxMjE5MTE1Nw%3D%3D%26mid%3D2653191907%26idx%3D1%26sn%3D876860c5a9a6710ead5dd8de37403ffc%26chksm%3D8c990c39bbee852f71c9dfc587fd70d10b0eab1cca17123c0a68bf1e16d46d71717712b91509%26scene%3D21%23wechat_redirect)

这一期我们来讲解高并发环境下，HashMap 可能出现的致命问题。

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601459579b3d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601458c330f7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/160160145c8fe4b1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/160160145caef8e9?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601459e785b8?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/160160145ac301d4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

HashMap 的容量是有限的。当经过多次元素插入，使得 HashMap 达到一定饱和度时，Key 映射位置发生冲突的几率会逐渐提高。

这时候，HashMap 需要扩展它的长度，也就是进行 **Resize**。

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601485958801?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

影响发生 Resize 的因素有两个：

**1.Capacity**

HashMap 的当前长度。上一期曾经说过，HashMap 的长度是 2 的幂。

**2.LoadFactor**

HashMap 负载因子，默认值为 0.75f。

衡量 HashMap 是否进行 Resize 的条件如下：

**HashMap.Size >= Capacity * L****oadFactor**

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601491c9c257?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601482623964?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**1\. 扩容**

创建一个新的 Entry 空数组，长度是原数组的 2 倍。

**2.ReHash**

遍历原 Entry 数组，把所有的 Entry 重新 Hash 到新数组。为什么要重新 Hash 呢？因为长度扩大以后，Hash 的规则也随之改变。

让我们回顾一下 Hash 公式：

index = HashCode（**Key**） & （**Length** - 1）

当原数组长度为 8 时，Hash 运算是和 111B 做与运算；新数组长度为 16，Hash 运算是和 1111B 做与运算。Hash 结果显然不同。

**Resize 前的 HashMap：**

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601485a7c79b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**Resize 后的 HashMap：**

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014a7a32213?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**ReHash 的 Java 代码如下：**

```
/**
 * Transfers all entries from current table to newTable.
 */
void transfer(Entry[] newTable, boolean rehash) {
    int newCapacity = newTable.length;
    for (Entry<K,V> e : table) {
        while(null != e) {
            Entry<K,V> next = e.next;
            if (rehash) {
                e.hash = null == e.key ? 0 : hash(e.key);
            }
            int i = indexFor(e.hash, newCapacity);
            e.next = newTable[i];
            newTable[i] = e;
            e = next;
        }
    }
}复制代码
```

![](https://user-gold-cdn.xitu.io/2017/12/2/160160148ec57044?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014b98d5cd5?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014bb0049e6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**注意：下面的内容十分烧脑，请小伙伴们坐稳扶好。**

假设一个 HashMap 已经到了 Resize 的临界点。此时有两个线程 A 和 B，在同一时刻对 HashMap 进行 Put 操作：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014ca234818?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014d4add54e?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

此时达到 Resize 条件，两个线程各自进行 Rezie 的第一步，也就是扩容：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014ca3010d9?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这时候，两个线程都走到了 ReHash 的步骤。让我们回顾一下 ReHash 的代码：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014deb9cbf3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

假如此时线程 B 遍历到 Entry3 对象，刚执行完红框里的这行代码，线程就被挂起。对于线程 B 来说：

**e = Entry3**

**next = Entry2**

这时候线程 A 畅通无阻地进行着 Rehash，当 ReHash 完成后，结果如下（图中的 e 和 next，代表线程 B 的两个引用）：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014e3cc413b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

直到这一步，看起来没什么毛病。接下来线程 B 恢复，继续执行属于它自己的 ReHash。线程 B 刚才的状态是：

**e = Entry3**

**next = Entry2**

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014e181e658?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

当执行到上面这一行时，显然 i = 3，因为刚才线程 A 对于 Entry3 的 hash 结果也是 3。

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014f63d6c17?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

我们继续执行到这两行，Entry3 放入了线程 B 的数组下标为 3 的位置，并且 **e 指向了 Entry2**。此时 e 和 next 的指向如下：

**e = Entry2**

**next = Entry2**

整体情况如图所示：

![](https://user-gold-cdn.xitu.io/2017/12/2/160160150c3e5eda?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

接着是新一轮循环，又执行到红框内的代码行：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014deb9cbf3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**e = Entry2**

**next = Entry3**

整体情况如图所示：

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601525e6394c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

接下来执行下面的三行，用头插法把 Entry2 插入到了线程 B 的数组的头结点：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016015190ef7d4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

整体情况如图所示：

![](https://user-gold-cdn.xitu.io/2017/12/2/160160151adc04a8?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

第三次循环开始，又执行到红框的代码：

![](https://user-gold-cdn.xitu.io/2017/12/2/16016014deb9cbf3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**e = Entry3**

**next = Entry3.next = null**

最后一步，当我们执行下面这一行的时候，见证奇迹的时刻来临了：

![](https://user-gold-cdn.xitu.io/2017/12/2/160160152263fe5a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**newTable[i] = **Entry2****

**e = Entry3**

******Entry2.next = Entry3******

**Entry3.next = Entry2**

**链表出现了环形！**

整体情况如图所示：

![](https://user-gold-cdn.xitu.io/2017/12/2/160160154abddd92?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

此时，问题还没有直接产生。当调用 Get 查找一个不存在的 Key，而这个 Key 的 Hash 结果恰好等于 3 的时候，由于位置 3 带有环形链表，所以程序将会进入**死循环**！

这种情况，不禁让人联想到一道经典的面试题：

[漫画算法：如何判断链表有环？](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzIxMjE5MTE1Nw%3D%3D%26mid%3D2653189798%26idx%3D1%26sn%3Dc35c259d0a4a26a2ee6205ad90d0b2e1%26chksm%3D8c99047cbbee8d6a452fbb171133551553a825c83fb8b0cc66210dcda842c61157a07baaeb6b%26scene%3D21%23wechat_redirect)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601529d9d3e1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601533b42a3a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/160160154ba3920b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/1601601560080b74?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/2/160160155397ed77?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**1.Hashmap 在插入元素过多的时候需要进行 Resize，Resize 的条件是**

****HashMap.Size >= Capacity * L****oadFactor。****

****2.**Hashmap 的** Resize 包含扩容和 ReHash 两个步骤，ReHash 在并发的情况下可能会形成链表环。****

—————END—————

喜欢本文的朋友们，欢迎长按下图关注订阅号**程序员小灰**，收看更多精彩内容

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd91630187?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
