---
title: 详细领悟ThreadLocal
date: 2018-09-19 08:36:03
tags: [java]
categories: [java]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/entry/5b9dca7cf265da0a9223a056?utm_source=gold_browser_extension

关于对 ThreadLocal 变量的理解，我今天查看一下午的博客，自己也写了 demo 来测试来看自己的理解到底是不是那么回事。从看到博客引出不解，到仔细查看 ThreadLocal 源码（JDK1.8），我觉得我很有必要记录下来我这大半天的收获，

今天我研究的最多的就是这两篇文章说理解。我在这里暂称为 A 文章和 B 文章。以下是两篇博文地址，我是在看完 A 文章后，很有疑问，特别是在 A 文章后的各位网页的评论中，更加坚定我要弄清楚 ThreadLocal 到底是怎么一回事。

A 文章：http://blog.csdn.net/lufeng20/article/details/24314381B 文章：http://www.cnblogs.com/dolphin0520/p/3920407.html

首先，我们从字面上的意思来理解 ThreadLocal，Thread：线程，这个毫无疑问。那 Local 呢？本地的，局部的。也就是说，ThreadLocal 是线程本地的变量，只要是本线程内都可以使用，线程结束了，那么相应的线程本地变量也就跟随着线程消失了。

以下内容是个人参考他人文章，理解总结出来，偏差之处，欢迎指正。

全篇包括两个部分，我希望大家对 ThreadLocal 源码已经有一定了解，我在文章中没有具体分析源码：

第一部分是说明 ThreadLocal 不是用来做变量共享的。

第二部分是深入了解 ThreadLocal 后得到的结论，谈谈什么情况用 ThreadLocal，以及用 ThreadLocal 有什么好处。

**一、ThreadLocal 不是用来解决多线程下访问共享变量问题的**

我想大家都知道，多线程情况下，对共享变量的访问是需要同步的，不然会引起不可预知的问题。

接下来我就是，我极力想要说明的：ThreadLocal 不是用来解决这个问题的！！！！！ ThreadLocal 可以在本线程持有一个共享变量的副本，对吧。大家都这么说。

我举个栗子，若是在线程的 ThreadLocal 中 set 一个程序中唯一的共享变量，该 ThreadLocal 仅仅是保存了一个共享变量的引用值，共享变量的实例对象在内存中只有一个。

**下面我们先测试一下，是不是这样：**

我先定义一个 Person 类，我们假定这个 Person 是要被共享的吧 ··· 哈哈（TheradLocal 实际上不是这样用的）

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f0c99dd418?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

然后创建一个 target 实现 Runnable 接口：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f0c98daac2?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

最后我们来测试一下，到底线程中，对共享变量的本地副本是怎么一回事：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f0c99faa6d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

我们来看看运行结果：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f0c9a43ba1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

我们可以看到，Thread-0 线程虽然创建了一个 ThreadLocal，并且将共享变量放入，但是线程内改变了共享变量的值，依然会对共享变量本身进行改变。

参考源码，我们可以看到 ThreadLocal 调用 set（T value）方法时，是将调用者 ThreadLocal 作为 ThreadLocalMap 的 key 值，value 作为 ThreadLocalMap 的 value 值。

我们看看 ThradLocal 类里面到底有什么：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f222142198?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

红色箭头标注出了四个我们常用的方法，并且 ThreadLocal 里定义了一个内部类 ThreadLocalMap，但是注意一下，虽然它定义了这样一个内部类，但 ThreadLocal 本身真的没有持有 ThreadLocalMap 的变量，

这个 ThreadLocalMap 的持有者是 Thread。

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f225ccbc76?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

所以，文章 A 中，在开头说了这样一段：

> ThreadLocal 是如何做到为每一个线程维护变量的副本的呢？其实实现的思路很简单：在 ThreadLocal 类中有一个 Map，用于存储每一个线程的变量副本，Map 中元素的键为线程对象，而值对应线程的变量副本。

正确应该是：在 Thread 类里面有一个 ThreadLocalMap，用于存储每一个线程的变量的引用，这个 Map 中的键为 ThreadLocal 对象，而值对应的是 ThreadLocal 通过 set 放进去的变量引用。

我在这里一直强调的是，ThreadLocal 通过 set（共享变量）然后再通过 ThreadLocal 方法 get 的是共享变量的引用！！！  如果多个线程都在其执行过程中将共享变量加入到自己的 ThreadLocal 中，那就是每个线程都持有一份共享变量的引用副本，注意是引用副本，共享变量的实例只有一个。所以，ThreadLocal 不是用来解决线程间共享变量的访问的事儿的。想要控制共享变量在多个线程之间按照程序员想要的方式来进行，那是锁和线程间通信的事，和 ThreadLocal 没有半毛钱的关系。

总的来说：每个线程中都有一个自己的 ThreadLocalMap 类对象，可以将线程自己的对象保持到其中，各管各的，线程执行期间都可以正确的访问到自己的对象。

**二、ThreadLocal 到底该怎么用**

说了这么多，我觉得还是举栗子来说明一下，ThreadLocal 到底该怎么用，有什么好处。

大家都知道，SimpleDateFomat 是线程不安全的，因为里面用了 Calendar 这个成员变量来实现 SimpleDataFormat, 并且在 Parse 和 Format 的时候对 Calendar 进行了修改，calendar.clear()，calendar.setTime(date)。总之在多线程情况下，若是用同一个 SimpleDateFormat 是要出问题的。

