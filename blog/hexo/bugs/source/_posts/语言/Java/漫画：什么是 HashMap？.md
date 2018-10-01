---
title: 漫画：什么是 HashMap？
date: 2018-09-29 08:36:03
tags: [java]
categories: [java]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5a215783f265da431d3c7bba

​![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc543e5604?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc52f29142?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc53163f19?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc54953d78?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

————————————

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc5325169a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc538f1b37?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc7b01a1e5?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc79349407?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc7c189315?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc7b1b0aa1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

众所周知，HashMap 是一个用于存储 Key-Value 键值对的集合，每一个键值对也叫做 **Entry**。这些个键值对（Entry）分散存储在一个数组当中，这个数组就是 HashMap 的主干。

HashMap 数组每一个元素的初始值都是 Null。

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc8eb1be60?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

对于 HashMap，我们最常使用的是两个方法：**Get** 和 **Put**。

**1.Put 方法的原理**

调用 Put 方法的时候发生了什么呢？

比如调用 hashMap.put("apple", 0) ，插入一个 Key 为 “apple" 的元素。这时候我们需要利用一个哈希函数来确定 Entry 的插入位置（index）：

**index = Hash（“apple”）**

假定最后计算出的 index 是 2，那么结果如下：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcaff8b9c1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

但是，因为 HashMap 的长度是有限的，当插入的 Entry 越来越多时，再完美的 Hash 函数也难免会出现 index 冲突的情况。比如下面这样：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dc96908c9b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这时候该怎么办呢？我们可以利用**链表**来解决。

HashMap 数组的每一个元素不止是一个 Entry 对象，也是一个链表的头节点。每一个 Entry 对象通过 Next 指针指向它的下一个 Entry 节点。当新来的 Entry 映射到冲突的数组位置时，只需要插入到对应的链表即可：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd5e241325?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

需要注意的是，新来的 Entry 节点插入链表时，使用的是 “头插法”。至于为什么不插入链表尾部，后面会有解释。

2.Get 方法的原理

使用 Get 方法根据 Key 来查找 Value 的时候，发生了什么呢？

首先会把输入的 Key 做一次 Hash 映射，得到对应的 index：

index = Hash（“apple”）

由于刚才所说的 Hash 冲突，同一个位置有可能匹配到多个 Entry，这时候就需要顺着对应链表的头节点，一个一个向下来查找。假设我们要查找的 Key 是 “apple”：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcb60e4e33?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

第一步，我们查看的是头节点 Entry6，Entry6 的 Key 是 banana，显然不是我们要找的结果。

第二步，我们查看的是 Next 节点 Entry1，Entry1 的 Key 是 apple，正是我们要找的结果。

之所以把 Entry6 放在头节点，是因为 HashMap 的发明者认为，**后插入的 Entry 被查找的可能性更大**。

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcb4cc5a68?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dca7f241b3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcbe24c396?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcd7f261fb?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dce476625f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcd7f261fb?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcedf11a77?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcd7f261fb?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dceea2ac49?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dcfc77338c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

————————————

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd0ab57139?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd187b1d19?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd21196889?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd2e4373a3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd3f6fd588?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

之前说过，从 Key 映射到 HashMap 数组的对应位置，会用到一个 Hash 函数：

**index = Hash（“apple”）**

如何实现一个尽量均匀分布的 Hash 函数呢？我们通过利用 Key 的 HashCode 值来做某种运算。

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd46b7e5a1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

**index = HashCode（**Key**） % Length ?**

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd56a0b9ef?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

如何进行位运算呢？有如下的公式（Length 是 HashMap 的长度）：

**index = HashCode（**Key**） & （**Length** - 1）**

下面我们以值为 “book” 的 Key 来演示整个过程：

1\. 计算 book 的 hashcode，结果为十进制的 3029737，二进制的 101110001110101110 1001。

2\. 假定 HashMap 长度是默认的 16，计算 Length-1 的结果为十进制的 15，二进制的 1111。

3\. 把以上两个结果做**与运算**，101110001110101110 1001 & 1111 = 1001，十进制是 9，所以 index=9。

可以说，Hash 算法最终得到的 index 结果，完全取决于 Key 的 Hashcode 值的最后几位。

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd518aa9c7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd52a73a2e?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

假设 HashMap 的长度是 10，重复刚才的运算步骤：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd66736dac?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

单独看这个结果，表面上并没有问题。我们再来尝试一个新的 HashCode 101110001110101110 **1011** ：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd877e95af?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

让我们再换一个 HashCode 101110001110101110 **1111** 试试 ：

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd753e752b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

是的，虽然 HashCode 的倒数第二第三位从 0 变成了 1，但是运算的结果都是 1001。也就是说，当 HashMap 长度为 10 的时候，有些 index 结果的出现几率会更大，而有些 index 结果永远不会出现（比如 0111）！

这样，显然不符合 Hash 算法均匀分布的原则。

反观长度 16 或者其他 2 的幂，Length-1 的值是所有二进制位全为 1，这种情况下，index 的结果等同于 HashCode 后几位的值。只要输入的 HashCode 本身分布均匀，Hash 算法的结果就是均匀的。

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd8627cdbc?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd88f4abf7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

喜欢本文的朋友们，欢迎长按下图关注订阅号**程序员小灰**，收看更多精彩内容

![](https://user-gold-cdn.xitu.io/2017/12/1/160123dd91630187?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
