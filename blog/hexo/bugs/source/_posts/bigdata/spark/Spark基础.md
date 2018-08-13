---
title: Spark基础
date: 2018-07-24 08:36:03
tags:
  - spark
  - 大数据
  - docker
categories:
  - 大数据
---

1. 数据倾斜

   数据倾斜就是我们在计算数据的时候，数据的分散度不够，导致大量的数据集中到了一台或者几台机器上计算，这些数据的计算速度远远低于平均计算速度，导致整个计算过程过慢。

   Hadoop:

     Hadoop中的数据倾斜主要表现在、ruduce阶段卡在99.99%，一直99.99%不能结束。

     这里如果详细的看日志或者和监控界面的话会发现：

     有一个多几个reduce卡住

     各种container报错OOM

     读写的数据量极大，至少远远超过其它正常的reduce

     伴随着数据倾斜，会出现任务被kill等各种诡异的表现。

     经验：Hive的数据倾斜，一般都发生在Sql中Group和On上，而且和数据逻辑绑定比较深。

   Spark:

   Spark中的数据倾斜也很常见，这里包括Spark Streaming和Spark Sql，表现主要有下面几种：

   Executor lost，OOM，Shuffle过程出错

   Driver OOM

   单个Executor执行时间特别久，整体任务卡在某个阶段不能结束

   正常运行的任务突然失败

   数据倾斜的原理：

   在做数据运算的时候会设计到，countdistinct、group by、join等操作，这些都会触发Shuffle动作，一旦触发，所有相同key的值就会拉到一个或几个节点上，就容易发生单点问题。

   如何解决

   几个思路：
   1. 业务逻辑，我们从业务逻辑的层面上来优化数据倾斜，比如上面的例子，我们单独对这两个城市来做count，最后和其它城市做整合。
   2. 程序层面，比如说在Hive中，经常遇到count（distinct）操作，这样会导致最终只有一个reduce，我们可以先group 再在外面包一层count，就可以了。
   3. 调参方面，Hadoop和Spark都自带了很多的参数和机制来调节数据倾斜，合理利用它们就能解决大部分问题。

   Hadoop平台的优化方法

   1. mapjoin方式
   2. count distinct的操作，先转成group，再count
   3. 万能膏药：hive.groupby.skewindata=true
   4. left semi jioin的使用
   5. 设置map端输出、中间结果压缩。（不完全是解决数据倾斜的问题，但是减少了IO读写和网络传输，能提高很多效率）
   6. 自己实现partition类，用key和value相加取hash值。

   Spark平台的优化方法
   1. 列出来一些方法和思路，具体的参数和用法在官网看就行了。
   2. mapjoin方式
   3. 设置rdd压缩
   4. 合理设置driver的内存

2. 性能调优
3. Spark的数据在多节点环境中数据表现是怎么样的？
4. 执行了执行语句之后数据是怎么样流动的？
5. Spark SQL inner join2个表的数据是怎么样流动？
6. Spark SQL

  Spark将参与Join的两张表抽象为流式遍历表(streamIter)和查找表(buildIter)，通常streamIter为大表，buildIter为小表，我们不用担心哪个表为streamIter，哪个表为buildIter，这个spark会根据join语句自动帮我们完成。

  spark会基于streamIter来遍历，每次取出streamIter中的一条记录rowA，根据Join条件计算keyA，然后根据该keyA去buildIter中查找所有满足Join条件(keyB==keyA)的记录rowBs，并将rowBs中每条记录分别与rowAjoin得到join后的记录，最后根据过滤条件得到最终join的记录。


7. UDS UDAF
   UDF 1:1
   UDAF n:1 groupby extends UserDefindedAggregateFunction
