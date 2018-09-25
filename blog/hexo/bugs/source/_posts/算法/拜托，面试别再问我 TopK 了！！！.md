---
title: TopK问题
date: 2018-09-25 08:36:03
tags: [算法]
categories: [算法]
---
> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/entry/5ba385dbe51d450e5d0b0a76?utm_source=gold_browser_extension

> 前言：本文将介绍随机选择，分治法，减治法的思想，以及 TopK 问题优化的来龙去脉，原理与细节，保证有收获。

面试中，TopK，是问得比较多的几个问题之一，到底有几种方法，这些方案里蕴含的优化思路究竟是怎么样的，今天和大家聊一聊。

_画外音：_ _除非校招，我在面试过程中从不问 TopK 这个问题，默认大家都知道。_

**问题描述**：

从 arr[1, n] 这 n 个数中，找出最大的 k 个数，这就是经典的 TopK 问题。

**栗子**：

从 arr[1, 12]={5,3,7,1,8,2,9,4,7,2,6,6} 这 n=12 个数中，找出最大的 k=5 个。

**一、排序**

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f63b5392d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

排序是最容易想到的方法，将 n 个数排序之后，取出最大的 k 个，即为所得。

**伪代码**：

sort(arr, 1, n);

return arr[1, k];

**时间复杂度**：O(n*lg(n))

**分析**：明明只需要 TopK，却将全局都排序了，这也是这个方法复杂度非常高的原因。那能不能不全局排序，而只局部排序呢？ 这就引出了第二个优化方法。

**二、局部排序**

不再全局排序，只对最大的 k 个排序。

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f6398efd6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

冒泡是一个很常见的排序方法，每冒一个泡，找出最大值，冒 k 个泡，就得到 TopK。

**伪代码**：

for(i=1 to k){

         bubble_find_max(arr,i);

}

return arr[1, k];

**时间复杂度**：O(n*k)

**分析**：冒泡，将全局排序优化为了局部排序，非 TopK 的元素是不需要排序的，节省了计算资源。不少朋友会想到，需求是 TopK，是不是这最大的 k 个元素也不需要排序呢？ 这就引出了第三个优化方法。

**三、堆**

**思路**：只找到 TopK，不排序 TopK。

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f63ab4ba7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

先用前 k 个元素生成一个小顶堆，这个小顶堆用于存储，当前最大的 k 个元素。

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f63a8839a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

接着，从第 k+1 个元素开始扫描，和堆顶（堆中最小的元素）比较，如果被扫描的元素大于堆顶，则替换堆顶的元素，并调整堆，以保证堆内的 k 个元素，总是当前最大的 k 个元素。

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f7b5e35f9?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

直到，扫描完所有 n-k 个元素，最终堆中的 k 个元素，就是猥琐求的 TopK。

**伪代码**：

heap[k] = make_heap(arr[1, k]);

for(i=k+1 to n){

         adjust_heap(heep[k],arr[i]);

}

return heap[k];

**时间复杂度**：O(n*lg(k))

_画外音：n 个元素扫一遍，假设运气很差，每次都入堆调整，调整时间复杂度为堆的高度，即 lg(k)，故整体时间复杂度是 n*lg(k)。_

**分析**：堆，将冒泡的 TopK 排序优化为了 TopK 不排序，节省了计算资源。堆，是求 TopK 的经典算法，那还有没有更快的方案呢？

**四、随机选择**

随机选择算在是《算法导论》中一个经典的算法，其时间复杂度为 O(n)，是一个线性复杂度的方法。

这个方法并不是所有同学都知道，为了将算法讲透，先聊一些前序知识，一个所有程序员都应该烂熟于胸的经典算法：快速排序。

_画外音：_

_（1）如果有朋友说，“不知道快速排序，也不妨碍我写业务代码呀”… 额..._

_（2）除非校招，我在面试过程中从不问快速排序，默认所有工程师都知道；_

**其伪代码是**：

void quick_sort(int[]arr, int low, inthigh){

         if(low== high) return;

         int i = partition(arr, low, high);

         quick_sort(arr, low, i-1);

         quick_sort(arr, i+1, high);

}

其核心算法思想是，分治法。

**分治法**（Divide&Conquer），把一个大的问题，转化为若干个子问题 （Divide），每个子问题 “**都**” 解决，大的问题便随之解决（Conquer）。这里的关键词是 **“都”**。从伪代码里可以看到，快速排序递归时，先通过 partition 把数组分隔为两个部分，两个部分 “都” 要再次递归。

分治法有一个特例，叫减治法。

**减治法**（Reduce&Conquer），把一个大的问题，转化为若干个子问题 （Reduce），这些子问题中 “**只**” 解决一个，大的问题便随之解决（Conquer）。这里的关键词是 **“只”**。

**二分查找 binary_search**，BS，是一个典型的运用 减治法思想的算法，其伪代码是：

int BS(int[]arr, int low, inthigh, int target){

         if(low> high) return -1;

         mid= (low+high)/2;

         if(arr[mid]== target) return mid;

         if(arr[mid]> target)

                   return BS (arr, low, mid-1, target);

         else

                   return BS (arr, mid+1, high, target);

}

