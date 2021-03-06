---
title: 数据结构之排序-Java
date: 2018-10-11 08:36:03
tags: [算法]
categories: [算法]
---
> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.cnblogs.com/20145221GQ/p/5407824.html

# Java 实现：数据结构之排序

## 0\. 概述

*   形式化定义：假设有 n 个记录的序列（待排序列）为 {R1, R2 , …, Rn}，其相应的关键字序列为 { K1, K2, …, Kn }。找到{1,2, …, n} 的一个排列 p1,p2, …, pn，使得 Kp1≤Kp2≤ …≤ Kpn （升序），按此排列将 n 个记录重新排列为 { Rp1, Rp2, …，Rpn }的操作称作排序。
*   排序方法分类
    *   基于比较的排序：
        *   比较两个关键字大小
        *   移动关键字到合适位置（交换或复制）
    *   不基于比较的排序
*   排序有内部排序和外部排序之分，内部排序是数据记录在内存中进行排序，而外部排序是因排序的数据很大，一次不能容纳全部的排序记录，在排序过程中需要访问外存。
*   本篇博客所要介绍的是内部排序中的八大排序方法（参考博客地址为 C 语言实现）：
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131315679-1289433839.png)

## 1\. 插入排序—直接插入排序 (Straight Insertion Sort)

*   基本思想
    在要排序的一组数中，假设前面 (n-1)[n>=2] 个数已经是排好顺序的，现在要把第 n 个数插到前面的有序数中，使得这 n 个数也是排好顺序的。如此反复循环，直到全部排好顺序。
*   代码实现（InsertSort.java）

```
package DataStructures.Sort;
public class InsertSort {
    public InsertSort(int a[]){
        int temp = 0;
        for(int i=1; i<a.length; i++){
            int j = i-1;
            temp=a[i];
            for(; j>=0 && temp<a[j]; j--){
                a[j+1] = a[j];  //将大于temp的值整体后移一个单位
            }
            a[j+1] = temp;
        }
    }
}
```

*   运行结果（[InsertSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/InsertSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FInsertSortDemo.java&oid=59a40da633a92ec93d8aa1210f5fe5202e4361cf&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131325804-846904131.png)

## 2\. 插入排序—希尔排序（Shell's Sort）

*   基本思想
    算法先将要排序的一组数按某个增量 d（n/2,n 为要排序数的个数）分成若干组，每组中记录的下标相差 d. 对每组中全部元素进行直接插入排序，然后再用一个较小的增量（d/2）对它进行分组，在每组中再进行直接插入排序。当增量减到 1 时，进行直接插入排序后，排序完成。
*   代码实现（ShellSort.java）

```
package DataStructures.Sort;
public class ShellSort {
    public ShellSort(int a[]) {
        double d1 = a.length;
        int temp = 0;
        while (true) {
            d1 = Math.ceil(d1 / 2); //返回大于参数x的最小整数,即对浮点数向上取整
            int d = (int) d1;
            for (int x = 0; x < d; x++) {
                for (int i = x + d; i < a.length; i += d) {
                    int j = i - d;
                    temp = a[i];
                    for (; j >= 0 && temp < a[j]; j -= d) {
                        a[j + d] = a[j];
                    }
                    a[j + d] = temp;
                }
            }
            if (d == 1) {
                break;
            }
        }
    }
}
```

*   运行结果（[ShellSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/ShellSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FShellSortDemo.java&oid=1772494b3684ded3417731e8987e0ed7756dbbd7&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131334273-1171682317.png)

## 3\. 选择排序—简单选择排序（Simple Selection Sort）

*   基本思想
    在要排序的一组数中，选出最小（或者最大）的一个数与第 1 个位置的数交换；然后在剩下的数当中再找最小（或者最大）的与第 2 个位置的数交换，依次类推，直到第 n-1 个元素（倒数第二个数）和第 n 个元素（最后一个数）比较为止。
*   代码实现（SelectSort.java）

