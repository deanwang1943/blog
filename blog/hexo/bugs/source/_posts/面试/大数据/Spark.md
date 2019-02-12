Apache Spark面试问题答案
一,什么是Apache Spark？

Apache Spark是一个功能强大的开源灵活数据处理框架，围绕速度，易用性和复杂的分析而构建.Apache Spark在集群计算系统中正在快速发展。Spark可以在Hadoop上运行，独立运行或在云中运行，并且能够访问来自各种来源的数据，包括HDFS，HBase，Cassandra或其他。

由于Spark中的集群内计算，它不需要在磁盘内外进行混洗。这样可以更快地处理spark中的数据。

与其他大数据和MapReduce技术（如Hadoop和Storm）相比，Spark具有多项优势。其中很少是：

1.Speed

它可以在内存中运行程序比Hadoop-MapReduce快100倍，在磁盘上运行速度快10倍。

2.易用性

Spark具有易于使用的API，可用于大型数据集。这包括100多个用于

转换数据的运算符和用于处理半结构化数据的熟悉数据帧API 的集合。

我们可以用Java，Scala，Python，R编写应用程序。

3. Unified Engine

Spark附带更高级别的库，包括对SQL查询，流数据，机器学习和图形处理的支持。

4.Runs Everywhere

Spark可以在Hadoop，Mesos，独立或云端运行。

Spark生态系统

以下是Spark生态系统及其组件的简要概述。

它包括：

Spark Streaming： Spark Streaming用于处理实时流数据。

Spark SQL： Spark SQL组件是一个位于Spark集群之上的库，通过使用我们可以在Spark数据上运行SQL查询。

Spark MLlib： MLlib是Spark的可扩展机器学习库。

Spark GraphX： GraphX用于图形和图形并行计算。

二.为何选择Apache Spark？

基本上，我们有很多通用的集群计算工具。例如Hadoop MapReduce，Apache Storm，Apache Impala，Apache Storm，Apache Giraph等等。但每个人的功能也有一些限制。如：

1. Hadoop MapReduce只允许批量处理。

2.如果我们谈论流处理，只有Apache Storm / S4可以执行。

3.再次进行交互式处理，我们需要Apache Impala / Apache Tez。

4.虽然我们需要执行图形处理，但我们选择Neo4j / Apache Giraph。

因此，没有一个引擎可以一起执行所有任务。因此，对强大的引擎有很大的需求，可以实时（流）和批处理模式处理数据。

此外，它可以响应亚秒级并执行内存处理

通过这种方式，Apache Spark出现了。它是一个功能强大的开源引擎，提供交互式处理，实时流处理，图形处理，内存处理以及批处理。即使速度非常快，易于使用，同时也是标准接口。

三. Apache Spark Ecosystem的组件是什么？

Apache spark由以下组件组成：

1.Spark Core

2.Spark SQL

3.Spark Streaming

4.MLlib

5.GraphX

spark streaming：spark streaming包含的基本功能spark，包括任务调度，内存管理，故障恢复成分，与存储系统交互，等等。Spark Core也是API的所在地，它定义了弹性分布式数据集（RDD），这是Spark的主要编程抽象。它还提供了许多用于构建和操作这些RDDS的API。

Spark SQL：Spark SQL提供了一个处理结构化数据的接口。它允许在SQL中查询以及SQL（HQL）的Apache Hive变体。它支持许多源。

Spark Streaming：Spark组件，可以处理实时数据流。

MLlib：Spark附带了一个名为MLlib的通用机器学习包

GraphX：GraphX是一个用于操纵图形（例如，社交网络的朋友图）和执行图形并行计算的库。

四，.什么是Spark Core？

Spark Core是整个Spark项目的基本单元。它提供了各种功能，如任务调度，调度和输入输出操作等.Spark使用称为RDD（弹性分布式数据集）的特殊数据结构。它是API的主页，用于定义和操作RDD。Spark Core是分布式执行引擎，其顶部附加了所有功能。例如，MLlib，SparkSQL，GraphX，Spark Streaming。因此，允许单一平台上的各种工作负载。Apache Spark的所有基本功能类似于内存计算，容错，内存管理，监控，任务调度由Spark Core提供。

除此之外，Spark还提供与数据源的基本连接。例如，HBase，Amazon S3，HDFS等。

五，Apache Spark支持哪些语言？

Apache Spark是用Scala语言编写的。Spark在Scala，Python和Java中提供了一个API，以便与Spark进行交互。它还提供R语言的API。

六，Apache Spark如何比Hadoop更好？

Apache Spark正在提升快速集群计算工具。由于其非常快速的内存数据分析处理能力，它比 Hadoop MapReduce快100倍。

Apache Spark是一个大数据框架。Apache Spark是一种通用数据处理引擎，通常用于HDFS之上。Apache Spark适用于从批处理到数据流的各种数据处理要求。

Hadoop是一个开源框架，用于处理存储在 HDFS中的数据。Hadoop可以处理结构化，非结构化或半结构化数据。Hadoop MapReduce只能以批处理模式处理数据。

在许多情况下，Apache Spark超过Hadoop，例如

1.处理内存中的数据，这在Hadoop中是不可能的

.2。处理批量，迭代，交互和流式传输的数据，即实时模式。而Hadoop仅以批处理模式处理。

3. Spark更快，因为它可以减少磁盘读写操作的数量，因为它可以将中间数据存储在内存中。而在Hadoop MapReduce中间输出是Map（）的输出总是写在本地硬盘

4上.Apache Spark很容易编程，因为它有数百个带RDD的高级操作符（弹性分布式数据集）