从伪代码可以看到，二分查找，一个大的问题，可以用一个 mid 元素，分成左半区，右半区两个子问题。而左右两个子问题，只需要解决其中一个，递归一次，就能够解决二分查找全局的问题。

通过分治法与减治法的描述，可以发现，分治法的复杂度一般来说是大于减治法的：

快速排序：O(n*lg(n))

二分查找：O(lg(n))

话题收回来，**快速排序**的核心是：

i = partition(arr, low, high);

**这个 partition 是干嘛的呢？**

顾名思义，partition 会把整体分为两个部分。

更具体的，会用数组 arr 中的一个元素（默认是第一个元素 t=arr[low]）为划分依据，将数据 arr[low, high] 划分成左右两个子数组：

*   左半部分，都比 t 大

*   右半部分，都比 t 小

*   中间位置 i 是划分元素

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f7c00aa05?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

以上述 TopK 的数组为例，先用第一个元素 t=arr[low] 为划分依据，扫描一遍数组，把数组分成了两个半区：

*   左半区比 t 大

*   右半区比 t 小

*   中间是 t

partition 返回的是 t 最终的位置 i。

很容易知道，partition 的时间复杂度是 O(n)。

_画外音：把整个数组扫一遍，比 t 大的放左边，比 t 小的放右边，最后 t 放在中间 N[i]。_

**partition 和 TopK 问题有什么关系呢？**

TopK 是希望求出 arr[1,n] 中最大的 k 个数，那如果找到了**第 k 大** 的数，做一次 partition，不就一次性找到最大的 k 个数了么？

_画外音：即 partition 后左半区的 k 个数。_

问题变成了 arr[1, n] 中找到第 k 大的数。

再回过头来看看**第一次** partition，划分之后：

i = partition(arr, 1, n);

*   如果 i 大于 k，则说明 arr[i] 左边的元素都大于 k，于是只递归 arr[1, i-1] 里第 k 大的元素即可；

*   如果 i 小于 k，则说明说明第 k 大的元素在 arr[i] 的右边，于是只递归 arr[i+1, n] 里第 k-i 大的元素即可；

_画外音：这一段非常重要，多读几遍。_

这就是**随机选择**算法 randomized_select，RS，其伪代码如下：

int RS(arr, low, high, k){

  if(low== high) return arr[low];

  i= partition(arr, low, high);

  temp= i-low; // 数组前半部分元素个数

  if(temp>=k)

      return RS(arr, low, i-1, k); // 求前半部分第 k 大

  else

      return RS(arr, i+1, high, k-i); // 求后半部分第 k-i 大

}

![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f7d503df1?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这是一个典型的减治算法，递归内的两个分支，最终只会执行一个，它的时间复杂度是 O(n)。

再次强调一下：

*   **分治法**，大问题分解为小问题，小问题都要递归各个分支，例如：快速排序

*   **减治法**，大问题分解为小问题，小问题只要递归一个分支，例如：二分查找，随机选择

通过随机选择（randomized_select），找到 arr[1, n] 中第 k 大的数，再进行一次 partition，就能得到 TopK 的结果。

**五、总结**

TopK，不难；其思路优化过程，不简单：

*   **全局排序**，O(n*lg(n))

*   **局部排序**，只排序 TopK 个数，O(n*k)

*   **堆**，TopK 个数也不排序了，O(n*lg(k))

*   分治法，每个分支 “都要” 递归，例如：快速排序，O(n*lg(n))

*   减治法，“只要” 递归一个分支，例如：二分查找 O(lg(n))，随机选择 O(n)

*   TopK 的另一个解法：**随机选择** +partition

知其然，知其所以然。

思路比结论重要。

希望大家对 TopK 有新的认识，谢转。

**![](https://user-gold-cdn.xitu.io/2018/9/20/165f6c2f7f0061aa?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)**

**架构师之路** - 分享可落地的架构文章

相关推荐：

《[数据库索引底层，如何实现？](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMjM5ODYxMDA5OQ%3D%3D%26mid%3D2651961486%26idx%3D1%26sn%3Db319a87f87797d5d662ab4715666657f%26chksm%3Dbd2d0d528a5a84446fb88da7590e6d4e5ad06cfebb5cb57a83cf75056007ba29515c85b9a24c%26scene%3D21%23wechat_redirect)》**B + 树**

《[搜索引擎底层，如何实现？](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMjM5ODYxMDA5OQ%3D%3D%26mid%3D2651959895%26idx%3D1%26sn%3Dde25ce2544c088ff9be0b93fd3ea4d15%26chksm%3Dbd2d078b8a5a8e9d5ae4339a683d3f980ff2994f3c10c4081c7bab7f0d77f37521de95e974bf%26scene%3D21%23wechat_redirect)》**倒排索引**

《[10W 定时任务，如何实现？](https://link.juejin.im?target=http%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMjM5ODYxMDA5OQ%3D%3D%26mid%3D2651959957%26idx%3D1%26sn%3Da82bb7e8203b20b2a0cb5fc95b7936a5%26chksm%3Dbd2d07498a5a8e5f9f8e7b5aeaa5bd8585a0ee4bf470956e7fd0a2b36d132eb46553265f4eaf%26scene%3D21%23wechat_redirect)》**HWTimer**

**挖坑**：TopK，你以为这就是最快的解法？太小看架构师之路了，更快方案 ，且听下一期分解。