```
package DataStructures.Sort;
public class SelectSort {
    public SelectSort(int a[]){
        int position = 0;
        for(int i=0; i<a.length; i++){
            int j = i+1;
            position = i;
            int temp = a[i];
            for(; j<a.length; j++){
                if(a[j] < temp){
                    temp = a[j];
                    position = j;
                }
            }
            a[position] =a [i];
            a[i] = temp;
        }
    }
}
```

*   运行结果（[SelectSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/SelectSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FSelectSortDemo.java&oid=56d196e1edec387b7a3a8926c5bab4c4f013fb9b&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131341523-2048063814.png)

## 4\. 选择排序—堆排序（Heap Sort）

*   基本思想
    *   堆排序是一种树形选择排序，是对直接选择排序的有效改进。可以将一个堆看做是一棵完全二叉树的顺序存储。以升序排序为例：
    *   通过建大顶堆，将待排序列中的最大元素筛选出来（即根结点位置）。
    *   将根结点与待排序列中最后一个元素交换。
    *   调整剩余元素再次成为大顶堆。
    *   不断重复上述过程，直至堆中只剩 2 个元素为止。
*   代码实现（HeapSort.java）

```
//以建立大顶堆为例
package DataStructures.Sort;
public class HeapSort {
    public  HeapSort(int a[]){
        int arrayLength=a.length;
        //循环建堆
        for(int i=0;i<arrayLength-1;i++){
            //建堆
            buildMaxHeap(a,arrayLength-1-i);
            //交换堆顶和最后一个元素
            swap(a,0,arrayLength-1-i);
        }
    }
    private  void swap(int[] data, int i, int j) {
        int temp = data[i];
        data[i] = data[j];
        data[j] = temp;
    }
    //对data数组从0到lastIndex建大顶堆
    private void buildMaxHeap(int[] data, int lastIndex) {
        //从lastIndex处节点（最后一个节点）的父节点开始
        for(int i=(lastIndex-1)/2;i>=0;i--){
            //k保存正在判断的节点
            int k=i;
            //如果当前k节点的子节点存在
            while(k*2+1<=lastIndex){
                //k节点的左子节点的索引
                int biggerIndex=2*k+1;
                //如果biggerIndex小于lastIndex，即biggerIndex+1代表的k节点的右子节点存在
                if(biggerIndex<lastIndex){
                    //若果右子节点的值较大
                    if(data[biggerIndex]<data[biggerIndex+1]){
                        //biggerIndex总是记录较大子节点的索引
                        biggerIndex++;
                    }
                }
                //如果k节点的值小于其较大的子节点的值
                if(data[k]<data[biggerIndex]){
                    //交换他们
                    swap(data,k,biggerIndex);
                    //将biggerIndex赋予k，开始while循环的下一次循环，重新保证k节点的值大于其左右子节点的值
                    k=biggerIndex;
                }
                else{
                    break;
                }
            }
        }
    }
}
```

*   运行结果（[HeapSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/HeapSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FHeapSortDemo.java&oid=cb5a3bd915f0c989c7c27fe875bec83d82300f2b&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131351585-288732267.png)

## 5\. 交换排序—冒泡排序（Bubble Sort）

*   基本思想
    在要排序的一组数中，对当前还未排好序的范围内的全部数，自上而下对相邻的两个数依次进行比较和调整，让较大的数往下沉，较小的往上冒。即：每当两相邻的数比较后发现它们的排序与排序要求相反时，就将它们互换。
*   代码实现（BubbleSort.java）

```
package DataStructures.Sort;
public class BubbleSort {
    public BubbleSort(int[] a){
        int temp;
        for(int i=0; i<a.length-1; i++){
            for(int j=0; j<a.length-1-i; j++){
                if(a[j] > a[j+1]){
                    temp = a[j];
                    a[j] = a[j+1];
                    a[j+1] = temp;
                }
            }
        }
    }
}
```

*   运行结果（[BubbleSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/BubbleSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FBubbleSortDemo.java&oid=b2363219c4acf3fff81249accaf1fc12633638dd&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131423476-344199340.png)

## 6\. 交换排序—快速排序（Quick Sort）