5.与Hadoop MapReduce相比，Apache Spark代码更紧凑。使用Scala使其非常简短，减少了编程工作。另外，星火提供了丰富的各种语言，比如Java，API的斯卡拉，Python和[R 。

6. Spark和Hadoop都具有高度的容错能力。

7.在Hadoop集群中运行的Spark应用程序在磁盘上的速度比Hadoop MapReduce快10倍。

七，在Apache Hadoop上运行Spark有哪些不同的方法？

而不是MapReduce，我们可以在Hadoop生态系统上使用spark -spark with HDFS 你可以在HDFS中读取和写入数据 -spark with Hive 你可以读取和分析并写回到hive

八，Apache Spark中的SparkContext是什么？

SparkContext是Spark执行环境的客户端，它充当Spark应用程序的主服务器。SparkContext设置内部服务并建立与Spark执行环境的连接。您可以在创建SparkContext之后创建RDD，累加器和广播变量，访问Spark服务并运行作业（直到SparkContext停止）。每个JVM只能激活一个SparkContext。您必须在创建新的SparkContext之前停止（）活动的SparkContext。

在Spark shell中，已经为名为sc的变量中的用户创建了一个特殊的解释器感知SparkContext。

任何Spark驱动程序应用程序的第一步是创建SparkContext。SparkContext允许Spark驱动程序应用程序通过资源管理器访问集群。资源管理器可以是YARN，也可以是Spark的Cluster Manager。

SparkContext提供的功能很少：

1。我们可以获取Spark应用程序的当前状态，例如配置，应用程序名称。

2.我们可以设置配置，如主URL，默认日志级别。

3.可以创建像RDD这样的分布式实体。

九， Apache Spark中的SparkSession是什么？

从Apache Spark 2.0开始，Spark Session是Spark应用程序的新入口点。

在2.0之前，SparkContext是spark工作的切入点。RDD是当时的主要API之一，它是使用Spark Context创建和操作的。对于每个其他API，都需要不同的上下文 - 对于SQL，需要SQL上下文; 对于Streaming，需要Streaming Context; 对于Hive，需要Hive Context。

但是从2.0开始，RDD以及DataSet及其子集DataFrame API正在成为标准API，并且是Spark中数据抽象的基本单元。所有用户定义的代码都将根据DataSet和DataFrame API以及RDD进行编写和评估。

因此，需要一个新的入口点构建来处理这些新的API，这就是引入Spark Session的原因。Spark Session还包括不同上下文中可用的所有API - Spark Context，SQL Context，Streaming Context，Hive Context。

十，Apache Spark中的SparkSession vs SparkContext。

在 Spark 2.0.0之前，sparkContext被用作访问所有spark功能的通道。

spark驱动程序使用spark context通过资源管理器（ YARN或 Mesos ..）连接到集群。

sparkConf是创建spark上下文对象所必需的，它存储配置参数，如appName（用于标识您的spark驱动程序），应用程序，核心数量以及在工作节点上运行的执行程序的内存大小。

为了使用SQL，HIVE和Streaming的 API， 需要创建单独的上下文。

示例：

创建sparkConf：

val conf = new SparkConf().setAppName(“RetailDataAnalysis”).setMaster(“spark://master:7077”).set(“spark.executor.memory”, “2g”)

creation of sparkContext:

val sc = new SparkContext(conf)

Spark会议：

从SPARK 2.0.0开始，SparkSession提供了与基础Spark功能交互的单一入口点，并

允许使用DataFrame和Dataset API 编写Spark 。sparkContext中提供的所有功能也可在sparkSession中使用。

为了使用SQL，HIVE和Streaming的API，不需要创建单独的上下文，因为sparkSession包含所有API。

一旦SparkSession被实例化，我们就可以配置Spark的运行时配置属性。

例：

创建Spark会话：

val spark = SparkSession

.builder

.appName（“

WorldBankIndex ”）。getOrCreate（）

配置属性：

spark.conf.set（“spark.sql.shuffle.partitions”，6）

spark.conf.set（“spark.executor.memory”，“2g”）

从Spark 2.0.0开始，最好使用sparkSession，因为它提供了对sparkContext所具有的所有spark功能的访问。此外，它还提供了API来处理DataFrame和数据集。

十一，Apache Spark的抽象是什么？

Apache Spark有几个抽象：

1. RDD：

RDD指的是弹性分布式数据集。RDD是记录的只读分区集合。它是Spark的核心抽象，也是Spark的基本数据结构。它提供在大型集群上进行内存计算。即使是以容错的方式。有关RDD.follow链接的更详细见解：Spark RDD - RDD的简介，功能和操作

2. DataFrames：

它是一个组织成命名列的数据集。DataFrames等同于R / Python 中的关系数据库或数据框架中的表。换句话说，我们可以说它是一个具有良好优化技术的关系表。它是一个不可变的分布式数据集合。允许更高级别的抽象，它允许开发人员将结构强加到分布式数据集合上。有关DataFrame的更详细的见解。参考链接：Spark SQL DataFrame教程 - DataFrame简介

3. Spark Streaming：

它是Spark的核心扩展，允许从多个来源进行实时流处理。例如Flume和Kafka。为了提供可用于交互式和批量查询的统一，连续的DataFrame抽象，这两个源一起工作。它提供可扩展，高吞吐量和容错处理。有关Spark Streaming的更详细的见解。参考链接：初学者的Spark Streaming教程

4. GraphX

这是专门数据抽象的又一个例子。它使开发人员能够分析社交网络。此外，其他图表与Excel类似的二维数据一起。

十二，如何在Apache Spark中创建RDD？

弹性分布式数据集（RDD）是spark的核心抽象，是一个弹性分布式数据集。

它是一个不可变（只读）的分布式对象集合。RDD中的

每个数据集被划分为逻辑分区，

其可以在集群的不同节点上计算。

包括用户定义的类，RDD可以包含任何类型的Python，Java或Scala对象。

我们可以通过3种方式在Apache Spark中创建RDD ：

1。通过分发对象集合

2.通过加载外部数据集

3.从现有的Apache Spark RDDs

1. 使用并行化集合

RDD通常通过并行化现有集合来创建，

即通过在程序中获取现有集合并将

其传递给SparkContext的 parallelize（）方法。

scala> val data = Array（1,2,3,4,5）

scala> val dataRDD = sc.parallelize（data）

scala> dataRDD.count

2. 外部数据集

在Spark中，可以从Hadoop支持的任何数据源构建分布式数据集。

val dataRDD = spark.read.textFile（“F：/BigData/DataFlair/Spark/Posts.xml”）。rdd

3. 从现有RDD创建RDD

转换是从现有RDD创建RDD的方法。

转换作为一种功能，可以吸收RDD并产生另一个结果RDD。

输入RDD不会改变，RDD上应用的

一些操作是：filter，Map，FlatMap

val dataRDD = spark.read.textFile（“F：/Mritunjay/BigData/DataFlair/Spark/Posts.xml”）。rdd

val resultRDD = data.filter {line => {line.trim（）。startsWith（“<row”）} }

十三，为什么Spark RDD不可变？

以下是原因：

- 不可变数据始终可以安全地共享多个进程以及多个线程。

- 由于RDD是不可变的，我们可以随时重新创建RDD。（来自谱系图）。

- 如果计算耗时，我们可以缓存RDD，从而提高性能。

如果我遗漏了某些东西，请添加更多分数

RDD也是容错的，并且可以懒惰地评估以获取更多信息。

十四，在Apache Spark中解释配对RDD这个术语

简介

配对RDD是具有键值对的分布式数据集合。它是Resilient Distributed Dataset的子集。因此它具有RDD的所有功能和键值对的一些新功能。配对RDD 有许多转换操作可用。配对RDD上的这些操作对于解决许多需要排序，分组，减少某些值/功能的用例非常有用。

配对RDD上常用的操作有：groupByKey（）reduceByKey（）countByKey（）join（）等

创建配对RDD：

val pRDD：[（String），（Int）] = sc.textFile（“path_of_your_file”）。

flatMap（ line => line.split（“”））。map

{word =>（word，word.length）}

同样使用subString方法（如果我们有一个带有id和某个值的文件，我们可以创建配对的rdd，id为key，value为其他细节）

val pRDD2 [（Int），（String）] = sc.textFile（“path_of_your_file”）。

keyBy（line => line.subString（1,5）.trim（）。toInt）

。mapValues（line => line.subString （10,30）.trim（））

十五，Spark中的RDD与Distributed Storage Management有何不同？

RDD和分布式存储之间的一些区别如下：

弹性分布式数据集（RDD）是Apache Spark框架的主要数据抽象。

分布式存储只是一个可在多个节点上运行的文件系统。

RDD将数据存储在内存中（除非显式缓存）。

Distributed Storage将数据存储在持久存储中。

在发生故障或数据丢失的情况下，RDD可以重新计算自身。

如果数据从分布式存储系统中丢失，它将永远消失（除非有内部复制系统）

十六，在Apache Spark中解释RDD中的转换和操作

转换是对RDD的操作，用于创建一个或多个新RDD。例如map，filter，reduceByKey等。换句话说，转换是将RDD作为输入并产生一个或多个RDD作为输出的函数。输入RDD没有变化，但它总是通过应用它们所代表的计算产生一个或多个新的RDD。变换是惰性的，即不立即执行。只有在调用动作后才会执行转换。

操作是生成非RDD值的RDD操作。换句话说，返回任何类型但RDD的值的RDD操作是一个动作。它们触发执行RDD转换以返回值。简单地说，一个动作评估RDD沿袭图。例如收集，减少，计数，foreach等。

十七，Apache Spark转换的类型有哪些？

为了更好地理解转换的类型，让我们从Apache Spark中的转换简介开始 。

Spark

Spark Transformation中的转换是一种从现有RDD生成新RDD的函数。它将RDD作为输入并生成一个或多个RDD作为输出。每当我们应用任何转换时它都会创建新的RDD。由于RDD本质上是不可变的，因此无法更改输入RDD。

RDD谱系，通过应用使用最终RDD的整个父RDD构建的转换构建。换句话说，它也被称为RDD运算符图或RDD依赖图。它是一个逻辑执行计划，即它是RDD的整个父RDD的有向无环图（DAG）。

转换本质上是懒惰的，即当我们调用一个动作时它们会被执行。它们不会立即执行。两种最基本的转换类型是map（），filter（）。

结果RDD始终与其父RDD不同。它可以更小（例如过滤，计数，不同，样本），更大（例如flatMap（），union（），Cartesian（））或相同大小（例如map）。

现在，让我们关注这个问题，基本上有两种类型的转换：

1.窄变换 -

在讨论窄变换时，在单个分区中计算记录所需的所有元素都位于父RDD的单个分区中。为了计算结果，使用有限的分区子集。此转换是map（），filter（）的结果。

2.广泛转换 -

广泛转换意味着计算单个分区中记录所需的所有元素可能存在于父RDD的许多分区中。分区可以驻留在父RDD的许多不同分区中。此转换是groupbyKey（）和reducebyKey（）的结果

十八，解释RDD属性

RDD（弹性分布式数据集）是Apache Spark中的基本抽象。
RDD是群集上不可变的，分区的元素集合，可以并行操作。
每个RDD的特点是五个主要属性：
以下操作是谱系操作。1.列表或分区集。
2.其他（父）RDD的依赖关系列表
3.计算每个分区的函数
以下操作用于执行期间的优化。
4.可选的首选位置[即HDFS文件的块位置] [它是关于数据位置]
5.可选的分区信息[即键/值对的哈希分区 - >当数据混洗时数据将如何传播]
示例：
#HadoopRDD：
HadoopRDD 使用旧版MapReduce API（org.apache.hadoop.mapred）提供读取存储在Hadoop（HDFS，HBase，Amazon S3 ..）中的数据的核心功能
HadoopRDD的属性：
1.分区列表或分区：每个HDFS块一个
2.父RDD依赖项列表：无
3.计算每个分区的功能：读取相应的HDFS块
4.可选首选位置：HDFS块位置
5.可选分区信息：没有
#FilteredRDD：
FilteredRDD的属性：
1.分区列表或分区集：与父RDD相同的分区数
2. 父RDD上的依赖项列表：作为父项的“一对一”（与父项相同）
3。计算每个分区的函数：计算父项然后过滤它
4.可选首选位置：无（询问父级）
5。可选分区信息：无
十九， Apache Spark中的血统图是什么？

在谱系图上添加更多点：

您可以使用rdd0.toDebugString检查两个RDD之间的谱系。这会返回从当前rdd到RDD之前所有依赖关系的沿袭图。见下文。每当你看到toDebugString输出中的“+ - ”符号时，就意味着从下一个操作开始就会有下一个阶段。这表示识别创建了多少个阶段。

scala> val rdd0 = sc.parallelize（List（“Ashok Vengala”，“Ashok Vengala”，“DataFlair”））

rdd0：org.apache.spark.rdd.RDD [String] = ParallelCollectionRDD [10]并行化在<console >：31

scala> val count = rdd0.flatMap（rec => rec.split（“”））。map（word =>（word，1））。reduceByKey（_ + _）

count：org.apache.spark.rdd.RDD [（String，Int）] =在<console>：33处的reduceByKey处的ShuffledRDD [13]

scala> count.toDebugString

res24：String =

（2）在<console>处的reduceByKey处的ShuffledRDD [13]：33 []

+ - （2）MapPartitionsRDD [12]在地图处<console>：33 []

| MapPartitionsRDD [11]在flatMap的<console>：33 []

| ParallelCollectionRDD [10]并行化在<console>：31 []

从下到上（即最后三行）：这些将在阶段0中执行。第一行（ShuffledRDD）：这将在第一阶段进行操作。

在toDebugString输出中，我们看到的是ParallelCollectionRDD，MapPartitionsRDD和ShuffleRDD。这些都是RDD抽象

二十，解释术语Spark Partitions和Partitioners

分区：

分区在HDFS中也称为“分裂”，是数据集的逻辑块，可以在Petabyte，Terabytes范围内并分布在群集中。
默认情况下，Spark为文件的每个块创建一个分区（对于HDFS）
HDFS块的默认块大小为64 MB（Hadoop版本1）/ 128 MB（Hadoop版本2），因此分割大小。
但是，可以明确指定要创建的分区数。
分区基本上用于加速数据处理。
分区：
定义键值对RDD中的元素如何按键分区的对象。将每个键映射到分区ID，从0到（分区数 - 1）
分区程序捕获输出处的数据分布。调度程序可以根据分区程序的类型优化将来的操作。（即如果我们执行任何操作，说需要在节点之间移动的转换或动作，我们可能需要分区器。请在论坛中引用reduceByKey（）转换）
Spark中基本上有三种类型的分区器：
（1）哈希分区程序（2）范围分区程序（3）可以制作自定义分区程序
属性名称： spark.default.parallelism
默认值：对于像reduceByKey和join这样的分布式shuffle操作，是父RDD中最大的分区数。对于没有父RDD并行化的操作，它取决于集群管理器：
•本地模式：本地计算机上的核心数量
•Mesos细粒度模式：8
•其他：所有执行程序节点上的核心总数或2，以较小者为准更大
含义：通过转换（如join）返回的RDD中的默认分区数
二十一，默认情况下，Apache Spark中的RDD中创建了多少个分区？

默认情况下，Spark为文件的每个块创建一个分区（对于HDFS）
HDFS块的默认块大小为64 MB（Hadoop版本1）/ 128 MB（Hadoop版本2）。
但是，可以明确指定要创建的分区数。
例1：
没有指定分区
val rdd1 = sc.textFile("/home/hdadmin/wc-data.txt")
例2：
以下代码创建了10个分区的RDD，因为我们指定了no。分区。
val rdd1 = sc.textFile("/home/hdadmin/wc-data.txt", 10)
可以通过以下方式查询分区数：
rdd1.partitions.length
<strong>
OR
</strong>
rdd1.getNumPartitions
最佳情况是我们应该按照以下方式制作RDD：
Cluster中的核心数量=否。分区
二十二，什么是Spark DataFrames？

DataFrame由两个单词data和frame组成，意味着数据必须适合某种帧。我们可以将框架理解为关系数据库的模式。

在Spark中，DataFrame是通过网络和一些模式的分布式数据的集合。我们可以将其理解为格式化为行/列方式的数据。可以从Hive数据，JSON文件，CSV，结构化数据或可以在结构化数据中构建框架的原始数据创建DataFrame。如果可以在该RDD上应用某些模式，我们还可以从RDD创建DataFrame 。

临时视图或表也可以从DataFrame创建，因为它具有数据和模式。我们还可以在创建的表/视图上运行SQL查询以获得更快的结果。

它也被懒惰地评估（懒惰评估）以获得更好的资源利用率。

二十三，Spark中DataFrame的好处是什么？

以下是DataFrames的优点。

1.DataFrame是分布式数据集合。在DataFrames中，数据在命名列中组织。

它们在概念上类似于关系数据库中的表。此外，还有更丰富的优化。

3. DataFrames授权SQL查询和DataFrame API。

4.我们可以通过它处理结构化和非结构化数据格式。如：Avro，CSV，弹性搜索和Cassandra。此外，它还涉及存储系统HDFS，HIVE表，MySQL等。

5.在DataFrames中，Catalyst支持优化（催化剂优化器）。有一般库可用于表示树木。在四个阶段中，DataFrame使用Catalyst树转换：

- 分析逻辑计划以解决参考

- 逻辑计划优化

- 物理规划

- 用于将查询的一部分编译为Java字节码的代码生成。

6. DataFrame API有各种编程语言版本。例如爪哇，Scala中，Python和- [R 。

7.它提供Hive兼容性。我们可以在现有的Hive仓库上运行未修改的Hive查询。

8.它可以从单个笔记本电脑上的千字节数据扩展到大型集群上的数PB数据。

9. DataFrame通过Spark核心提供与大数据工具和框架的轻松集成。

二十四，什么是Spark数据集？

甲数据集是对象的不可变集合，那些被映射到一个关系模式。它们本质上是强类型的。

数据集API的核心有一个编码器。该编码器负责在JVM对象和

表格表示之间进行转换。通过使用Spark的内部二进制格式，存储表格表示，允许对序列化数据执行操作并提高内存利用率。它还支持为各种类型自动生成编码器，包括基本类型（例如String，Integer，Long）和Scala案例类。它提供了许多功能转换 （例如map，flatMap，filter）。

二十五，数据集在spark中有哪些优点？

1）静态类型 -

使用Dataset的静态类型功能，开发人员可以在编译时捕获错误（这节省了时间和成本）。

2）运行时安全性： -

数据集 API都表示为lambda函数和JVM类型对象，

在编译时将检测到任何类型参数的不匹配。此外，使用数据集时，也可以在编译时检测分析错误，

从而节省开发人员的时间和成本。

3）性能和优化

数据集API构建于Spark SQL引擎之上，它使用Catalyst生成优化的逻辑和物理查询计划，提供空间和速度效率。

4）处理需求，如高级表达式，过滤器，地图，聚合，平均值，总和，

SQL查询，列式访问以及在半结构化数据上使用lambda函数，DataSet最好。

5）数据集提供丰富的语义，高级抽象和特定于域的API

二十六，Apache Spark中的定向非循环图是什么？

在数学术语中，有向无环图是具有不定向的循环的图。DAG是一个图表，其中包含应用于RDD的所有操作的集合。在调用任何操作时的RDD上。Spark创建DAG并将其提交给DAG调度程序。只有在构建DAG之后，Spark才会创建查询优化计划。DAG调度程序将运算符划分为任务阶段。阶段由基于输入数据的分区的任务组成。DAG调度程序将运营商连接在一起。

使用有向非循环图在Spark中实现容错。通过使用DAG，可以在Spark中进行查询优化。因此，我们通过使用DAG获得更好的性能。

二十七， Spark DAG需要什么？

在Spark中需要DAG

我们知道Hadoop MapReduce存在一些局限性。为了克服这些限制，Apache Software在Spark中引入了DAG 。让我们首先研究MapReduce的计算过程。它通常分三步进行：

1. HDFS用于读取数据。

2.之后，我们应用Map和Reduce操作。

3.再次将计算结果写回HDFS。

在Hadoop中，每个MapReduce操作都是相互独立的。甚至HADOOP也不知道接下来会有哪些Map减少。因此，有时在一些迭代中读取和写回两个map-reduce作业之间的立即结果是无关紧要的。结果，磁盘存储器或稳定存储器（HDFS）中的存储器被浪费。

当我们谈论多步骤时，所有作业从一开始就被阻止，直到完成上一个作业。因此，复杂的计算可能需要较长的时间和较小的数据量。

但是，在Spark中引入DAG之后，执行计划已经过优化，例如，最大限度地减少了混乱数据。由于形成了连续计算级的DAG（有向无环图）。

二十八，DAG和Lineage有什么区别？

为了更好地理解这些差异，我们将逐一讨论每个主题：

谱系图

我们知道，只要在RDD上执行一系列转换，就不会立即评估它们，而是懒惰（懒惰评估）。当从现有RDD创建新RDD时，该新RDD包含指向父RDD的指针。同样，RDD之间的所有依赖关系都将记录在图形中，而不是实际数据中。该图称为谱系图。

现在来到DAG，

Apache Spark中的定向非循环图（DAG）

DAG 是顶点和边缘的组合。在DAG中，顶点表示RDD，边表示要应用于RDD的操作。DAG中的每个边缘都是从一个序列中的较早到后一个。当我们调用一个Action时，创建的DAG将被提交给DAG Scheduler，后者会进一步将图形拆分为任务的各个阶段

二十九，Apache Spark中的缓存和持久性有什么区别？

Cache和Persist都是Spark计算的优化技术。

Cache是​​具有MEMORY_ONLY存储级别的Persist的同义词（即）使用Cache技术我们可以仅在需要时将中间结果保存在内存中。

Persist 使用存储级别为持久性标记RDD，存储级别可以是MEMORY，MEMORY_AND_DISK，MEMORY_ONLY_SER，MEMORY_AND_DISK_SER，DISK_ONLY，MEMORY_ONLY_2，MEMORY_AND_DISK_2

仅仅因为你可以在内存中缓存RDD并不意味着你应该盲目地这样做。根据访问数据集的次数以及执行此操作所涉及的工作量，通过增加的内存压力可以更快地重新计算。

不言而喻，如果你只读一个数据集，一旦没有缓存它，它实际上会使你的工作变慢

三十，Apache Spark有哪些限制？

现在，Apache Spark被认为是行业广泛使用的下一代Gen Big数据工具。但Apache Spark存在一定的局限性。他们是：

Apache Spark的局限性：

1.无文件管理系统

Apache Spark依赖于其他平台，如Hadoop或其他基于云的平台文件管理系统。这是Apache Spark的主要问题之一。

2.延迟

使用Apache Spark时，它具有更高的延迟。

3.不支持实时处理

在Spark Streaming中，到达的实时数据流被分成预定义间隔的批次，每批数据被视为Spark Resilient Distributed Database（RDD）。然后使用map，reduce，join等操作处理这些RDD。这些操作的结果是批量返回的。因此，它不是实时处理，但Spark接近实时数据的实时处理。微批处理在Spark Streaming中进行。

4.手动优化

手动优化是优化Spark作业所必需的。此外，它适用于特定数据集。如果我们想要在Spark中进行分区和缓存是正确的，我们需要手动控制。

少一点。算法

Spark MLlib在Tanimoto距离等许多可用算法方面落后。

6.窗口标准

Spark不支持基于记录的窗口标准。它只有基于时间的窗口标准。

7.迭代处理

在Spark中，数据分批迭代，每次迭代都是单独调度和执行的。

8.

当我们想要经济高效地处理大数据时，昂贵内存容量可能成为瓶颈，因为在内存中保存数据非常昂贵。此时内存消耗非常高，并且不以用户友好的方式处理。Spark的成本非常高，因为Apache Spark需要大量的RAM才能在内存中运行

三十一，Apache Spark的不同运行模式

我们可以用四种模式启动spark应用程序：

1）本地模式（本地[*]，本地，本地[2] ......等）

- >当您启动spark-shell而没有控制/配置参数时，它将以本地模式启动

spark-shell --master local [1 ]

- > spark-submit --class com.df.SparkWordCount SparkWC.jar local [1]

2）Spark Standalone集群管理器：

- > spark-shell --master spark：// hduser：7077

- > spark-submit --class com.df.SparkWordCount SparkWC.jar spark：// hduser：7077

3）纱线模式（客户端/群集模式）：

- > spark-shell --master yarn或

（或）

- > spark-shell --master yarn --deploy-mode client

以上两个命令都是相同的。

要在集群模式下启动spark应用程序，我们必须使用spark-submit命令。我们不能通过spark-shell运行yarn-cluster模式，因为当我们运行spark应用程序时，驱动程序将作为部件应用程序主容器/进程运行。因此无法通过spark-shell运行集群模式。

- > spark-submit --class com.df.SparkWordCount SparkWC.jar yarn-client

- > spark-submit --class com.df.SparkWordCount SparkWC.jar yarn-cluster

4）Mesos模式：

- > spark-shell --master mesos：// HOST：5050

三十二，在Spark中表示数据的不同方法有哪些？

基本上，在Apache Spark中有3种不同的方式来表示数据。要么我们可以通过RDD表示它，要么我们使用DataFrames，或者我们也可以选择DataSet来表示我们在Spark中的数据。让我们详细讨论它们中的每一个：

1. RDD

RDD指的是“弹性分布式数据集”。RDD是Apache Spark的核心抽象和基础数据结构。它是一个不可变的对象集合，可以在集群的不同节点上进行计算。我们知道RDD是不可变的，虽然我们不能对其进行任何更改，但我们可以对它们应用以下操作，如Transformation和Actions。它以容错方式对大型集群执行内存计算。基本上，有三种方法可以在Spark中创建RDD，例如 - 稳定存储中的数据，其他RDD，以及并行化驱动程序中已有的集合。按照此链接详细了解Spark RDD。

2. DataFrame

在DataFrame中，数据组织成命名列。此表与关系数据库中的表类似。DataFrames也是一个不可变的分布式数据集合。它允许开发人员将结构强加到分布式数据集合上，从而实现更高级别的抽象。请点击此链接详细了解Spark DataFrame。

3. Spark数据集API

它是DataFrame API的扩展。它提供了类型安全的，面向对象的编程接口。它利用Spark的Catalyst优化器，将数据字段和表达式公开给查询计划器。

三十三，什么是Spark中的日志写入（日志记录）？

任何Apache Spark作业中都有两种类型的故障- 驱动程序故障或工作程序故障。

当任何工作节点发生故障时，将终止在该工作节点中运行的执行程序进程，并且在该工作节点上调度的任务将自动移动到任何其他正在运行的工作节点，并且将完成任务。

当驱动程序或主节点发生故障时，运行执行程序的所有关联工作程序节点将与每个执行程序内存中的数据一起被终止。在从可靠和容错的文件系统（如HDFS）读取文件的情况下，始终保证零数据丢失，因为数据随时可以从文件系统中读取。通过定期以特定间隔保存应用程序数据，检查点还可确保Spark中的容错。

在Spark Streaming应用程序的情况下，并不总是保证零数据丢失，因为数据将被缓冲在执行程序的内存中，直到它们被处理为止。如果驱动程序失败，则所有执行程序都将被终止，其内存中的数据将无法恢复。

为了克服这种数据丢失情况，Apache Spark 1.2中引入了写入前向记录（WAL）。启用WAL后，首先在日志文件中记下操作的意图，这样如果驱动程序失败并重新启动，则该日志文件中的注释操作可以应用于数据。对于读取流数据的源，如Kafka或Flume，接收器将接收数据，这些数据将存储在执行程序的内存中。启用WAL后，这些接收的数据也将存储在日志文件中。

可以通过执行以下操作启用WAL：

1.使用streamingContext.checkpoint（path）设置检查点目录

2.通过将spark.stream.receiver.WriteAheadLog.enable设置为True来启用WAL日志记录

三十四，在Apache Spark中解释催化剂查询优化器。

pache Spark最重要的组件是Spark SQL，它处理DataFrame API和SQL查询。在Spark SQL中，有一个名为Catalyst Query Optimizer的优化器。使用此Spark创建可扩展的查询优化器。此查询优化器Spark基于Scala的函数式编程构造。

需要查询优化器：

要获得解决方案来解决Bigdata的各种问题。
作为扩展优化器的解决方案。
我们分四个阶段使用催化剂通用树转换框架工作

分析
逻辑优化。
物理规划。
代码生成。
三十五，Apache Spark中的共享变量是什么？

共享变量只不过是可以在并行操作中使用的变量。默认情况下，当Apache Spark并行运行一个函数作为不同节点上的一组任务时，它会将函数中使用的每个变量的副本发送给每个任务。有时，变量需要跨任务共享，或者在任务和驱动程序之间共享。Spark支持两种类型的共享变量：广播变量，可用于缓存所有节点的内存中的值; 累加器，它们是仅“添加”到的变量，例如计数器和总和。

三十六，Apache Spark如何处理累积的元数据？

由于随机操作，元数据在驱动程序上累积。在长期工作中变得特别乏味。

要处理累积元数据的问题，有两种选择：

首先，设置spark.cleaner.ttl参数以触发自动清理。但是，这将消除任何持久的RDD。
另一种解决方案是简单地将长时间运行的作业分成批处理并将中间结果写入磁盘。这有利于每个批次的新环境，而不必担心元数据的建立。
三十七，什么是Apache Spark Machine学习库？

Apache Spark中的机器学习库

它是一个可扩展的机器学习库，可以讨论高速和高质量的算法。

为了使机器学习可扩展且简单，创建了MLlib。有机器学习库包括各种机器学习算法的实现。例如，聚类，回归，分类和协同过滤。MLlib中也存在一些较低级别的机器学习原语，如通用梯度下降优化算法。

在Apache Spark Version 2.0中，基于RDD的API在spark中。MLlib包进入维护模式。在此版本中，基于DataFrame的API是Spark的主要机器学习API。因此，MLlib不会向基于RDD的API添加任何新功能。

基于 DataFrame的API是它比 RDD更加用户友好，因此MLlib正在切换到DataFrame API。使用DataFrames的一些好处是它包括Spark数据源， Spark SQL DataFrame查询Tungsten和 Catalyst优化，以及跨语言的统一API。这个机器学习库也使用线性代数包Breeze。Breeze是用于数值计算和机器学习的库的集合。

三十八，列出常用的机器学习算法。

基本上，有三种类型的机器学习算法：

（1）监督学习算法

（2）无监督学习算法

（3）强化学习算法

>最常用的机器学习算法如下：

（1）线性回归

（2）Logistic回归

（3）决策树

（4）K-Means

（5）KNN

（6）SVM

（7）随机森林

（8）朴素贝叶斯

（9） 降维算法

（10）梯度升压和Adaboos

三十九，DSM和RDD有什么区别？

在几个特征的基础上，RDD和DSM之间的区别是：

一世。读

RDD -在读操作RDD要么是粗粒度或细粒度。粗粒度意味着我们可以转换整个数据集，但不能转换数据集上的单个元素。虽然细粒度意味着我们可以转换数据集上的单个元素。

DSM - 分布式共享内存中的读取操作是细粒度的。

II。写

RDD - RDD中的写操作是粗粒度的。

DSM - Write操作在分布式共享系统中是细粒度的。

III。一致性

RDD - RDD的一致性是微不足道的，这意味着它本质上是不可变的。我们无法识别RDD的内容，即RDD的任何变化都是永久性的。因此，一致性水平非常高。

DSM - 系统保证如果程序员遵守规则，内存将保持一致。此外，内存操作的结果将是可预测的。

IV。故障恢复机制

RDD - 通过随时使用沿袭图，可以在Spark RDD中轻松恢复丢失的数据。因此，对于每次转换，形成新的RDD。由于RDD本质上是不可变的，因此很容易恢复。

DSM - 通过检查点技术实现容错，该技术允许应用程序回滚到最近的检查点而不是重新启动。

v。斯特拉格勒减灾

总的来说，Stragglers是那些比同龄人需要更多时间才能完成的人。这可能是由于许多原因造成的，例如负载不平衡，I / O块，垃圾收集等。

落后者的问题是当并行计算之后是同步，例如减少导致所有并行任务等待其他人。

RDD - 可以通过在RDD中使用备份任务来缓解落后者。

DSM - 实现落后缓解，非常困难。

六。行为如果没有足够的RAM

RDD - 由于没有足够的空间将RDD存储在RAM中，因此RDD会转移到磁盘。

DSM - 如果RAM用完存储，性能会降低，在这种类型的系统中

四十，列出Apache Spark中Parquet文件的优点

Parquet是Hadoop的开源文件格式。与传统方法相比，Parquet以扁平柱状格式存储嵌套数据结构，其中数据以行面向方式存储，镶木地板在存储和性能方面更有效。

柱状格式有几个优点：

1）按列进行组织可以实现更好的压缩，因为数据更加均匀。在Hadoop集群的规模上，节省的空间非常明显。

2）I / O将减少，因为我们可以在读取数据时有效地仅扫描列的子集。更好的压缩还可以减少读取输入所需的带宽。

3）当我们在每列中存储相同类型的数据时，我们可以通过使指令分支更可预测来使用更适合现代处理器管道的编码

四十一，什么是Spark的懒惰评估？

简介

延迟评估意味着在触发操作之前不会启动执行。转换本质上是懒惰的，即当我们在RDD上调用某些操作时，它不会立即执行。Spark将它们添加到DAG计算中，并且只有当驱动程序请求某些数据时，才会执行此DAG

懒惰评估的优点。

1）这是一种优化技术，即它通过减少查询数量来提供优化。

2）它节省了驱动程序和集群之间的往返，从而加快了进程

四十二， Spark懒惰评估的好处是什么？

Apache Spark使用延迟评估以获得好处：

1）对RDD应用转换操作或“将数据加载到RDD”不会立即执行，直到它看到一个动作。对RDD的转换和在RDD中存储数据进行了懒惰的评估。如果Spark使用惰性评估，将以更好的方式利用资源。

2）Spark使用延迟评估来减少通过将操作分组在一起而必须接管的数据。在MapReduce的情况下，用户/开发人员必须花费大量时间来将操作组合在一起，以便最小化MapReduce传递的数量。在spark中，编写单个复杂映射而不是将许多简单操作链接在一起没有任何好处。用户可以将他们的火花程序组织成较小的操作。通过使用延迟评估，Spark将非常有效地管理所有操作

3）延迟评估有助于优化Spark中的磁盘和内存使用。

4）一般来说，在对数据进行计算时，我们必须考虑两个方面，即空间和时间的复杂性。使用火花懒惰评估，我们可以克服两者。仅在需要数据时才会触发操作。它减少了开销。

5）它还节省了计算量并提高了速度。延迟评估将在节省计算开销方面发挥关键作用。

只计算必要的值而不是整个数据集（它全部取决于操作操作，也很少

转换）

四十三，Apache火花比Hadoop快多少？

当数据适合内存时， Apache Spark工作得更快，Spark处理内存中的数据，这使得处理速度更快，而 MapReduce在处理后将数据推送到磁盘。使用 DAG有助于进行大量优化，它可以在一个阶段中优化和进行计算，并且还可以避免不必要的减速器任务。Spark可以在内存中缓存部分或完整数据，从而避免大量磁盘I / O. 据说商业Spark比 Hadoop快100倍

四十四，通过YARN启动Apache Spark有哪些方法？

Apache Spark有两种在YARN上运行应用程序的模式：集群和客户端

spark-submit或spark-shell --master yarn-cluster或--master yarn-client

四十五。.解释Apache Spark中的各种集群管理器？

Apache Spark是一种可以在群集上以分布式模式运行的大型数据处理引擎。Spark应用程序作为集群上的独立进程集运行，所有这些都由中央协调器协调。这个中央协调器可以连接三个不同的集群管理器，Spark的Standalone，Apache Mesos和Hadoop YARN。

在群集上以分布式模式运行应用程序时，Spark使用主/从体系结构和中央协调器，也称为驱动程序

此驱动程序进程负责将用户应用程序转换为称为任务的较小执行单元。然后，这些任务由执行程序执行，执行程序是运行各个任务的工作进程。

Spark Standalone

Spark Standalone集群管理器是一个简单的集群管理器，可作为Spark发行版的一部分。它具有主服务器的HA，对工作人员故障具有弹性，具有管理每个应用程序资源的功能，并且可以与现有Hadoop部署一起运行并访问HDFS（Hadoop分布式文件系统）数据。该分发包括脚本，以便在Amazon EC2上本地或在云中轻松部署。它可以在Linux，Windows或Mac OSX上运行。

Apache Mesos

Mesos通过动态资源共享和隔离来处理分布式环境中的工作负载。在大规模集群环境中部署和管理应用程序是健康的Mesos许多物理资源都是俱乐部成为单个虚拟资源Apache Mesos的三个组件是Mesos master，Mesos slave，Frameworks。

Mesos Master是群集的一个实例。群集具有许多提供容错的Mesos主服务器。从属是Mesos实例，为群集提供资源。Mesos Framework允许应用程序从集群请求资源

YARN> / strong>

YARN数据计算框架是ResourceManager，Nodemanager的组合。

资源管理器 - 管理系统中所有应用程序之间的资源。在资源管理器具有调度器和应用程序管理器。

Scheduler将资源分配给各种正在运行的应用程序。它是纯调度程序，执行应用程序状态的监视或跟踪。

Application Manager管理所有节点上的应用程序。

纱线节点管理器包含应用程序主和容器。容器是一个工作单元发生的地方。Application Master是一个特定于框架的库。它旨在协调资源管理器中的资源。它继续使用节点管理器来执行和观察任务。

四十六，什么是Apache Spark中的推测执行？

在投机性任务在Apache的火花是验证任务推测，这意味着运行速度比成功完成任务的任务表中位数较慢的任务任务的运行速度比在job.It任务的其余部分慢是健康检查过程。这些任务被提交给另一名工人。它并行运行新副本，而不是关闭慢速任务。

在集群部署模式，线程开始为TaskSchedulerImp1 与启用spark.speculation 。它在初始spark.speculation.interval通过后定期执行每个spark.speculation.interval

四十七，.使用Apache Spark时，如何最大限度地减少数据传输？

在Spark中，可以通过避免导致数据混洗的操作来减少数据传输。

避免重新分区和合并，ByBey操作（如groupByKey和reduceByKey）以及联合操作（如cogroup和join）之类的操作。

Spark Shared Variables有助于减少数据传输。共享变量有两种类型 - 广播变量和累加器。

广播变量：

如果我们有一个大型数据集，而不是为每个任务传输数据集的副本，我们可以使用一个广播变量，该变量可以一次复制到每个节点，

并为该节点中的每个任务共享相同的数据。广播变量有助于为每个节点提供大型数据集。

首先，我们需要使用SparkContext.broadcast创建一个广播变量，然后将其广播到驱动程序的所有节点。值方法

可用于访问共享值。仅当多个阶段的任务使用相同数据时，才会使用广播变量。

累加器：

Spark函数使用驱动程序中定义的变量，并生成变量的本地复制。累加器是共享变量，有助于

在执行期间并行更新变量，并将工作者的结果共享给驱动程序。

四十八。 Apache Spark超越Hadoop的情况是什么？

我们可以比较下面区域的Hadoop和Spark：

存储
计算
计算速度
资源
与Hadoop相比，Spark的主要优势在于其计算速度.Spark具有：

闪电般快速的集群计算。
Apache Spark是一种用于大规模数据处理的快速通用引擎。
这个优点是因为RDD是火花的基本抽象。

除此之外，Spark架构和Spark执行引擎是Apache Spark与Hadoop相比速度更快的两个原因。

Hadoop是批处理的理想选择，而Spark可以进行批处理以及迭代，交互式流处理。

四十九。什么是动作，它如何在apache spark中处理数据

动作返回RDD计算/操作的最终结果。它使用沿袭图触发执行以将数据加载到原始RDD中，并执行所有中间转换并将最终结果返回给Driver程序或将其写出到文件系统。

例如：首先，take，reduce，collect，count，aggregate是spark中的一些动作。

Action会将值返回给Apache Spark驱动程序。它可能会触发先前构造的，懒惰的RDD进行评估。这是一个生成非RDD值的RDD操作。Action函数实现Spark程序中的值。所以基本上一个动作是RDD操作，它返回任何类型的值，但RDD [T]是一个动作。操作是从执行程序向驱动程序发送数据的两种方法之一（另一种是累加器）

五十，如何在Apache Spark中实现容错？

Apache Spark中容错的基本语义是，所有Spark RDD都是不可变的。它通过在DAG中创建的沿袭图表记住操作中涉及的每个RDD之间的依赖关系，并且在任何失败的情况下，Spark指的是应用相同操作来执行任务的沿袭图。

有两种类型的故障 - 工作者或驱动程序故障。如果工作程序失败，该工作节点中的执行程序将与其内存中的数据一起被终止。使用沿袭图，这些任务将在任何其他工作节点中完成。数据也会复制到其他工作节点以实现容错。有两种情况：

1. 接收和复制的数据 - 从源接收数据，并在工作节点之间复制数据。在任何故障的情况下，数据复制将有助于实现容错。

2.已接收但尚未复制的数据 - 从源接收数据但缓冲以进行复制。如果发生任何故障，则需要从源检索数据。

对于基于接收器的流输入，容错基于接收器的类型：

可靠的接收器 - 一旦接收和复制数据，就会向源发送确认。如果接收器发生故障，源将不会收到对接收数据的确认。当接收器重新启动时，源将重新发送数据以实现容错。
不可靠的接收器 - 接收的数据将不会被确认。在这种情况下，如果发生任何故障，源将不知道数据是否已被接收，并且它将不会重新发送数据，因此会丢失数据。
为了克服这种数据丢失情况，Apache Spark 1.2中引入了写入前向记录（WAL）。启用WAL后，首先在日志文件中记下操作的意图，这样如果驱动程序失败并重新启动，则该日志文件中的注释操作可以应用于数据。对于读取流数据的源，如Kafka或Flume，接收器将接收数据，这些数据将存储在执行程序的内存中。启用WAL后，这些接收的数据也将存储在日志文件中。
可以通过执行以下操作启用WAL：
使用streamingContext.checkpoint（path）设置检查点目录
通过将spark.stream.receiver.WriteAheadLog.enable设置为True来启用WAL日志记录


Apache Spark面试问题答案

一， Spark Driver在spark应用程序中的作用是什么？

Spark驱动程序是定义知识RDD的转换和操作并向主服务器提交请求的程序。Spark驱动程序是在机器的主节点上运行的程序，它声明对知识RDD的转换和操作。

简单来说，Spark中的驱动程序创建SparkContext，连接到给定的Spark Master。它将RDD图表联合提供给Master，无论独立集群管理器在哪里运行。

二， Apache Spark集群中的工作节点是什么？

Apache Spark遵循主/从架构，具有一个主或驱动程序进程以及多个从属或工作进程

1. master是运行main（）程序的驱动程序，其中创建了spark上下文。然后，它与集群管理器交互以安排作业执行并执行任务。

2.工作程序由可以并行运行的进程组成，以执行驱动程序安排的任务。这些过程称为执行程序。

每当客户端运行应用程序代码时，驱动程序都会实例化Spark Context，将转换和操作转换为执行的逻辑DAG。然后将此逻辑DAG转换为物理执行计划，然后将其细分为较小的物理执行单元。然后，驱动程序与集群管理器交互，以协商执行应用程序代码任务所需的资源。然后，集群管理器与每个工作节点交互，以了解每个节点中运行的执行程序的数量。

工作节点/执行者的角色：

1.执行应用程序代码的数据处理

2.读取数据并将数据写入外部源

3.将计算结果存储在内存或磁盘中。

执行程序在Spark应用程序的整个生命周期中运行。这是执行者的静态分配。用户还可以决定运行任务需要多少执行程序，具体取决于工作负载。这是执行者的动态分配。

在执行任务之前，执行程序通过集群管理器向驱动程序注册，以便驱动程序知道有多少执行程序正在运行以执行计划任务。然后，执行程序通过集群管理器开始执行工作节点调度的任务。

每当任何工作节点发生故障时，需要执行的任务将自动分配给任何其他工作节点

三，为什么变换在Spark中变得懒散？

每当在Apache Spark中执行转换操作时，它都会被懒惰地评估。在执行操作之前不会执行。Apache Spark只是将变换操作的条目添加到计算的DAG（有向无环图），这是一个没有循环的有向有限图。在该DAG中，所有操作都被分类到不同的阶段，在单个阶段中没有数据的混乱。

通过这种方式，Spark可以通过完整地查看DAG来优化执行，并将适当的结果返回给驱动程序。

<stronh>例如，考虑HDFS中的1TB日志文件，其中包含错误，警告和其他信息。以下是驱动程序中正在执行的操作：

1. 创建此日志文件的RDD

2.对此RDD执行flatmap（）操作，以根据制表符分隔符拆分日志文件中的数据。

3.执行filter（）操作以提取仅包含错误消息的数据

4.执行first（）操作以仅获取第一条错误消息。

如果热切评估上述驱动程序中的所有转换，那么整个日志文件将被加载到内存中，文件中的所有数据将根据选项卡进行拆分，现在要么需要在某处写入FlatMap的输出或将其保存在记忆中。Spark需要等到执行下一个操作，并且资源被阻塞以进行即将进行的操作。除此之外，每个操作spark都需要扫描所有记录，比如FlatMap处理所有记录然后再次在过滤操作中处理它们。

另一方面，如果所有转换都被懒惰地评估，Spark将整体查看DAG并为应用程序准备执行计划，现在该计划将被优化，操作将被合并/合并到阶段然后执行将开始。Spark创建的优化计划可提高作业效率和整体吞吐量。

通过Spark中的这种惰性评估，驱动程序和集群之间的切换次数也减少了，从而节省了内存中的时间和资源，并且计算速度也有所提高。

四，我可以在没有Hadoop的情况下运行Apache Spark吗？

是的，Apache Spark可以在没有Hadoop，独立或在云中运行。Spark不需要Hadoop集群就可以工作。Spark还可以读取并处理来自其他文件系统的数据。HDFS只是Spark支持的文件系统之一。

Spark没有任何存储层，因此它依赖于分布式存储系统之一，用于分布式计算，如HDFS，Cassandra等。

但是，在Hadoop（HDFS（用于存储）+ YARN（资源管理器））上运行Spark有很多优点，但这不是强制性要求。Spark是一种用于分布式计算的。在这种情况下，数据分布在计算机上，Hadoop的分布式文件系统HDFS用于存储不适合内存的数据。

使用Hadoop和Spark的另一个原因是它们都是开源的，并且与其他数据存储系统相比，它们可以相当容易地相互集成。

五，.在Spark中解释累加器。

这个讨论是继续问题，命名Apache Spark中可用的两种类型的共享变量。
累加器介绍：

Accumulator是Apache Spark中的共享变量，用于聚合群集中的信息。
换句话说，将来自工作节点的信息/值聚合回驱动程序。（我们将在下面的会议中看到）
为什么累加器：
当我们在map（），filter（）等操作中使用函数时，这些函数可以使用驱动程序中这些函数作用域外定义的变量。
当我们将任务提交到集群时，集群上运行的每个任务都会获得这些变量的新副本，并且这些变量的更新不会传播回驱动程序。
累加器降低了此限制。
用例 ：
累加器最常见的用途之一是计算作业执行期间发生的事件以进行调试。
意思是数不了。输入文件中的空白行，没有。在会话期间来自网络的错误数据包，在奥运会数据分析期间，我们必须找到我们在SQL查询中所说的年龄（年龄！='NA'），简短地查找错误/损坏的记录。
例子 ：
scala> val record = spark.read.textFile("/home/hdadmin/wc-data-blanklines.txt")
record: org.apache.spark.sql.Dataset[String] = [value: string]</p>
<p>scala> val emptylines = sc.accumulator(0)
warning: there were two deprecation warnings; re-run with -deprecation for details
emptylines: org.apache.spark.Accumulator[Int] = 0</p>
<p>scala> val processdata = record.flatMap(x =>
{
if(x == "")
emptylines += 1
x.split(" ")
})</p>
<p>processdata: org.apache.spark.sql.Dataset[String] = [value: string]
scala> processdata.collect
16/12/02 20:55:15 WARN SizeEstimator: Failed to check whether UseCompressedOops is set; assuming yes
输出：
res0：Array [String] = Array（DataFlair，提供，培训，开，切，边缘，技术。，“”，DataFlair，是，领导，培训，提供者，我们，有，训练，1000s， ，候选人，培训，焦点，实践，方面，哪些，工业，需要，而不是理论，知识。，“”，DataFlair，帮助，组织，解决，BigData，问题。， “”，Javadoc，是一个工具，用于生成API，文档，HTML，格式，文档，注释，内容，源代码，代码。，它，可以，只下载，仅作为，部分，Java，2，SDK。，To，see，documentation，generated，by，Javadoc，tool ,, go，to，J2SE，1.5.0，API，Documentation。，“”，Javadoc，常见问题解答， - ，这，常见问题，涵盖，在哪里，到，下载，Javadoc，工具，如何，到，找到，列表，已知，错误和功能，reque ...
scala> println（“空行数：”+ emptylines.value）
空行数：10
程序的解释和结论：
在上面的例子中，我们创建了一个Accumulator [Int] 'emptylines'
在这里，我们想找到没有。我们处理过程中的空白行。
之后，我们应用flatMap（）转换来处理我们的数据，但我们想要找出没有。空行（空白行）所以在flatMap（）函数中，如果我们遇到任何空行，累加器空行增加1，否则我们按空格分割行。
之后，我们检查输出和否。的空白行。
我们通过调用sc.accumulator（0）来创建具有初始值的累加器，通过调用sc.accumulator（0）即spark Context.accumulator（初始值），其中返回类型为initalValue {org.apache.spark.Accumulator [T]，其中T为initalValue]
最后，我们调用累加器上的value（）属性来访问它的值。
请注意，工作节点上的任务不能访问累加器的value属性，因此在任务的上下文中，累加器是只写变量。
accumulator的value（）属性仅在驱动程序中可用。
我们也可以算不上。在变换/动作的帮助下，我们需要一个额外的操作，但是在累加器的帮助下，我们可以计算一下。我们加载/处理数据时的空行（或更广泛的事件）。
六， Driver程序在Spark Application中的作用是什么？

驱动程序负责在集群上启动各种并行操作。
驱动程序包含应用程序的main（）函数。
它是运行用户代码的过程，用户代码又创建SparkContext对象，创建RDD并在RDD上执行转换和操作操作。
驱动程序通过SparkContext对象访问Apache Spark，该对象表示与计算集群的连接（从Spark 2.0开始，我们可以通过SparkSession访问SparkContext对象）。
驱动程序负责将用户程序转换为称为任务的物理执行单元。
它还定义了集群上的分布式数据集，我们可以对数据集（转换和操作）应用不同的操作。
Spark程序创建一个名为Directed Acyclic graph的逻辑计划，当驱动程序运行时，该计划由驱动程序转换为物理执行计划。
七，如何识别给定的操作是程序中的Transformation / Action？

为了识别操作，需要查看操作的返回类型。

如果操作在这种情况下返回一个新的RDD，则操作是“转换”
如果操作返回除RDD之外的任何其他类型，则操作为“Action”
因此，Transformation从现有RDD（前一个）构造新的RDD，而Action根据应用的转换计算结果，并将结果返回给驱动程序或将其保存到外部存储

八，命名Apache Spark中可用的两种类型的共享变量。

Apache Spark中有两种类型的共享变量：

（1）累加器：用于聚合信息。

（2）广播变量：有效地分配大值。

当我们将函数传递给Spark时，比如说filter（），这个函数可以使用在函数外部但在Driver程序中定义的变量，但是当我们将任务提交给Cluster时，每个工作节点都获得一个新的变量副本并更新从这些变量不会传播回Driver程序。

累加器和广播变量用于消除上述缺点（即我们可以将更新的值恢复到我们的驱动程序）

九，使用Apache Spark时开发人员常见的错误是什么？

1）DAG的管理- 人们经常在DAG控制中犯错误。始终尝试使用reducebykey而不是groupbykey。ReduceByKey和GroupByKey可以执行几乎相似的功能，但GroupByKey包含大数据。因此，尽量使用ReduceByKey。始终尽量减少地图的侧面。尽量不要在分区中浪费更多时间。尽量不要随便洗牌。尽量远离Skews和分区。

2）保持随机块的所需大小

十，默认情况下，Apache Spark中的RDD中创建了多少个分区？

默认情况下，Spark为文件的每个块创建一个分区（对于HDFS）
HDFS块的默认块大小为64 MB（Hadoop版本1）/ 128 MB（Hadoop版本2）。
但是，可以明确指定要创建的分区数。
例1：
没有指定分区
val rdd1 = sc.textFile("/home/hdadmin/wc-data.txt")
例2：
以下代码创建了10个分区的RDD，因为我们指定了no。分区。
val rdd1 = sc.textFile("/home/hdadmin/wc-data.txt", 10)
可以通过以下方式查询分区数：
rdd1.partitions.length
<strong>
OR
</strong>
rdd1.getNumPartitions
最佳情况是我们应该按照以下方式制作RDD：
Cluster中的核心数量=否。分区
十一，.为什么我们需要压缩以及支持的不同压缩格式是什么？

在Big Data中，当我们使用压缩时，它可以节省存储空间并减少网络开销。
可以在将数据写入HDFS时指定压缩编码（Hadoop格式）
人们也可以读取压缩数据，因为我们也可以使用压缩编解码器。
以下是BigData中不同的压缩格式支持：
* gzip
* lzo
* bzip2
* Zlib
* Snappy
十二，解释过滤器转换。

Apache Spark中的filter（）转换将函数作为输入。
它返回一个RDD，它只有通过输入函数中提到的条件的元素。
示例：
val rdd1 = sc.parallelize(List(10,20,40,60))
val rdd2 = rdd2.filter(x => x !=10)
println(rdd2.collect())
产量
10
十三，如何在交互式shell中启动和停止scala？

在Scala中启动交互式shell的命令：

>>>> bin / spark-shell

首先进入spark目录即

hdadmin@ubuntu:~$ cd spark-1.6.1-bin-hadoop2.6/

hdadmin@ubuntu:~/spark-1.6.1-bin-hadoop2.6$ bin/spark-shell

shisi

-------------------------------------------------- -------------------------------------------------- --------------------------

在Scala中停止交互式shell的命令：

scala>Press (Ctrl+D)

可以看到以下消息

scala> Stopping spark context.

十四，解释sortByKey（）操作

> sortByKey（）是一种转换。

>它返回按键排序的RDD。

>排序可以在（1）升序OR（2）降序OR（3）自定义排序中完成

从：

http：//data-flair.training/blogs/rdd-transformations-actions-apis-apache-spark/#212_SortByKey

他们将适用于范围内具有隐式排序[K]的任何键类型K. 对于所有标准基元类型，已经存在排序对象。用户还可以为自定义类型定义自己的排序，或覆盖默认排序。将使用最近范围内的隐式排序。

当调用 （K，V）数据集

（其中k为Ordered）时，返回按键按升序或降序排序的（K，V）对数据集，如升序参数中所指定。

示例：

<br />

val rdd1 = sc.parallelize(Seq(("India",91),("USA",1),("Brazil",55),("Greece",30),("China",86),("Sweden",46),("Turkey",90),("Nepal",977)))<br />

val rdd2 = rdd1.sortByKey()<br />

rdd2.collect();<br />

输出：

数组[（String，Int）] =（数组（巴西，55），（中国，86），（希腊，30），（印度，91），（尼泊尔，977），（瑞典，46），（火鸡，90），（美国，1）

<br />

val rdd1 = sc.parallelize(Seq(("India",91),("USA",1),("Brazil",55),("Greece",30),("China",86),("Sweden",46),("Turkey",90),("Nepal",977)))<br />

val rdd2 = rdd1.sortByKey(false)<br />

rdd2.collect();<br />

输出：

Array [（String，Int）] =（Array（USA，1），（Turkey，90），（Sweden，46），（Nepal，977），（India，91），（Greece，30），（中国，86），（巴西，55）

十五，解释Spark中的distnct（），union（），intersection（）和substract（）转换

union（）转换

最简单的设定操作。
rdd1.union（rdd2），它输出一个包含两个来源数据的RDD。
如果输入RDD中存在重复项，则union（）转换的输出也将包含重复项，可以使用distinct（）进行修复。
例

val u1 = sc.parallelize(List("c","c","p","m","t"))

val u2 = sc.parallelize(List("c","m","k"))

val result = u1.union(u2)

result.foreach{println}

输出：

c

c

p

m

t

c

m

k

十六，在apache spark中解释foreach（）操作

> foreach（）操作是一个动作。

>它不会返回任何值。

>它对RDD的每个元素执行输入功能。

来自：http：

//data-flair.training/blogs/rdd-transformations-actions-apis-apache-spark/#39_Foreach

它在RDD中的每个项目上执行该功能。它适用于编写数据库或发布到Web服务。它为每个数据项执行参数减少功能。

例：

val mydata = Array(1,2,3,4,5,6,7,8,9,10)

val rdd1 = sc.parallelize(mydata)

rdd1.foreach{x=>println(x)}

OR

rdd1.foreach{println}

输出：

1

2

3

4

5

6

7

8

9

10

十七，Apache Spark中的groupByKey vs reduceByKey

在对（K，V）对的数据集应用groupByKey（）时，数据根据另一个RDD中的键值K进行混洗。在这种转变中，许多不必要的数据通过网络传输。

Spark提供了将数据存储到单个执行程序机器上的数据多于内存中数据时保存到磁盘的功能。

例：

val data = spark.sparkContext.parallelize(Array(('k',5),('s',3),('s',4),('p',7),('p',5),('t',8),('k',6)),3)

val group = data.groupByKey().collect()

group.foreach(println)

在对数据集（K，V）应用reduceByKey时，在对数据进行混合之前，组合具有相同密钥的同一机器上的对。

例：

val words = Array("one","two","two","four","five","six","six","eight","nine","ten")

val data = spark.sparkContext.parallelize(words).map(w => (w,1)).reduceByKey(_+_)

data.foreach(println)

十八，.解释mapPartitions（）和mapPartitionsWithIndex（）

Mappartitions是一种类似于Map的转换。

在Map中，函数应用于RDD的每个元素，并返回结果RDD的每个其他元素。对于mapPartitions，该函数将应用于RDD的每个分区，而不是每个元素，并返回结果RDD的多个元素。在mapPartitions转换中，性能得到改善，因为在地图转换中消除了每个元素的对象创建。

由于mapPartitions转换适用于每个分区，因此它将字符串或int值的迭代器作为分区的输入。

请考虑以下示例：

val data = sc.parallelize(List(1,2,3,4,5,6,7,8), 2)

Map:

def sumfuncmap(numbers : Int) : Int =

{

var sum = 1

return sum + numbers

}

data.map(sumfuncmap).collect

returns Array[Int] = Array(2, 3, 4, 5, 6, 7, 8, 9) //Applied to each and every element

MapPartitions：

def sumfuncpartition(numbers : Iterator[Int]) : Iterator[Int] =

{

var sum = 1

while(numbers.hasNext)

{

sum = sum + numbers.next()

}

return Iterator(sum)

}

data.mapPartitions(sumfuncpartition).collect

returns

Array[Int] = Array(11, 27) // Applied to each and every element partition-wise

MapPartitionsWithIndex类似于mapPartitions，除了它还需要一个参数作为输入，它是分区的索引。

十九，Apache Spark中的Map是什么？

Map是应用于RDD中每个元素的转换，它提供了一个新的RDD作为结果。在Map转换中，用户定义的业务逻辑将应用于RDD中的所有元素。它类似于FlatMap，但与可以产生0,1或多个输出的FlatMap不同，Map只能产生一对一的输出。 映射操作将长度为N的RDD转换为另一个长度为N的RDD。

A -------> a

B -------> b

C -------> c

Map Operation

映射转换不会将数据从一个分区变为多个分区。它将使操作保持狭窄

二十，Apache Spark中的FlatMap是什么？

FlatMap是Apache Spark中的转换操作，用于从现有RDD 创建RDD。它需要RDD中的一个元素，并且可以根据业务逻辑生成0,1或多个输出。它类似于Map操作，但Map产生一对一输出。如果我们对长度为N的RDD执行Map操作，则输出RDD的长度也为N.但对于FlatMap操作，输出RDD可以根据业务逻辑的不同长度

X ------ A x ----------- a

Y ------ B y ----------- b，c

Z ----- -C z ----------- d，e，f

地图操作FlatMap操作

我们也可以说flatMap将长度为N的RDD转换为N个集合的集合，然后将其展平为单个RDD结果。

如果我们观察下面的示例data1 RDD，它是Map操作的输出，具有与数据RDD相同的元素，

但是data2 RDD没有相同数量的元素。我们还可以在这里观察data2 RDD是data1 RDD的平坦输出

pranshu @ pranshu-virtual-machine：〜$ cat pk.txt

1 2 3 4

5 6 7 8 9

10 11 12

13 14 15 16 17

18 19 20

scala> val data = sc.textFile（“/ home / pranshu / pk.txt”）

17/05/17 07:08:20 WARN SizeEstimator：无法检查是否设置了UseCompressedOops; 假设是

数据：org.apache.spark.rdd.RDD [String] = /home/pranshu/pk.txt MapPartitionsRDD [1] at textFile at <console>：24

scala> data.collect

res0：Array [String] = Array（1 2 3 4,5 6 7 8 9,10 11 12,13 14 15 16 17,18 19 20）

斯卡拉>

scala> val data1 = data.map（line => line.split（“”））

data1：org.apache.spark.rdd.RDD [Array [String]] = MapPartitionsRDD [2] at map at <console>：26

斯卡拉>

scala> val data2 = data.flatMap（line => line.split（“”））

data2：org.apache.spark.rdd.RDD [String] =在mapMap at <console>的MapPartitionsRDD [3]：26

斯卡拉>

scala> data1.collect

res1：Array [Array [String]] = Array（数组（1,2,3,4），数组（5,6,7,8,9 ），数组（10,11,12），数组（13,14,15,16,17），数组（18,19,20））

斯卡拉>

scala> data2.collect

res2：Array [String] =数组（1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18， 19,20）

二十一，在Spark中解释fold（）操作。

fold（）是一个动作。它是广泛的操作（即跨多个分区的shuffle数据并输出单个值）
它将函数作为输入，具有两个相同类型的参数，并输出单个输入类型的值。
它类似于reduce，但还有一个参数'ZERO VALUE'（比如初始值），它将在每个分区的初始调用中使用。
def fold（zeroValue：T）（op：（T，T）⇒T）：T

使用给定的关联函数和中性“零值”聚合每个分区的元素，然后聚合所有分区的结果。函数op（t1，t2）允许修改t1并将其作为结果值返回以避免对象分配; 但是，它不应该修改t2。

这与在Scala等函数式语言中为非分布式集合实现的折叠操作有所不同。该折叠操作可以单独地应用于分区，然后将这些结果折叠成最终结果，而不是以某种定义的顺序将折叠顺序地应用于每个元素。对于不可交换的函数，结果可能与应用于非分布式集合的折叠的结果不同。

zeroValue：op运算符的每个分区的累积结果的初始值，以及组合的初始值来自op运算符的不同分区 - 这通常是中性元素（例如，列表连接为Nil或0为总结）

操作：用于在分区内累积结果并组合来自不同分区的结果的运算符

示例：

val rdd1 = sc.parallelize(List(1,2,3,4,5),3)

rdd1.fold(5)(_+_)

输出：

Int = 35

val rdd1 = sc.parallelize(List(1,2,3,4,5))

rdd1.fold(5)(_+_)

输出：

Int = 25

val rdd1 = sc.parallelize(List(1,2,3,4,5),3)

rdd1.fold(3)(_+_)

Int = 27

二十二，解释API createOrReplaceTempView（）

它的基本数据集功能。
它位于org.apache.spark.sql下
def createOrReplaceTempView（viewName：String）：Unit
使用给定名称创建临时视图。
此临时视图的生命周期与用于创建此数据集的SparkSession相关联。
<br />

scala> val df = spark.read.csv("/home/hdadmin/titanic_data.txt")<br />

df: org.apache.spark.sql.DataFrame = [_c0: string, _c1: string ... 9 more fields]</p>

<p>scala> df.printSchema<br />

root<br />

|-- _c0: string (nullable = true)<br />

|-- _c1: string (nullable = true)<br />

|-- _c2: string (nullable = true)<br />

|-- _c3: string (nullable = true)<br />

|-- _c4: string (nullable = true)<br />

|-- _c5: string (nullable = true)<br />

|-- _c6: string (nullable = true)<br />

|-- _c7: string (nullable = true)<br />

|-- _c8: string (nullable = true)<br />

|-- _c9: string (nullable = true)<br />

|-- _c10: string (nullable = true)</p>

<p>scala> df.show<br />

+---+---+---+--------------------+-------+-----------+--------------------+-------+-----------------+-----+------+<br />

|_c0|_c1|_c2| _c3| _c4| _c5| _c6| _c7| _c8| _c9| _c10|<br />

+---+---+---+--------------------+-------+-----------+--------------------+-------+-----------------+-----+------+<br />

| 1|1st| 1|Allen, Miss Elisa...|29.0000|Southampton| St Louis, MO| B-5| 24160 L221| 2|female|<br />

| 2|1st| 0|Allison, Miss Hel...| 2.0000|Southampton|Montreal, PQ / Ch...| C26| null| null|female|<br />

| 3|1st| 0|Allison, Mr Hudso...|30.0000|Southampton|Montreal, PQ / Ch...| C26| null|(135)| male|<br />

| 4|1st| 0|Allison, Mrs Huds...|25.0000|Southampton|Montreal, PQ / Ch...| C26| null| null|female|<br />

| 5|1st| 1|Allison, Master H...| 0.9167|Southampton|Montreal, PQ / Ch...| C22| null| 11| male|<br />

| 6|1st| 1| Anderson, Mr Harry|47.0000|Southampton| New York, NY| E-12| null| 3| male|<br />

| 7|1st| 1|Andrews, Miss Kor...|63.0000|Southampton| Hudson, NY| D-7| 13502 L77| 10|female|<br />

| 8|1st| 0|Andrews, Mr Thoma...|39.0000|Southampton| Belfast, NI| A-36| null| null| male|<br />

| 9|1st| 1|Appleton, Mrs Edw...|58.0000|Southampton| Bayside, Queens, NY| C-101| null| 2|female|<br />

| 10|1st| 0|Artagaveytia, Mr ...|71.0000| Cherbourg| Montevideo, Uruguay| null| null| (22)| male|<br />

| 11|1st| 0|Astor, Colonel Jo...|47.0000| Cherbourg| New York, NY| null|17754 L224 10s 6d|(124)| male|<br />

| 12|1st| 1|Astor, Mrs John J...|19.0000| Cherbourg| New York, NY| null|17754 L224 10s 6d| 4|female|<br />

| 13|1st| 1|Aubert, Mrs Leont...| NA| Cherbourg| Paris, France| B-35| 17477 L69 6s| 9|female|<br />

| 14|1st| 1|Barkworth, Mr Alg...| NA|Southampton| Hessle, Yorks| A-23| null| B| male|<br />

| 15|1st| 0| Baumann, Mr John D.| NA|Southampton| New York, NY| null| null| null| male|<br />

| 16|1st| 1|Baxter, Mrs James...|50.0000| Cherbourg| Montreal, PQ|B-58/60| null| 6|female|<br />

| 17|1st| 0|Baxter, Mr Quigg ...|24.0000| Cherbourg| Montreal, PQ|B-58/60| null| null| male|<br />

| 18|1st| 0| Beattie, Mr Thomson|36.0000| Cherbourg| Winnipeg, MN| C-6| null| null| male|<br />

| 19|1st| 1|Beckwith, Mr Rich...|37.0000|Southampton| New York, NY| D-35| null| 5| male|<br />

| 20|1st| 1|Beckwith, Mrs Ric...|47.0000|Southampton| New York, NY| D-35| null| 5|female|<br />

+---+---+---+--------------------+-------+-----------+--------------------+-------+-----------------+-----+------+<br />

only showing top 20 rows</p>

<p>scala> df.createOrReplaceTempView("titanicdata")</p>

<p>

二十三，解释Apache Spark中的values（）操作

values（）是一种转换。
它仅返回值的RDD。
<br />

val rdd1 = sc.parallelize(Seq((2,4),(3,6),(4,8),(5,10),(6,12),(7,14),(8,16),(9,18),(10,20)))<br />

val rdd2 = rdd1.values<br />

rdd2.collect<br />

输出：

Array[Int] = Array(4, 6, 8, 10, 12, 14, 16, 18, 20)

示例2：数据集中的值重复

<br />

val rdd1 = sc.parallelize(Seq((2,4),(3,6),(4,8),(2,6),(4,12),(5,10),(5,40),(10,40)))<br />

val rdd2 = rdd1.keys<br />

rdd2.collect<br />

val rdd3 = rdd1.values<br />

rdd3.collect<br />

输出：

Array[Int] = Array(2, 3, 4, 2, 4, 5, 5, 10)

Array[Int] = Array(4, 6, 8, 6, 12, 10, 40, 40)

二十四，解释Apache spark中的keys（）操作。

keys（）是一种转换。
它返回一个密钥的RDD。
val rdd1 = sc.parallelize(Seq((2,4),(3,6),(4,8),(5,10),(6,12),(7,14),(8,16),(9,18),(10,20)))
val rdd2 = rdd1.keys
rdd2.collect
输出：
Array[Int] = Array(2, 3, 4, 5, 6, 7, 8, 9, 10)
示例2 :(重复键 - 数据集中存在重复键）

val rdd1 = sc.parallelize(Seq((2,4),(3,6),(4,8),(2,6),(4,12),(5,10),(5,40),(10,40)))

val rdd2 = rdd1.keys

rdd2.collect

输出：

Array[Int] = Array(2, 3, 4, 2, 4, 5, 5, 10)

二十五，在Spark中解释textFile与fullTextFile

两者都是org.apache.spark.SparkContext的方法。
文本文件（） ：
def textFile（path：String，minPartitions：Int = defaultMinPartitions）：RDD [String]
从HDFS读取文本文件，本地文件系统（在所有节点上都可用）或任何Hadoop支持的文件系统URI，并将其作为字符串的RDD返回
例如sc.textFile（“/ home / hdadmin / wc-data.txt”）因此它将创建RDD，其中每个单独的行都是一个元素。
每个人都知道textFile的用法。
wholeTextFiles（）：
def wholeTextFiles（path：String，minPartitions：Int = defaultMinPartitions）：RDD [（String，String）]
从HDFS读取文本文件目录，本地文件系统（在所有节点上都可用）或任何支持Hadoop的文件系统URI。
而不是创建基本RDD，wholeTextFile（）返回pairRDD。
例如，目录中的文件很少，因此通过使用wholeTextFile（）方法，
它创建了带有文件名的对RDD，路径为键，
值为整个文件为字符串
val myfilerdd = sc.wholeTextFiles("/home/hdadmin/MyFiles")
val keyrdd = myfilerdd.keys
keyrdd.collect
val filerdd = myfilerdd.values
filerdd.collect
输出：
Array [String] = Array（
文件：/home/hdadmin/MyFiles/JavaSparkPi.java，
文件：/home/hdadmin/MyFiles/sumnumber.txt，
文件：/home/hdadmin/MyFiles/JavaHdfsLR.java，
文件： /home/hdadmin/MyFiles/JavaPageRank.java，
文件：/home/hdadmin/MyFiles/JavaLogQuery.java，
文件：/home/hdadmin/MyFiles/wc-data.txt，
文件：/ home / hdadmin / MyFiles / nosum。文本）
Array [String] =
Array（“/ *
*根据一个或多个
*贡献者许可协议许可给Apache Software Foundation（ASF）。
有关版权所有权的其他信息，请参阅随*此工作分发的NOTICE文件。
* ASF许可此根据Apache许可证2.0版
*（“许可证”）向您提交;除非符合
*许可，否则您不得使用此文件。您可以在以下位置获取许可副本：
http://www.apache.org/licenses/LICENSE-2.0
*除非适用法律要求或书面同意，否则
根据许可证分发的软件*按“原样”分发
*，不附带任何明示或暗示的担保或条件。
*有关权限和
* 的特定语言，请参阅许可证。
二十六，解释Spark中的cogroup（）操作

>这是一个转变。

>它位于org.apache.spark.rdd.PairRDDFunctions包中

def cogroup [W1，W2，W3]（other1：RDD [（K，W1）]，other2：RDD [（K，W2）]，other3：RDD [（K，W3）]）：RDD [（K，（ Iterable [V]，Iterable [W1]，Iterable [W2]，Iterable [W3]））]

对于this或other1或other2或other3中的每个键k，返回包含元组的结果RDD，该元组具有该键，other1，other2和other3中该键的值列表。

例：

val myrdd1 = sc.parallelize(List((1,"spark"),(2,"HDFS"),(3,"Hive"),(4,"Flink"),(6,"HBase")))

val myrdd2 = sc.parallelize(List((4,"RealTime"),(5,"Kafka"),(6,"NOSQL"),(1,"stream"),(1,"MLlib")))

val result = myrdd1.cogroup(myrdd2)

result.collect

输出：

Array [（Int，（Iterable [String]，Iterable [String]））] =

Array（（4，（CompactBuffer（Flink），CompactBuffer（RealTime））），

（1，（CompactBuffer（spark），CompactBuffer（ stream，MLlib））），

（6，（CompactBuffer（HBase），CompactBuffer（NOSQL））），

（3，（CompactBuffer（Hive），CompactBuffer（））），

（5，（CompactBuffer（），CompactBuffer（Kafka） ）），

（2，（CompactBuffer（HDFS），CompactBuffer（））））

二十七，解释Apache Spark中的pipe（）操作

这是一种转变。
def pipe（command：String）：RDD [String]
将由管道元素创建的RDD返回给分叉的外部进程。
通常，Spark使用Scala，Java和Python来编写程序。但是，如果这还不够，并且想要管道（注入）用其他语言（如'R'）编写的数据，Spark会以pipe（）方式的形式提供一般机制
Spark在RDD上提供了pipe（）方法。
使用Spark的pipe（）方法，可以编写RDD的转换，可以将RDD中的每个元素从标准输入读取为String。
它可以将结果作为String写入标准输出。
二十八，.解释Spark coalesce（）操作

>这是一种转变。

>它位于org.apache.spark.rdd.ShuffledRDD包中

DEF聚结（numPartitions：中等，洗牌：布尔=假，partitionCoalescer：选项[PartitionCoalescer] = Option.empty）（隐式ORD：订购[（K，C）] = NULL）：RDD [（K，C）]

返回一个缩减为numPartitions分区的新RDD。

这会导致较窄的依赖性，例如，如果从1000个分区到100个分区，则不会进行随机播放，而是100个新分区中的每个分区将声明10个当前分区。

但是，如果你正在进行激烈的合并，例如对numPartitions = 1，这可能导致你的计算发生在比你想要的更少的节点上（例如，在numPartitions = 1的情况下，一个节点）。为避免这种情况，您可以传递shuffle = true。这将添加一个shuffle步骤，但意味着当前的上游分区将并行执行（无论当前分区是什么）。

注意：使用shuffle = true，您实际上可以合并到更大数量的分区。如果您有少量分区（例如100），这可能会使一些分区异常大，这很有用。调用coalesce（1000，shuffle = true）将导致1000个分区，并使用散列分区程序分发数据。

来自：http：

//data-flair.training/blogs/rdd-transformations-actions-apis-apache-spark/#214_Coalesce

它会更改存储数据的分区数。它将原始分区与新数量的分区相结合，因此可以减少分区数量。它是重新分区的优化版本，允许数据移动，但前提是您要减少RDD分区的数量。过滤大型数据集后，它可以更有效地运行操作。

示例：

val myrdd1 = sc.parallelize(1 to 1000, 15)

myrdd1.partitions.length

val myrdd2 = myrdd1.coalesce(5,false)

myrdd2.partitions.length

Int = 5

输出：

Int = 15

Int = 5

二十九，解释Spark中的repartition（）操作

repartition（）是一种转变。

>此函数更改参数numPartitions（numPartitions：Int）中提到的分区数

>它位于包org.apache.spark.rdd.ShuffledRDD中

def repartition（numPartitions：Int）（隐式ord：Ordering [（K，C）] = null）：RDD [（K，C）]

返回一个具有正好numPartitions分区的新RDD。

可以增加或减少此RDD中的并行度。在内部，它使用shuffle重新分配数据。

如果要减少此RDD中的分区数，请考虑使用coalesce，这可以避免执行shuffle。

来自：

http：//data-flair.training/blogs/rdd-transformations-actions-apis-apache-spark/

重新分区将重新调整RDD中的数据，以生成您请求的最终分区数。它可以减少或增加整个网络中的分区数量和数据。

示例：

val rdd1 = sc.parallelize(1 to 100, 3)

rdd1.getNumPartitions

val rdd2 = rdd1.repartition(6)

rdd2.getNumPartitions

输出：

Int = 3

Int = 6

三十，.解释Apache Spark中的fullOuterJoin（）操作

>这是转型。

>它位于org.apache.spark.rdd.PairRDDFunctions包中

def fullOuterJoin [W]（其他：RDD [（K，W）]）：RDD [（K，（Option [V]，Option [W]））]

执行此和其他的完全外部联接。

对于此中的每个元素（k，v），得到的RDD将包含所有对（k，（Some（v），Some（w）））用于其他w，

或对（k，（Some（v）） ，无）））如果其他元素没有密钥k。

类似地，对于其他元素（k，w），得到的RDD将包含所有对（k，（Some（v），Some（w）））中的v，

或者对（k，（None，一些（w）））如果其中没有元素具有密钥k。

使用现有的分区程序/并行级别对生成的RDD进行散列分区。

示例：

val frdd1 = sc.parallelize(Seq(("Spark",35),("Hive",23),("Spark",45),("HBase",89)))

val frdd2 = sc.parallelize(Seq(("Spark",74),("Flume",12),("Hive",14),("Kafka",25)))

val fullouterjoinrdd = frdd1.fullOuterJoin(frdd2)

fullouterjoinrdd.collect

输出：

Array [（String，（Option [Int]，Option [Int]））] = Array（（Spark，（Some（35），Some（74））），（Spark，（Some（45），Some（ 74））），（Kafka，（无，有些（25））），（Flume，（无，有些（12））），（Hive，（Some（23），Some（14））），（HBase， （一些（89），无）））

三十一. Expain Spark leftOuterJoin（）和rightOuterJoin（）操作

> leftOuterJoin（）和rightOuterJoin（）都是转换。

>两者都在org.apache.spark.rdd.PairRDDFunctions包中

leftOuterJoin（）：

def leftOuterJoin [W]（其他：RDD [（K，W）]）：RDD [（K，（V，Option [W]））]

执行此和其他的左外连接。对于此中的每个元素（k，v），得到的RDD将包含w中的所有对（k，（v，Some（w））），或者对（k，（v，None））如果不包含其他元素有关键k。使用现有分区程序/并行级别对输出进行散列分区。

leftOuterJoin（）在两个RDD之间执行连接，其中键必须存在于第一个RDD中

示例：

val rdd1 = sc.parallelize(Seq(("m",55),("m",56),("e",57),("e",58),("s",59),("s",54)))

val rdd2 = sc.parallelize(Seq(("m",60),("m",65),("s",61),("s",62),("h",63),("h",64)))

val leftjoinrdd = rdd1.leftOuterJoin(rdd2)

leftjoinrdd.collect

输出：

Array [（String，（Int，Option [Int]））] = Array（（s，（59，Some（61））），（s，（59，Some（62））），（s，（ 54，Some（61））），（s，（54，Some（62））），（e，（57，None）），（e，（58，None）），（m，（55，Some（ 60））），（m，（55，Some（65））），（m，（56，Some（60））），（m，（56，Some（65））））

rightOuterJoin（）：

def rightOuterJoin [W]（其他：RDD [（K，W）]）：RDD [（K，（Option [V]，W））]

执行此和其他的右外连接。对于其他元素（k，w），得到的RDD将包含所有对（k，（Some（v），w））的v，或者对（k，（None，w））如果没有其中的元素有关键k。使用现有的分区程序/并行级别对生成的RDD进行散列分区。

它执行两个RDD之间的连接，其中密钥必须存在于其他RDD中

例：

val rdd1 = sc.parallelize(Seq(("m",55),("m",56),("e",57),("e",58),("s",59),("s",54)))

val rdd2 = sc.parallelize(Seq(("m",60),("m",65),("s",61),("s",62),("h",63),("h",64)))

val rightjoinrdd = rdd1.rightOuterJoin(rdd2)

rightjoinrdd.collect

Array [（String，（Option [Int]，Int））] = Array（（s，（Some（59），61）），（s，（Some（59），62）），（s，（Some（（ 54），61）），（s，（Some（54），62）），（h，（None，63）），（h，（None，64）），（m，（Some（55），60 ）），（m，（Some（55），65）），（m，（Some（56），60）），（m，（Some（56），65）））

三十二，解释Spark join（）操作

> join（）是转型。

>它在包org.apache.spark.rdd.pairRDDFunction

def join [W]（其他：RDD [（K，W）]）：RDD [（K，（V，W））]固定链接

返回包含所有元素对的RDD，其中包含匹配键和其他元素。

每对元素将作为（k，（v1，v2））元组返回，其中（k，v1）在此，而（k，v2）在其他元素中。在整个群集中执行散列连接。

它正在连接两个数据集。当调用类型（K，V）和（K，W）的数据集时，返回（K，（V，W））对的数据集以及每个键的所有元素对。通过leftOuterJoin，rightOuterJoin和fullOuterJoin支持外连接。

例1：

val rdd1 = sc.parallelize(Seq(("m",55),("m",56),("e",57),("e",58),("s",59),("s",54)))

val rdd2 = sc.parallelize(Seq(("m",60),("m",65),("s",61),("s",62),("h",63),("h",64)))

val joinrdd = rdd1.join(rdd2)

joinrdd.collect

输出：

Array [（String，（Int，Int））] = Array（（m，（54,60）），（m，（54,65）），（m，（56,60）），（m，（56 ，65）），（s，（59,61）），（s，（59,62）），（s，（54,61）），（s，（54,62）））

例2：

val myrdd1 = sc.parallelize(Seq((1,2),(3,4),(3,6)))

val myrdd2 = sc.parallelize(Seq((3,9)))

val myjoinedrdd = myrdd1.join(myrdd2)

myjoinedrdd.collect

输出：

数组[（Int，（Int，Int））] =数组（（3，（4,9）），（3，（6,9）））

三十三，解释top（）和takeOrdered（）操作

top（）和takeOrdered（）都是动作。
两者都返回基于默认排序或基于用户提供的自定义排序的RDD元素。
def top(num: Int)(implicit ord: Ordering[T]): Array[T]
返回此RDD中的前k个（最大）元素，由指定的隐式Ordering [T]定义并维护排序。这与takeOrdered相反。
def takeOrdered(num: Int)(implicit ord: Ordering[T]): Array[T]
返回此RDD中的第一个k（最小）元素，由指定的隐式Ordering [T]定义并维护排序。这与top相反。
示例：
val myrdd1 = sc.parallelize(List(5,7,9,13,51,89))
myrdd1.top(3)
myrdd1.takeOrdered(3)
myrdd1.top(3)
输出：
Array[Int] = Array(89, 51, 13)
Array[Int] = Array(5, 7, 9)
Array[Int] = Array(89, 51, 13)
三十四，解释Spark中的first（）操作

>这是一个动作。

>它返回RDD的第一个元素。

示例：

val rdd1 = sc.textFile("/home/hdadmin/wc-data.txt")

rdd1.count

rdd1.first

输出：

长：20

字符串：DataFlair是领先的技术培训提供商

三十五，.解释Apache Spark中的sum（），max（），min（）操作

sum（）：

>它将RDD中的值相加。

>它是一个包org.apache.spark.rdd.DoubleRDDFunctions。

>它的返回类型是Double

例：

val rdd1 = sc.parallelize(1 to 20)

rdd1.sum

输出：

Double = 210.0

max（）：

>它从隐式排序（元素顺序）定义的RDD元素返回一个最大值

>它是一个包org.apache.spark.rdd

例：

val rdd1 = sc.parallelize(List(1,5,9,0,23,56,99,87))

rdd1.max

输出：

Int = 99

min（）：

>它从隐式排序（元素顺序）定义的RDD元素返回一个min值

>它是一个包org.apache.spark.rdd

例：

val rdd1 = sc.parallelize(List(1,5,9,0,23,56,99,87))

rdd1.min

输出：

Int = 0

三十六，.解释Apache Spark RDD中的countByValue（）操作

这是一个动作
它返回RDD中每个唯一值的计数作为本地Map（作为Map to driver program）（value，countofvalues）对
必须小心使用此API，因为它将值返回给驱动程序，因此它仅适用于较小的值。
例：
val rdd1 = sc.parallelize(Seq(("HR",5),("RD",4),("ADMIN",5),("SALES",4),("SER",6),("MAN",8)))
rdd1.countByValue
输出：
scala.collection.Map [（String，Int），Long] = Map（（HR，5） - > 1，（RD，4） - > 1，（SALES，4） - > 1，（ADMIN，5 ） - > 1，（MAN，8） - > 1，（SER，6） - > 1）
val rdd2 = sc.parallelize{Seq(10,4,3,3)}
rdd2.countByValue
输出：
scala.collection.Map [Int，Long] = Map（4 - > 1,3 - > 2,10 - > 1）
三十七，.解释Spark中的lookup（）操作

>这是一个动作

>它返回RDD中键值'key'的值列表

val rdd1 = sc.parallelize(Seq(("Spark",78),("Hive",95),("spark",15),("HBase",25),("spark",39),("BigData",78),("spark",49)))

rdd1.lookup("spark")

rdd1.lookup("Hive")

rdd1.lookup("BigData")

输出：

Seq [Int] = WrappedArray（15,39,49）

Seq [Int] = WrappedArray（95）

Seq [Int] = WrappedArray（78）

三十八，解释Spark countByKey（）操作

>它是一个动作操作

>返回（key，noofkeycount）对。

它计算RDD的值，该值由每个不同键的两个组件元组组成。它实际上计算每个键的元素数，并将结果作为（键，计数）对的列表返回给主键。

val rdd1 = sc.parallelize(Seq(("Spark",78),("Hive",95),("spark",15),("HBase",25),("spark",39),("BigData",78),("spark",49)))

rdd1.countByKey

输出：

scala.collection.Map [String，Long] = Map（Hive - > 1，BigData - > 1，HBase - > 1，spark - > 3，Spark - > 1）

三十九，解释Spark saveAsTextFile（）操作

它将RDD的内容写入文本文件，或使用字符串表示将RDD保存为文件路径目录中的文本文件。

四十，解释reduceByKey（）Spark操作

> reduceByKey（）是对pairRDD（包含Key / Value）进行转换的转换。

> PairRDD包含元组，因此我们需要传递元组上的运算符而不是每个元素。

>它使用关联reduce函数将值与相同的键合并。

>它是广泛的操作，因为数据混洗可能发生在多个分区上。

>它在跨分区发送数据之前在本地合并数据，以优化数据混洗。

>它将函数作为一个输入，它有两个相同类型的参数（与同一个键相关的值）和一个输入类型的元素输出（值）

>我们可以说它有三个重载函数：

reduceBykey（function）

reduceByKey（功能，分配数量）

reduceBykey（partitioner，function）

它使用关联reduce函数，它合并每个键的值。它只能与键值对中的Rdd一起使用。它是一种广泛的操作，可以从多个分区/分区中混洗数据并创建另一个RDD。它使用关联函数在本地合并数据，以优化数据混洗。组合的结果（例如，和）与值的类型相同，并且当从不同分区组合时的操作也与在分区内组合值时的操作相同。

示例：

val rdd1 = sc.parallelize(Seq(5,10),(5,15),(4,8),(4,12),(5,20),(10,50)))

val rdd2 = rdd1.reduceByKey((x,y)=>x+y)

OR

rdd2.collect()

输出：

数组[（Int，Int）] =数组（（4,20），（10,50），（5,45）

四十一，解释Spark中的reduce（）操作

> reduce（）是一个动作。它是宽操作（即跨越多个分区的随机数据并输出单个值）

>它将函数作为具有两个相同类型参数的输入，并输出单个输入类型的值。

>即将RDD的元素组合在一起。

示例1：

val rdd1 = sc.parallelize（1到100）

val rdd2 = rdd1.reduce（（x，y）=> x + y）

OR

val rdd2 = rdd1.reduce（_ + _）

输出：

rdd2：Int = 5050

示例2：

val rdd1 = sc.parallelize（1到5）

val rdd2 = rdd1.reduce（_ * _）

输出：

rdd2：Int = 120

四十二，在Spark RDD中解释动作count（）

count（）是Apache Spark RDD操作中的一个操作
count（）返回RDD中的元素数。
示例：
val rdd1 = sc.parallelize（List（10,20,30,40））
println（rdd1.count（））
输出：
4
它返回RDD中的多个元素或项目。因此，它基本上计算数据集中存在的项目数，并在计数后返回一个数字。
四十三.解释Spark map（）转换

> map（）转换将函数作为输入，并将该函数应用于RDD中的每个元素。

>函数的输出将是每个输入元素的新元素（值）。

防爆。

val rdd1 = sc.parallelize（List（10,20,30,40））

val rdd2 = rdd1.map（x => x * x）

println（rdd2.collect（）。mkString（“，”））

四十四，解释Apache Spark中的flatMap（）转换

当想要为每个输入元素生成多个元素（值）时，使用flatMap（）。
与map（）一样，flatMap（）也将函数作为输入。
函数的输出是我们可以迭代的元素的List。（即函数可以为每个输入元素返回0或更多元素）
简单地使用flatMap（）将输入行（字符串）拆分为单词。
例

val fm1 = sc.parallelize(List("Good Morning", "Data Flair", "Spark Batch"))

val fm2 = fm1.flatMap(y => y.split(" "))

fm2.foreach{println}

输出如下：

Good

Morning

Data

Flair

Spark

Batch

四十五，Apache Spark有哪些限制？

在，Apache Spark被认为是行业广泛使用的下一代Gen Big数据工具。但Apache Spark存在一定的局限性。他们是：

Apache Spark的局限性：

1.无文件管理系统

Apache Spark依赖于其他平台，如Hadoop或其他基于云的平台文件管理系统。这是Apache Spark的主要问题之一。

2.延迟

使用Apache Spark时，它具有更高的延迟。

3.不支持实时处理

在Spark Streaming中，到达的实时数据流被分成预定义间隔的批次，每批数据被视为Spark Resilient Distributed Database（RDD）。然后使用map，reduce，join等操作处理这些RDD。这些操作的结果是批量返回的。因此，它不是实时处理，但Spark接近实时数据的实时处理。微批处理在Spark Streaming中进行。

4.手动优化

手动优化是优化Spark作业所必需的。此外，它适用于特定数据集。如果我们想要在Spark中进行分区和缓存是正确的，我们需要手动控制。

少一点。算法

Spark MLlib在Tanimoto距离等许多可用算法方面落后。

6.窗口标准

Spark不支持基于记录的窗口标准。它只有基于时间的窗口标准。

7.迭代处理

在Spark中，数据分批迭代，每次迭代都是单独调度和执行的。

8.

当我们想要经济高效地处理大数据时，昂贵内存容量可能成为瓶颈，因为在内存中保存数据非常昂贵。此时内存消耗非常高，并且不以用户友好的方式处理。Spark的成本非常高，因为Apache Spark需要大量的RAM才能在内存中运行。

四十六，什么是Spark SQL？

Spark SQL是一个Spark接口，用于处理结构化和半结构化数据（定义字段即表格的数据）。它提供了一个名为DataFrame和DataSet的抽象层，我们可以轻松处理数据。可以说DataFrame就像关系数据库中的表。Spark SQL可以以Parquets，JSON，Hive等各种结构化和半结构化格式读写数据。在Spark应用程序中使用SparkSQL是使用它的最佳方式。这使我们能够加载数据并使用SQL进行查询。我们也可以将它与Python，Java或Scala中的 “常规”程序代码结合起来。

四十七，解释Spark SQL缓存和解除

当我们尝试在另一个用户使用该表时解冻Spark SQL中的表时会发生什么？因为我们可以在Spark SQL JDBC服务器中的多个用户之间使用共享缓存表。

四十八，解释Spark流媒体

rk Streaming

数据流定义为以无界序列的形式连续到达的数据。为了进一步处理，Streaming将连续流动的输入数据分离为离散单元。它是一种低延迟处理和分析流数据。

在2013年，Apache Spark Streaming被添加到Apache Spark。通过Streaming，我们可以对实时数据流进行容错，可扩展的流处理。从许多来源，如Kafka，Apache Flume，Amazon Kinesis或TCP套接字，可以进行数据摄取。此外，通过使用复杂算法，可以进行处理。用高级函数表示，例如map，reduce，join和window。最后，处理后的数据可以推送到文件系统，数据库和实时仪表板。

在内部，通过Spark流，接收实时输入数据流并将其分成批次。然后，这些批次由Spark引擎处理，以批量生成最终结果流。

Discretized Stream或简称Spark DStream是它的基本抽象。这也代表了分成小批量的数据流。DStreams构建于Spark的核心数据抽象Spark RDD之上。Streaming可以与Spark MLlib和Spark SQL等任何其他Apache Spark组件集成。

四十九，解释Spark Streaming

Spark Streaming

数据流定义为以无界序列的形式连续到达的数据。为了进一步处理，Streaming将连续流动的输入数据分离为离散单元。它是一种低延迟处理和分析流数据。

在2013年，Apache Spark Streaming被添加到Apache Spark。通过Streaming，我们可以对实时数据流进行容错，可扩展的流处理。从许多来源，如Kafka，Apache Flume，Amazon Kinesis或TCP套接字，可以进行数据摄取。此外，通过使用复杂算法，可以进行处理。用高级函数表示，例如map，reduce，join和window。最后，处理后的数据可以推送到文件系统，数据库和实时仪表板。

在内部，通过Spark流，接收实时输入数据流并将其分成批次。然后，这些批次由Spark引擎处理，以批量生成最终结果流。

Discretized Stream或简称Spark DStream是它的基本抽象。这也代表了分成小批量的数据流。DStreams构建于Spark的核心数据抽象Spark RDD之上。Streaming可以与Spark MLlib和Spark SQL等任何其他Apache Spark组件集成。

五十，在Apache Spark Streaming中解释DStream中的不同转换

Apache Spark Streaming中DStream中的不同转换是：

1- map（func） - 通过函数func传递源DStream的每个元素来返回一个新的DStream。

2- flatMap（func） - 与map类似，但每个输入项可以映射到0个或更多输出项。

3- filter（func） - 通过仅选择func返回true的源DStream的记录来返回新的DStream。

4- repartition（numPartitions） - 通过创建更多或更少的分区来更改此DStream中的并行度级别。

5- union（otherStream） - 返回一个新的DStream，它包含源DStream和

otherDStream中元素的并集。

6- 计数（） -返回单元素的一个新的DSTREAM RDDS通过计数在源DSTREAM的每个RDD元件的数量。

7- reduce（func） - 通过使用函数func（它接受两个参数并返回一个）聚合源DStream的每个RDD中的元素，返回单元素RDD的新DStream。

8- countByValue（） - 当在类型为K的元素的DStream上调用时，返回（K，Long）对的新DStream，其中每个键的值是其在源DStream的每个RDD中的频率。

9- reduceByKey（func，[numTasks]） - 当在（K，V）对的DStream上调用时，返回一个（K，V）对的新DStream，其中使用给定的reduce函数聚合每个键的值。

10- join（otherStream，[numTasks]） - 当在（K，V）和（K，W）对的两个DStream上调用时，返回一个新的DStream（K，（V，W））对与所有对每个键的元素。

11- cogroup（otherStream，[numTasks]） - 当在（K，V）和（K，W）对的DStream上调用时，返回（K，Seq [V]，Seq [W]）元组的新DStream。

12- transform（func） - 通过将RDD-to-RDD函数应用于源DStream的每个RDD来返回一个新的DStream。

13- updateStateByKey（func） - 返回一个新的“状态”DStream，其中通过在密钥的先前状态和密钥的新值上应用给定函数来更新每个密钥的状态。
