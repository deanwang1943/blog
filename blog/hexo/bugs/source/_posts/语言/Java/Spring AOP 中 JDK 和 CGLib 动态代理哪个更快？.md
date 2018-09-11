---
title: Spring AOP 中 JDK 和 CGLib 动态代理哪个更快？
date: 2018-09-12 08:36:03
tags: [java,spring]
categories: [java]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/entry/5b95be3a6fb9a05d06732ec2?utm_source=gold_browser_extension

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef2a8f581b4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## **一、背景**

昨天一位知识星球的小伙伴面试的时候被问到：Spring AOP 中 JDK 和 CGLib 动态代理哪个效率更高？在知识星球整理了一下，今天特分享出来，供大家参考！对知识星球有兴趣的可以了解一下：

## **二、基本概念**

首先，我们知道 Spring AOP 的底层实现有两种方式：一种是 JDK 动态代理，另一种是 CGLib 的方式。

自 Java 1.3 以后，Java 提供了动态代理技术，允许开发者在运行期创建接口的代理实例，后来这项技术被用到了 Spring 的很多地方。

JDK 动态代理主要涉及 java.lang.reflect 包下边的两个类：Proxy 和 InvocationHandler。其中，InvocationHandler 是一个接口，可以通过实现该接口定义横切逻辑，并通过反射机制调用目标类的代码，动态地将横切逻辑和业务逻辑编织在一起。

JDK 动态代理的话，他有一个限制，就是它只能为接口创建代理实例，而对于没有通过接口定义业务方法的类，如何创建动态代理实例哪？答案就是 CGLib。

CGLib 采用底层的字节码技术，全称是：Code Generation Library，CGLib 可以为一个类创建一个子类，在子类中采用方法拦截的技术拦截所有父类方法的调用并顺势织入横切逻辑。

## **三、JDK 和 CGLib 动态代理区别**

1、JDK 动态代理具体实现原理：

*   通过实现 InvocationHandler 接口创建自己的调用处理器；

*   通过为 Proxy 类指定 ClassLoader 对象和一组 interface 来创建动态代理；

*   通过反射机制获取动态代理类的构造函数，其唯一参数类型就是调用处理器接口类型；

*   通过构造函数创建动态代理类实例，构造时调用处理器对象作为参数参入；

JDK 动态代理是面向接口的代理模式，如果被代理目标没有接口那么 Spring 也无能为力，Spring 通过 Java 的反射机制生产被代理接口的新的匿名实现类，重写了其中 AOP 的增强方法。

2、CGLib 动态代理：

CGLib 是一个强大、高性能的 Code 生产类库，可以实现运行期动态扩展 java 类，Spring 在运行期间通过 CGlib 继承要被动态代理的类，重写父类的方法，实现 AOP 面向切面编程呢。

3、两者对比：

*   JDK 动态代理是面向接口的。

*   CGLib 动态代理是通过字节码底层继承要代理类来实现（如果被代理类被 final 关键字所修饰，那么抱歉会失败）。

4、使用注意：

*   如果要被代理的对象是个实现类，那么 Spring 会使用 JDK 动态代理来完成操作（Spirng 默认采用 JDK 动态代理实现机制）；

*   如果要被代理的对象不是个实现类那么，Spring 会强制使用 CGLib 来实现动态代理。

## **四、JDK 和 CGLib 动态代理性能对比 - 教科书上的描述**

我们不管是看书还是看文章亦或是我那个上搜索参考答案，可能很多时候，都可以找到如下的回答：

关于两者之间的性能的话，JDK 动态代理所创建的代理对象，在以前的 JDK 版本中，性能并不是很高，虽然在高版本中 JDK 动态代理对象的性能得到了很大的提升，但是他也并不是适用于所有的场景。主要体现在如下的两个指标中：

1、CGLib 所创建的动态代理对象在实际运行时候的性能要比 JDK 动态代理高不少，有研究表明，大概要高 10 倍；

2、但是 CGLib 在创建对象的时候所花费的时间却比 JDK 动态代理要多很多，有研究表明，大概有 8 倍的差距；

3、因此，对于 singleton 的代理对象或者具有实例池的代理，因为无需频繁的创建代理对象，所以比较适合采用 CGLib 动态代理，反正，则比较适用 JDK 动态代理。

结果是不是如上边 1、2、3 条描述的那样哪？下边我们做一些小实验分析一下！