*   基本思想
    *   选择一个基准元素, 通常选择第一个元素或者最后一个元素
    *   通过一趟排序讲待排序的记录分割成独立的两部分，其中一部分记录的元素值均比基准元素值小。另一部分记录的 元素值比基准值大。
    *   此时基准元素在其排好序后的正确位置
    *   然后分别对这两部分记录用同样的方法继续进行排序，直到整个序列有序
*   代码实现（QuickSort.java）

```
package DataStructures.Sort;
public class QuickSort {
    public QuickSort(int[] a){
        quick(a);
    }
    private int getMiddle(int[] list, int low, int high) {
        int temp = list[low];    //数组的第一个作为中轴
        while (low < high){
            while (low<high && list[high]>=temp) {
                high--;
            }
            list[low] =list[high];   //比中轴小的记录移到低端
            while (low <high && list[low]<=temp) {
                low++;
            }
            list[high] = list[low];   //比中轴大的记录移到高端
        }
        list[low] = temp;              //中轴记录到尾
        return low;                   //返回中轴的位置
    }
    private void quickSort(int[] list, int low, int high) {
        if (low < high){
            int middle = getMiddle(list, low, high);  //将list数组进行一分为二
            quickSort(list, low, middle - 1);       //对低字表进行递归排序
            quickSort(list, middle + 1, high);       //对高字表进行递归排序
        }
    }
    private void quick(int[] a2) {
        if (a2.length > 0) {    //查看数组是否为空
            quickSort(a2,0, a2.length - 1);
        }
    }
}
```

*   运行结果（[QuickSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/QuickSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FQuickSortDemo.java&oid=c2f7757877851a457e884d5d11f6cacdcbe4e046&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131433085-824900528.png)

## 7\. 归并排序（Merge Sort）

*   基本思想
    *   归并（Merge）排序法是将两个（或两个以上）有序表合并成一个新的有序表，即把待排序序列分为若干个子序列，每个子序列是有序的。然后再把有序子序列合并为整体有序序列。
    *   分解：将含有 n 个元素的待排序列分解为各含 n/2 个元素的两个子序列。
    *   解决：用归并排序递归地排序两个子序列。
    *   合并：合并两个已排序的子序列，以得到最终结果。
*   代码实现（MergeSort.java）

```
package DataStructures.Sort;
public class MergeSort {
    public MergeSort(int[] a){
        sort(a,0,a.length-1);
    }
    private void sort(int[] data, int left, int right) {
        if(left < right){
            //找出中间索引
            int center = (left+right)/2;
            //对左边数组进行递归
            sort(data, left, center);
            //对右边数组进行递归
            sort(data, center+1, right);
            //合并
            merge(data, left, center, right);
        }
    }
    private void merge(int[] data, int left, int center, int right) {
        int [] tmpArr = new int[data.length];
        int mid = center+1;
        //third记录中间数组的索引
        int third = left;
        int tmp = left;
        while(left<=center && mid<=right){
            //从两个数组中取出最小的放入中间数组
            if(data[left] <= data[mid]){
                tmpArr[third++] = data[left++];
            }
            else{
                tmpArr[third++] = data[mid++];
            }
        }
        //剩余部分依次放入中间数组
        while(mid <= right){
            tmpArr[third++] = data[mid++];
        }
        while(left <= center){
            tmpArr[third++] = data[left++];
        }
        //将中间数组中的内容复制回原数组
        while(tmp <= right){
            data[tmp] = tmpArr[tmp++];
        }
    }
}
```

*   运行结果（[MergeSortDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/MergeSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FMergeSortDemo.java&oid=275910ac758c5f5aa232e9965189abf22e340d64&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131443991-348455675.png)

## 8\. 基数排序 (Radix Sort)

*   基本思想
    *   一种借助 “多关键字排序” 的思想来实现 “单关键字排序” 的算法。
    *   将所有待比较数值（正整数）统一为同样的数位长度，数位较短的数前面补零。然后，从最低位开始，依次进行一次排序。这样从最低位排序一直到最高位排序完成以后, 数列就变成一个有序序列。
        ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131457320-198302862.png)
*   代码实现（RadixSort.java）

