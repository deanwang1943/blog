---
title: Spark 的运行原理
date: 2018-10-25 08:36:03
tags:
  - spark
  - 大数据
categories:
  - 大数据
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5bb023bbe51d450ea52fdb3e?utm_source=gold_browser_extension

博客地址：[joey771.cn/2018/10/25/…](https://link.juejin.im?target=http%3A%2F%2Fjoey771.cn%2F2018%2F10%2F25%2Fspark%2Fspark%25E6%25BA%2590%25E7%25A0%2581%25E9%2598%2585%25E8%25AF%25BB%2FSpark%25E8%25BF%2590%25E8%25A1%258C%25E5%258E%259F%25E7%2590%2586%2F)

spark 的运行原理在大数据开发岗面试过程中是经常被问到的一个问题，我第一次被问到这个问题的时候有点摸不着头脑，这么大的一个问题我究竟应该怎样回答呢？是去描述一下 spark 的架构组成还是说一下底层的调用细节？后来查找了一些资料，看了一些书之后对这个问题有了一些理解，其实提这个问题的人可能最希望我们回答的是 Spark 运行的过程细节，简单来说就是把某个 Spark 程序从提交到执行完成中间经历了哪些步骤描述出来。如果在描述的过程中能够加入一些对 Spark 底层源码细节的解释会给提问者留下比较好的印象，认为你不仅仅是停留在使用 Spark 上，还对底层源码的原理有所了解。

### 简单描述 Spark 的运行原理

> 用户使用 spark-submit 提交一个作业之后，会首先启动一个 driver 进程，driver 进程会向集群管理器（standalone、YARN、Mesos）申请本次运行所需要的资源（这里的资源包括 core 和 memory，可以在 spark-submit 的参数中进行设置），集群管理器会根据我们需要的参数在各个节点上启动 executor。申请到对应资源之后，driver 进程就会开始调度和执行我们编写的作业代码。作业会被提交给 DAGScheduler，DAGScheduler 会根据作业中 RDD 的依赖关系将作业拆分成多个 stage，拆分的原则就是根据是否出现了宽依赖，每个 stage 当中都会尽可能多的包含连续的窄依赖。每个 stage 都包含了作业的一部分，会生成一个 TaskSet 提交给底层调度器 TaskScheduler，TaskScheduler 会把 TaskSet 提交到集群当中由 executor 进行执行。Task 的划分是根据数据的 partition 进行划分，一个 partition 会划分为一个 task。如此循环往复，直至执行完编写的 driver 程序的所有代码逻辑，并且计算完所有的数据。

简单的运行流程如下图：

<center>![](https://user-gold-cdn.xitu.io/2018/9/30/16629a724b5034a3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

图一 spark 运行流程

</center>

### SparkContext

Spark 程序的整个运行过程都是围绕 spark driver 程序展开的，spark driver 程序当中最重要的一个部分就是 SparkContext，SparkContext 的初始化是为了准备 Spark 应用程序的运行环境，SparkContext 主要是负责与集群进行通信、向集群管理器申请资源、任务的分配和监控等。

driver 与 worker 之间的架构如下图，driver 负责向 worker 分发任务，worker 将处理好的结果返回给 driver。

<center>![](https://user-gold-cdn.xitu.io/2018/9/30/16629ab664dc9649?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

图二 driver 架构

</center>

SparkContext 的核心作用是初始化 Spark 应用程序运行所需要的核心组件，包括高层调度器 DAGScheduler、底层调度器 TaskScheduler 和调度器的通信终端 SchedulerBackend，同时还会负责 Spark 程序向 Master 注册程序等。Spark 应用当中的 RDD 是由 SparkContext 进行创建的，例如通过 SparkContext.textFile()、SparkContext.parallel() 等这些 API。运行流程当中提及的向集群管理器 Cluster Manager 申请计算资源也是由 SparkContext 产生的对象来申请的。接下来我们从源码的角度学习一下 SparkContext，关于 SparkContext 创建的各种组件，在 SparkContext 类中有这样一段代码来创建这些组件：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8d2fbb706104?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

### DAGScheduler

DAGScheduler 是一个高层调度器，能够将 DAG 的各个 RDD 划分到不同的 Stage，并构建这些 Stage 之间的父子关系，最后将每个 Stage 根据 partition 划分为多个 Task，并以 TaskSet 的形式提交给底层调度器 TaskScheduler。Stage 的划分按照的是 RDD 依赖关系中是否出现了宽依赖，宽依赖指的是父 RDD 中的一个 partition 被子 RDD 的多个 partition 所依赖，简单来说就是父 RDD 的 partition 的出度大于 1，同理，窄依赖指的就是父 RDD 的一个 partition 只被子 RDD 的一个 partition 所依赖，也就是父 RDD 的 partition 的出度都是 1。每个 Stage 当中都会尽可能包含多的窄依赖，将各个窄依赖的算子形成一整个 pipeline 进行运行，可以减少各个算子之间 RDD 的读写，不像 MapReduce 当中每个 job 只包含一个 Map 任务和一个 Reduce 任务，下一个 Map 任务都需要等待上一个 Reduce 任务全部都结束才能执行，pipeline 形式的执行过程中没有产生 shuffle，放在一起执行明显效率更高。Stage 与 Stage 之间会出现 shuffle，这里 shuffle 也是一个常常考察的点，另外的文章会详细说明。DAGScheduler 还需要记录哪些 RDD 被存入磁盘等物化动作，同时要寻求 Task 的最优化调度，如在 Stage 内部数据的本地性等。DAGScheduler 还需要监控因为 shuffle 跨节点输出可能导致的失败，如果发现这个 Stage 失败，可能就要重新提交该 Stage。

#### DAGScheduler 具体调用过程

当一个 job 被提交时，DAGScheduler 便会开始其工作，spark 中 job 的提交是由 RDD 的 action 触发的，当发生 action 时，RDD 中的 action 方法会调用其 SparkContext 的 runJob 方法，经过多次重载之后会调用到 DAGScheduler 的 runJob 方法。 DAGScheduler 类当中 runJob 是提交 job 的入口函数，其中会调用 submitJob 方法返回一个 JobWaiter 来等待作业调度的结果，之后根据作业的成功或者失败打印相关的结果日志信息。

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8d18edda4035?imageView2/0/w/1280/h/960/format/webp/ignore-error/1) ![](https://user-gold-cdn.xitu.io/2018/10/25/166a8d23c863f998?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

submitJob 方法会获取 jobId 以及校验 partitions 是否存在，并向 eventProcessLoop 发送了一个 case class JobSubmitted 对象，JobSubmitted 对象封装了 jobId、最后一个 RDD，对 RDD 操作的函数，哪些 partition 需要被计算等内容。eventProcessLoop 当中有一个 eventThread 线程，是一个 deamon 线程，用于接收通过 post 方法发送到该线程的 JobSubmitted 对象，放入其中的一个 eventQueue 阻塞队列进行处理，从 eventQueue 中 take 出来的 event 会调用 onReceive 方法（该方法由 eventProcessLoop 实现），onReceive 方法中又会调用 doOnReceive 方法，按照不同的 event 类型进行不同的处理。 这里读源码的时候可能会有一个疑问，为何不直接在 DAGScheduler 调用 submitJob 的时候直接调用 doOnReceive 来处理 job，为何要新启一个线程来进行处理，并且自己给自己发消息进行处理（eventProcessLoop 是 DAGScheduler 内部的一个对象）。这里实际上是一个线程的异步通信方式，只是将消息以线程通信的方式 post（这里的线程通信方式实际上是用了一个阻塞队列）给另一个线程，submitJob 的方法能够立刻返回，不会阻塞在处理 event 的过程当中。这里我们不要浅显的认为 DAGScheduler 当中自己在给自己发消息，实际上还有别的组件会给 DAGScheduler 发消息，这种采用一个守护线程的方式进行消息处理可以将这两者统一起来，两者处理的逻辑都是一致的，扩展性非常好，使用消息循环器，就能统一处理所有的消息，保证处理的业务逻辑都是一致的。这里的 eventProcessLoop 实际上能够处理多种消息，不仅仅是 JobSubmitted，源码当中能看到有如下多种 event 的处理：

> 1.  JobSubmitted(jobId, rdd, func, partitions, callSite, listener, properties)
> 2.  MapStageSubmitted(jobId, dependency, callSite, listener, properties)
> 3.  StageCancelled(stageId, reason)
> 4.  JobCancelled(jobId, reason)
> 5.  JobGroupCancelled(groupId)
> 6.  AllJobsCancelled
> 7.  ExecutorAdded(execId, host)
> 8.  ExecutorLost(execId, reason)
> 9.  WorkerRemoved(workerId, host, message)
> 10.  BeginEvent(task, taskInfo)
> 11.  SpeculativeTaskSubmitted(task)
> 12.  GettingResultEvent(taskInfo)
> 13.  completion
> 14.  TaskSetFailed(taskSet, reason, exception)
> 15.  ResubmitFailedStages

JobSubmitted 会去调用 DAGScheduler 中的 handleJobSubmitted 方法，该方法是构建 Stage 的开始阶段，会创建 Stage 中的最后一个 Stage——ResultStage，而其他 Stage 为 ShuffleMapStage。ResultStage 的创建是由 createResultStage 这个函数完成的，其中的 getOrCreateParentStage 方法将会获取或创建一个给定 RDD 的父 Stages 列表，这个方法就是我们之前所说的具体划分 Stage 的方法，这个方法的源码很简单，如下：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8d02e3c97db0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

其中调用了一个函数 getShuffleDependencies 用来返回给定 RDD 的父节点中直接的 shuffle 依赖，其源码如下：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8cf96b737078?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这里有三个主要的数据结构，为两个 HashSet——parents 和 visited，还有一个 Stack——waitingForVisit，代码中首先将传入的 RDD 加入用于进行栈式访问的 waitingForVisit 中，这里使用栈我们也可以看出这是一个深度优先搜索的策略，visited 用于记录访问过的节点保证不会重复访问，接下来对访问的 RDD 的依赖进行区分，如果是 shuffleDep（即宽依赖），就将依赖加入 parents，如果是 dependency（窄依赖），则将依赖的 RDD 加入 waitingForVisit 进行深度优先搜索遍历，这里最终将返回 parents，产生的结果就是 parents 当中记录的都是 shuffleDep，即两个 Stage 之间的依赖。之后根据得到的 shuffle dependency 来调用 getOrCreateShuffleMapStage 产生 ShuffleMapStage，产生的 ShuffleMapStage 会存储在 shuffleIdToMapStage 这个 HashMap 当中，如果在该数据结构中已经存在创建过的 ShuffleMapStage 就直接返回，不存在则调用 createShuffleMapStage 进行创建，创建的时候会调用 getMissingAncestorShuffleDependencies 去搜索祖先 shuffle dependency，先将依赖的 Stage 进行创建。 Stage 创建完毕之后，handleJobSubmitted 将会调用 submitStage 来提交 finalStage，submitStage 将会递归优先提交父 Stage，父 Stage 是通过 getMissingParentStages 来获取的，并按照 Stage 的 id 进行排序，优先提交 id 小的 Stage。

#### 具体例子说明

如下图所示是 5 个 RDD 的转换图，假设 RDD E 最后出发了一个 action（比如 collect），接下来按照图中的关系仔细讲解一下 DAGScheduler 对 Stage 的生成过程。

<center>![](https://user-gold-cdn.xitu.io/2018/10/8/16651b2460a458ec?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)</center>

*   RDD.collect 方法会出发 SparkContext.runJob 方法，之后调用到 DAGScheduler.runJob 方法，继而调用 submitJob 方法将这个事件封装成 JobSubmitted 事件进行处理，调用到 handleJobSubmitted，在这个方法中会调用 createResultStage。
*   createResultStage 会基于 jobId 创建 ResultStage（ResultStage 中的 rdd 即是出发 action 的那个 RDD，即 finalRDD）。调用 getOrCreateResultStages 创建所有父 Stage，返回 parents: List[Stage] 作为父 Stage，将 parents 传入 ResultStage，实例化生成 ResultStage。在示意图中即是 RDD E 调用 createResultStage，通过 getOrCreateResultStages 获取 Stage1、Stage2，然后创建自己的 Stage3。
*   getOrCreateParentStages 方法中的 getShuffleDependencies 会获取 RDD E 的所有直接款依赖集合 RDD B 和 RDD D，然后对这两个 RDD 分别调用 getOrCreateShuffleMapStage，由于这两个 RDD 都没有父 Stage，则 getMissingAncestorShuffleDependencies 会返回为空，会创建这两个 ShuffleMapStage，最后再将这两个 Stage 作为 Stage3 的父 Stage，创建 Stage3。
*   之后会调用 handleJobSubmitted 中的 submitStage 来提交 Stage，提交的时候采用从后往前回溯的方式，优先提交前面的 Stage，并且按照 Stage 的 id 优先提交 Stage 的 id 小的，后面的 Stage 依赖于前面的 Stage，只有前面的 Stage 计算完毕才会去计算后面的 Stage。

### SchedulerBackend 和 TaskScheduler

之前讲到的 TaskScheduler 和 SchedulerBackend 都只是一个 trait，TaskScheduler 的具体实现类是 TaskSchedulerImpl，而 SchedulerBackend 的子类包括有：

> 1.  LocalSchedulerBackend
> 2.  StandaloneSchedulerBackend
> 3.  CoarseGrainedSchedulerBackend
> 4.  MesosCoarseGrainedSchedulerBackend
> 5.  YarnSchedulerBackend

不同的 SchedulerBackend 对应不同的 Spark 运行模式。传给 createTaskScheduler 不同的 master 参数就会输出不同的 SchedulerBackend，在这里 spark 实际上是根据 master 传入的字符串进行正则匹配来生成不同的 SchedulerBackend。这里采用了设计模式当中的策略模式，根据不同的需要来创建不同的 SchedulerBackend 的子类，如果使用的是本地模式，就会创建 LocalSchedulerBackend，而 standalone 集群模式则会创建 StandaloneSchedulerBackend。StandaloneSchedulerBackend 中有一个重要的方法 start，首先会调用其父类的 start 方法，之后定义了一个 Command 对象 command，其中有个对象成员 mainClass 为 org.apache.spark.executor.CoarseGrainedExecutorBackend，这个类非常重要，我们在运行 spark 应用时会在 worker 节点上看到名称为 CoarseGrainedExecutorBackend 的 JVM 进程，这里的进程就可以理解为 executor 进程，master 发指令给 worker 去启动 executor 所有的进程时加载的 Main 方法所在的入口类就是这个 CoarseGrainedExecutorBackend，在 CoarseGrainedExecutorBackend 中启动 executor，executor 通过构建线程池来并发地执行 task，然后再调用它的 run 方法。在 start 方法中还会创建一个十分重要的对象 StandaloneAppClient，会调用它的 start 方法，在该方法中会创建一个 ClientEndpoint 对象，这是一个 RpcEndPoint，会向 Master 注册。

SchedulerBackend 实际上是由 TaskScheduler 来进行管理的，createTaskScheduler 方法中都会调用 TaskScheduler 的 initialize 方法将 SchedulerBackend 作为参数输入，绑定两者的关系。

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8ce68002717f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

initialize 方法当中还会创建一个 Pool 来初始定义资源的分布模式 Scheduling Mode，默认是先进先出（FIFO）模式，还有一种支持的模式是公平（FAIR）模式。FIFO 模式指的是任务谁先提交谁就先执行，后面的任务需要等待前面的任务执行，FAIR 模式支持在调度池中为任务进行分组，不同的调度池权重不同，任务可以按照权重来决定执行的先后顺序。

TaskScheduler 的核心任务是提交 TaskSet 到集群运算运算并汇报结果。我们知道，之前所讲的 DAGScheduler 会将任务划分成一系列的 Stage，而每个 Stage 当中会封装一个 TaskSet，这些 TaskSet 会按照先后顺序提交给底层调度器 TaskScheduler 进行执行。TaskScheduler 接收的 TaskSet 是 DAGScheduler 中的 submitMissingTasks 方法传递过来的，具体调用的函数为 TaskScheduler.submitTasks，TaskScheduler 会为每一个 TaskSet 初始化一个 TaskSetManager 对其生命周期进行管理，当 TaskScheduler 得到 Worker 节点上的 Executor 计算资源的时候，TaskSetManager 便会发送具体的 Task 到 Executor 上进行执行。如果 Task 执行的过程中出现失败的情况，TaskSetManager 也会负责进行处理，会通知 DAGScheduler 结束当前的 Task，并将失败的 Task 再次添加到待执行队列当中进行后续的再次计算，重试次数默认为 4 次，处理该逻辑的方法为 TaskSetManager.handleFailedTask。Task 执行完毕，TaskSetManager 会将结果反馈给 DAGScheduler 进行后续处理。

TaskScheduler 的具体实现类为 TaskSchedulerImpl，其中有一个方法为 submitTasks 非常重要，该方法源码如下所示：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8cc8d4837aa6?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

该方法中会创建 TaskSetManager，并通过一个 HashMap 将 stage 的 id 和 TaskSetManager 进行对应管理。之后会调用 SchedulableBuilder 的 addTaskSetManager 方法将创建的 TaskSetManager 加入其中，SchedulableBuilder 会确定 TaskSetManager 的调度顺序并确定每个 Task 具体运行在哪个 ExecutorBackend 中。submitTasks 方法的最后会调用 backend.receiveOffer，该 backend 具体类型一般为 CoarseGrainedSchedulerBackend，是 SchedulerBackend 的一个子类，其 reviveOffers 方法中调用的是 driverEndPoint.send 方法，这个方法会给 DriverEndPoint 发送 ReceiveOffers 消息，会触发底层资源调度。 driverEndPoint 的 receive 方法匹配到 ReceiveOffers 消息，就调用 makeOffers 方法，该方法如下所示：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a8d66c824cdd7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

该方法会获取活动的 Executor，根据 activeExecutor 生成所有可用于计算的 workOffers，workOffers 在创建时会传入 Executor 的 id，host 和可用的 core 等信息，可用的内存信息在其他地方已经获取。makeOffers 方法中还调用了 scheduler 的 resourceOffers 方法，这个方法便是给用于计算的 workOffers 提供资源，均匀的将任务分发给每个 workOffer(Executor) 进行计算。在这里我曾经有一个疑问，就是任务是不是按顺序发给每个 Executor 进行计算的，即假设有 100 个 Task，5 个 Executor，分发任务的时候是不是总是按照 0 号 Executor、1 号 Executor、2 号 Executor…… 这样的顺序进行分发的，也就是 0 号 Executor 总是拿到 id 为 TaskId % 5 的任务，1 号 Executor 总是拿到 id 为 TaskId % 5 + 1 的任务。但阅读源码发现，其中有一个环节是进行 shuffle 操作，调用的是 Random.shuffle(offers)，即把 workOffers(Executors) 在 Seq 中的顺序进行洗牌，避免总是把任务放在同一组 worker 节点，这一点我们在后续的 resourceOfferSingleTaskSet 方法中可以很清楚的看到任务具体分发的过程其实就是按照 workerOffers 在 Seq 中的顺序进行的，在源码中就是对 workerOffers 的一个简单的 for 遍历进行读取可用的 core 资源并将可用的资源分发给 TaskSetManager 用于对应的 TaskSet 的计算：

![](https://user-gold-cdn.xitu.io/2018/10/25/166a9030d75e7bad?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

源码中按照 shuffledOffers 的索引进行顺序遍历，因为之前已经进行过 shuffle 操作，workerOffer 的顺序每次都是打乱的，所以在这里分配任务时不会总是按照一定的顺序给 workerOffer 分配对应 id 号的 Task，而是会以随机乱序的方式给 workerOffer 分配 Task，但是任务的分配还会考虑任务的本地性，在分配任务时会将对应的 Executor 资源输入给 TaskSetManager 的 resourceOffer 方法，该方法会返回需要计算的 Task 的 TaskDescription，这里很重要的一个依据就是尽量给 Executor 分配计算本地性高的任务。数据的本地优先级从高到低依次为：PROCESS_LOCAL、NODE_LOCAL、NO_PREF、RACK_LOCAL、ANY，因此对于一些任务，其数据一直处于某个节点上，因而该任务也会一直分配给该节点上的 Executor 进行计算，之前对 workerOffer 进行打乱分配的效果可能看起来就不是特别明显了，会发现一些任务一直处于某些节点上进行计算。DAGScheduler 也会有本地性的考虑，但是 DAGScheduler 是从数据的层面进行考虑的，从 RDD 的层面确定就可以，而 TaskScheduler 是从具体计算的角度考虑计算的本地性，是更具体的底层调度，满足数据本地性和计算本地性。

在 resourceOfferSingleTaskSet 方法中我们看到有一个变量 CPUS_PER_TASK，之前我一直理解的是一个 Task 是由一个 cpu core 进行执行的，但是这个变量实际上来源于配置参数 spark.task.cpus，当我们将这个参数设置为 2 时一个 Task 会被分配到 2 个 core，从 Stack Overflow 当中了解到这个参数的设置实际上是为了满足一些特殊的 Task 的需求，有些 Task 内部可能会出现多线程的情况，或者启动额外的线程进行其他交互操作，这样设置能够确保对 core 资源的总需求在按照设置的情况运行时不会超过一定的设置值（但这里并没有强制要求，如果 Task 启动的线程数大于设置的 spark.task.cpus 也不会有问题，但可能会因为超过一定的值造成资源抢占，影响效率）。

进行资源分配的 taskSet 实际上是有一定的顺序的，在 TaskSchedulerImpl.resourceOffers 方法中调用了 rootPool.getSortedTaskSetQueue 获取按照一定规则排序后的 taskSet 进行遍历处理，这里的规则就是之前所说的 FIFO 或 FAIR，指的是属于一个 Stage 的 TaskSet 的计算的优先级。resourceOffers 函数一开始也会对每一个活着的 slave 进行标记，记录其主机名并跟踪是否增加了新的 Executor，这里可能的情况是有一些 Executor 挂掉了重新启动了新的，需要在有新的 TaskSet 计算请求时加入到计算资源信息记录当中。

任务的资源分配好之后，会获得 Task 的 TaskDescription，接下来 CoarseGrainedSchedulerBackend 调用 launchTasks 方法把任务发送给对应的 ExecutorBackend 进行执行。

![](https://user-gold-cdn.xitu.io/2018/10/25/166aa25cf98aad30?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

如果任务序列化之后大小超过了 maxRpcMessageSize(默认 128M) 会丢弃，否则根据 TaskDescription 中记录的执行该 Task 的 executorId 获取 executorData，将其中的 freeCores 减去运行任务需要的 core 数，并使用 executorEndPoint 的 send 方法发送 LaunchTask 给指定的 Executor 的 ExecutorBackend 进行执行，LaunchTask 是一个 case class，其中存储的内容就是序列化的 Task。

参考文献：

*   Spark 大数据商业实战三部曲 / 王家林，段智华，夏阳编著. 北京: 清华大学出版社，2018
*   [stackoverflow.com/questions/3…](https://link.juejin.im?target=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F36671832%2Fnumber-of-cpus-per-task-in-spark)