## **五、性能测试**

1、首先有几个 Java 类

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef2a8feb86c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

2、Target.java

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef2a8ee4a3c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

3、TargetImpl.java

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef3b8bd1f77?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

4、JdkDynamicProxyTest.java

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef3bc76bc7b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

5、CglibProxyTest.java

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef3bca9f02e?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

6、ProxyPerformanceTest.java

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef3bfd14966?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2018/9/10/165c1850c5f2e998?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

7、测试结果

（1）JDK 1.6

![](https://user-gold-cdn.xitu.io/2018/9/10/165c1850c61496a3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2018/9/10/165c1850c6605fc2?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

（2）JDK 1.7

![](https://user-gold-cdn.xitu.io/2018/9/10/165c1850c6584b7d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef57928a006?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

（3）JDK 1.8

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef587eaf636?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef590951aea?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

经过多次试验，可以看出平均情况下的话，JDK 动态代理的运行速度已经逐渐提高了，在低版本的时候，运行的性能可能不如 CGLib，但是在 1.8 版本中运行多次，基本都可以得到一致的测试结果，那就是 JDK 动态代理已经比 CGLib 动态代理快了！

但是 JDK 动态代理和 CGLib 动态代理的适用场景还是不一样的哈！

## **六、总结**

最终的测试结果大致是这样的，在 1.6 和 1.7 的时候，JDK 动态代理的速度要比 CGLib 动态代理的速度要慢，但是并没有教科书上的 10 倍差距，在 JDK1.8 的时候，JDK 动态代理的速度已经比 CGLib 动态代理的速度快很多了，希望小伙伴在遇到这个问题的时候能够有的放矢！

Spring AOP 中的 JDK 和 CGLib 动态代理关于这个知识点很重要，关于两者之间性能的对比经过测试实验已经有了一个初步的结果，以后再有人问你 Spring AOP，不要简单的说 JDK 动态代理和 CGLib 这两个了，是时候的可以抛出来对两者之间区别的理解，是有加分的哦！

参考文章：

1、https://blog.csdn.net/qq1723205668/article/details/56481476 2、https://blog.csdn.net/xiangbq/article/details/49794335

<section>

<section>

<section>

<section>

<section>

<section>

**点击图片查看更多推荐内容**

**↓↓↓**

[![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef59fd5f8ee?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzI1NDQ3MjQxNA%3D%3D%26mid%3D2247486862%26idx%3D1%26sn%3D67d996466338c4a3e1c382dcd3e5723f%26chksm%3De9c5f43fdeb27d29a8dc3979d979ea8e841f592cbd50c7b365548950c3624d79beba46cb7d5c%26scene%3D21%23wechat_redirect)

告诉你 38 个 MySQL 数据库的小技巧！

[![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef5d81d775d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzI1NDQ3MjQxNA%3D%3D%26mid%3D2247486856%26idx%3D1%26sn%3Dd430be5d14d159fd36b733c83369d59a%26chksm%3De9c5f439deb27d2f60b69d7f09b240eb43a8b1de2d07f7511e1f1fecdf9d49df1cb7bc6e1ab5%26scene%3D21%23wechat_redirect)

动态代理之投鞭断流！看一下 MyBatis 的底层实现原理！

[![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef5d96f602c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzI1NDQ3MjQxNA%3D%3D%26mid%3D2247486823%26idx%3D1%26sn%3Dce4e1ecdd72f34dddd3ae15b2b03d9dc%26chksm%3De9c5f4d6deb27dc02da35033172a1972c184927e67d8ca24224e3b47ce8a9cec542e0a0b21d9%26scene%3D21%23wechat_redirect)

令人生畏的源码，到底该怎样看？

[![](https://user-gold-cdn.xitu.io/2018/9/10/165c0ef5db4bcf50?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzI1NDQ3MjQxNA%3D%3D%26mid%3D2247486817%26idx%3D1%26sn%3D35a80c6b4289ab6897d090a246ea21d9%26chksm%3De9c5f4d0deb27dc6e818bd14a71ce1aab06c47b4299b348c022b35b6a55ae91ce910f0ee2643%26scene%3D21%23wechat_redirect)

怎么样才算一个靠谱的程序员！

</section>

</section>

</section>

</section>

</section>

</section>