那么问题来了，为了线程安全，是不是在每个线程使用 SimpleDateFormat 的时候都手动 new 出来一个新的用？  这得多麻烦啊，一般来说，在开发时，SimpleDateFormat 这样的类我们是放在工具类里面的，阿里巴巴 Java 开发手册里面这样推荐 DateUtils：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f2297c79f6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这里重写了 initialValue 方法，新建了一个 SimpleDateFormat 对象并返回，这样我们就可以在任何线程任何地方想要执行日期格式化的时候，就可以像如下方式来执行，并且线程之间互相没有影响：

 DateUtils.df.get().format(new Date());

我们来看看为什么这么做线程之间就没有影响了。假设现在有线程 A 和线程 B 同时执行以上语句，那么两个线程是怎么操作的呢？

线程 A：df.get 的时候，首先尝试获得线程 A 自己 ThreadLocalMap, 如果是第一次 get，由于我们没有 set，而是重写了 initialValue 方法，所以在 A 线程第一次 get 时没有 ThreadLocalMap，这时线程 A 会

new 一个线程 A 自己的 ThreadLocalMap 出来，将 df（注意 df 是 ThreadLocal 变量）作为这个 map 的键，将 initialValue 中返回的值（注意是 new 出来的）作为 map 的值。这个时候 A 线程里面就有一个 ThreadLocalMap 了，并且里面保存了一个 SimpleDateFormat 的引用。那么从现在开始，线程 A 的生存期间，再次调用 df.get(), 都将获得一个 A 线程的 ThreadLocalMap，并且通过 df 作为键得到相应的 SimpleDateFormat;

线程 B：df.get 的时候，首先尝试获得线程 B 自己 ThreadLocalMap, 如果是第一次 get，由于我们没有 set，而是重写了 initialValue 方法，所以在 B 线程第一次 get 时没有 ThreadLocalMap，这时线程 B 会

new 一个线程 B 自己的 ThreadLocalMap 出来，将 df（注意 df 是 ThreadLocal 变量，这里的 df 和线程 A 中的 df 是同一个，但是又有什么关系呢，map 不一样）作为这个 map 的键，将 initialValue 中返回的值（注意是 new 出来的，这里是线程 B 在执行 df.get 时自己 new 出来的，不再是线程 A 中的那个了）作为 map 的值。这个时候 A 线程里面就有一个 ThreadLocalMap 了，并且里面保存了一个 SimpleDateFormat 的引用。

那么从现在开始，线程 B 的生存期间，再次调用 df.get(), 都将获得一个 B 线程的 ThreadLocalMap，并且通过 df 作为键得到相应的 SimpleDateFormat（这里和线程 A 中已经是另外一个不同的对象了）;

这下大概明白为什么说这样用就线程安全了吧，这里的线程安全并不是指访问的同一个对象，而是每个线程创建自己的对象（SimpleDateFormat）来用，各自用各自的，当然线程安全了。。。

当然大家可以说，这和自己在线程里面每次用的时候 new 出来一个有什么区别呢，对，没区别，但是这样方便啊，而且可以保持线程里面只有唯一一个 SimpleDateFormat 对象，你要每用一次 new 一次，那就消耗内存了撒。可能你会说，那我只 new 一个，那个方法用的时候通过参数传递过去就行。。。。。  不嫌麻烦的话我也无话可说。哈哈。。  然而 ThreadLocal 却太方便了。。。   敬仰神人竟然能创造出 ThreadLocal。这才是 ThreadLocal。

**总结一下：**

ThreadLocal 真的不是用来解决对象共享访问问题的，而主要是提供了保持对象的方法和避免参数传递的方便的对象访问方式。 

1、每个线程中都有一个自己的 ThreadLocalMap 类对象，可以将线程自己的对象保持到其中，各管各的，线程可以正确的访问到自己的对象。 

2、将一个共用的 ThreadLocal 静态实例作为 key（上面得 df），将不同对象的引用保存到不同线程的 ThreadLocalMap 中，然后在线程生命周期内执行的各处通过这个静态 ThreadLocal 实例的 get() 方法取得自己线程保存的那个对象，避免了将这个对象（指的是 SimpleDateFormat）作为参数传递的麻烦。

**补充一下：**

一般情况下，通过 ThreadLocal.set() 到线程中的对象是该线程自己使用的对象，其他线程是不需要访问的，也访问不到的。各个线程中访问的是不同的对象。

 若不用 DateUtils 工具类，完全可以在线程开始的时候这样执行：

![](https://user-gold-cdn.xitu.io/2018/9/16/165e05f2a02833f4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

然后在线程生命周期的任何地方调用：

 df.get().format(new Date());

效果是一样的，可是这没有工具类方便嘛。。。

本文个人理解后整理，文章中存在很多表述不清楚的地方，欢迎留言讨论。

**参考文章：**

A 文章：http://blog.csdn.net/lufeng20/article/details/24314381B 文章：http://www.cnblogs.com/dolphin0520/p/3920407.html C 文章：http://www.iteye.com/topic/103804

（作者）

作者 l Gonjian

来源：https://www.cnblogs.com/gonjan-blog/p/6507072.html