```
package DataStructures.Sort;
import java.util.ArrayList;
import java.util.List;
public class RadixSort {
    public RadixSort(int[] a){
        radixSort(a);
    }
    private void radixSort(int[] a){
        //首先确定排序的趟数;
        int max=a[0];
        for(int i=1; i<a.length; i++){
            if(a[i] > max){
                max = a[i];
            }
        }
        int time = 0;
        //判断位数;
        while(max > 0){
            max /= 10;
            time++;
        }
        //建立10个队列;
        List<ArrayList> queue = new ArrayList<ArrayList>();
        for(int i=0; i<10; i++){
            ArrayList<Integer>queue1 = new ArrayList<Integer>();
            queue.add(queue1);
        }
        //进行time次分配和收集;
        for(int i=0; i<time; i++){
            //分配数组元素;
            for(int j=0; j<a.length; j++){
                //得到数字的第time+1位数;
                int x = a[j]%(int)Math.pow(10,i+1)/(int)Math.pow(10, i);
                ArrayList<Integer>queue2 = queue.get(x);
                queue2.add(a[j]);
                queue.set(x, queue2);
            }
            int count = 0;//元素计数器;
            //收集队列元素;
            for(int k=0; k<10; k++){
                while(queue.get(k).size() > 0){
                    ArrayList<Integer>queue3 = queue.get(k);
                    a[count] = queue3.get(0);
                    queue3.remove(0);
                    count++;
                }
            }
        }
    }
}
```

*   运行结果（[RadixDemo.java](http://git.oschina.net/20145221/java-besti-is-2015-2016-2-20145221/blob/master/src/DataStructures/Sort/RadixSortDemo.java?dir=0&filepath=src%2FDataStructures%2FSort%2FRadixSortDemo.java&oid=1e218f2e460cf69c3b9470ceffedba2d0edd4d9f&sha=56fd8f9deaf9f6c21bb1dc3c015912ee9f6b1bbf)）
    ![](https://images2015.cnblogs.com/blog/877163/201604/877163-20160419131509538-1724508624.png)

## 9\. 脉络梳理

*   排序算法稳定性：
    *   首先，通俗地讲就是能保证排序前 2 个相等的数其在序列的前后位置顺序和排序后它们两个的前后位置顺序相同。在简单形式化一下，如果 Ai = Aj, Ai 原来在位置前，排序后 Ai 还是要在 Aj 位置前。
    *   其次，说一下稳定性的好处。排序算法如果是稳定的，那么从一个键上排序，然后再从另一个键上排序，第一个键排序的结果可以为第二个键排序所用。基数排序就 是这样，先按低位排序，逐次按高位排序，低位相同的元素其顺序再高位也相同时是不会改变的。
    *   所以，堆排序、快速排序、希尔排序、直接选择排序不是稳定的排序算法，而基数排序、冒泡排序、直接插入排序、折半插入排序、归并排序是稳定的排序算法。（相关解释参考：[排序算法稳定性](http://baike.baidu.com/view/547325.htm)）
*   各种排序特点的比较：

| 排序算法 | 平均时间 | 最差情形 | 稳定度 | 额外空间 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 直接插入排序 | O(n^2) | O(n^2) | 稳定 | O(1) | n 小时较好 |
| 希尔排序 | O(nlogn) | O(n^s),1<s<2 | 不稳定 | O(1) | s 是所选分组 |
| 简单选择排序 | O(n^2) | O(n^2) | 不稳定 | O(1) | n 小时较好 |
| 堆排序 | O(nlogn) | O(nlogn) | 不稳定 | O(1) | n 大时较好 |
| 冒泡排序 | O(n^2) | O(n^2) | 稳定 | O(1) | n 小时较好 |
| 快速排序 | O(n) | O(n^2) | 不稳定 | O(nlogn) | n 大时较好 |
| 归并排序 | O(nlogn) | O(nlogn) | 稳定 | O(1) | n 大时较好 |
| 基数排序 | O(logrd) | O(logrd) | 稳定 | O(n) | d 是关键字项数 (0-9)，r 是基数 (个十百) |

## 参考资料

*   [八大排序算法](http://blog.csdn.net/hguisu/article/details/7776068)
*   [各种排序算法的总结和比较](http://blog.csdn.net/zz198808/article/details/8010352)
