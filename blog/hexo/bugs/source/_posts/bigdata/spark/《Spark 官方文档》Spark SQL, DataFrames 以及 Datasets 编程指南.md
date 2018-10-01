---
title: 《Spark 官方文档》Spark SQL, DataFrames 以及 Datasets 编程指南
date: 2018-09-27 08:36:03
tags:
  - spark
  - 大数据
categories:
  - 大数据
---
> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 http://ifeve.com/spark-sql-dataframes/ spark-1.6.0 [[原文地址]](http://spark.apache.org/docs/latest/sql-programming-guide.html)

## Spark SQL, DataFrames 以及 Datasets 编程指南

# 概要

Spark SQL 是 Spark 中处理结构化数据的模块。与基础的 Spark RDD API 不同，Spark SQL 的接口提供了更多关于数据的结构信息和计算任务的运行时信息。在 Spark 内部，Spark SQL 会能够用于做优化的信息比 RDD API 更多一些。Spark SQL 如今有了三种不同的 API：SQL 语句、DataFrame API 和最新的 Dataset API。不过真正运行计算的时候，无论你使用哪种 API 或语言，Spark SQL 使用的执行引擎都是同一个。这种底层的统一，使开发者可以在不同的 API 之间来回切换，你可以选择一种最自然的方式，来表达你的需求。

本文中所有的示例都使用 Spark 发布版本中自带的示例数据，并且可以在 spark-shell、pyspark shell 以及 sparkR shell 中运行。

## SQL

Spark SQL 的一种用法是直接执行 SQL 查询语句，你可使用最基本的 SQL 语法，也可以选择 HiveQL 语法。Spark SQL 可以从已有的 Hive 中读取数据。更详细的请参考 [Hive Tables](http://spark.apache.org/docs/latest/sql-programming-guide.html#hive-tables) 这一节。如果用其他编程语言运行 SQL，Spark SQL 将以 [DataFrame](http://spark.apache.org/docs/latest/sql-programming-guide.html#DataFrames) 返回结果。你还可以通过命令行 [command-line](http://spark.apache.org/docs/latest/sql-programming-guide.html#running-the-spark-sql-cli) 或者 [JDBC/ODBC](http://spark.apache.org/docs/latest/sql-programming-guide.html#running-the-thrift-jdbcodbc-server) 使用 Spark SQL。

## DataFrames

DataFrame 是一种分布式数据集合，每一条数据都由几个命名字段组成。概念上来说，她和关系型数据库的表 或者 R 和 Python 中的 data frame 等价，只不过在底层，DataFrame 采用了更多优化。DataFrame 可以从很多数据源（[sources](http://spark.apache.org/docs/latest/sql-programming-guide.html#data-sources)）加载数据并构造得到，如：结构化数据文件，Hive 中的表，外部数据库，或者已有的 RDD。

DataFrame API 支持 [Scala](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame), [Java](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/DataFrame.html), [Python](http://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrame), and [R](http://spark.apache.org/docs/latest/api/R/index.html)。

## Datasets

Dataset 是 Spark-1.6 新增的一种 API，目前还是实验性的。Dataset 想要把 RDD 的优势（强类型，可以使用 lambda 表达式函数）和 Spark SQL 的优化执行引擎的优势结合到一起。Dataset 可以由 JVM 对象构建（[constructed](http://spark.apache.org/docs/latest/sql-programming-guide.html#creating-datasets) ）得到，而后 Dataset 上可以使用各种 transformation 算子（map，flatMap，filter 等）。

Dataset API 对 [Scala](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.Dataset) 和 [Java](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html) 的支持接口是一致的，但目前还不支持 Python，不过 Python 自身就有语言动态特性优势（例如，你可以使用字段名来访问数据，row.columnName）。对 Python 的完整支持在未来的版本会增加进来。

# 入门

## 入口：SQLContext

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_0)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_0)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_0)
*   **[R](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_0)**

Spark SQL 所有的功能入口都是 [`SQLContext`](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.SQLContext) 类，及其子类。不过要创建一个 SQLContext 对象，首先需要有一个 SparkContext 对象。

```
val sc: SparkContext // 假设已经有一个 SparkContext 对象
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// 用于包含RDD到DataFrame隐式转换操作
import sqlContext.implicits._
```

除了 SQLContext 之外，你也可以创建 HiveContext，HiveContext 是 SQLContext 的超集。

除了 SQLContext 的功能之外，HiveContext 还提供了完整的 HiveQL 语法，UDF 使用，以及对 Hive 表中数据的访问。要使用 HiveContext，你并不需要安装 Hive，而且 SQLContext 能用的数据源，HiveContext 也一样能用。HiveContext 是单独打包的，从而避免了在默认的 Spark 发布版本中包含所有的 Hive 依赖。如果这些依赖对你来说不是问题（不会造成依赖冲突等），建议你在 Spark-1.3 之前使用 HiveContext。而后续的 Spark 版本，将会逐渐把 SQLContext 升级到和 HiveContext 功能差不多的状态。

spark.sql.dialect 选项可以指定不同的 SQL 变种（或者叫 SQL 方言）。这个参数可以在 SparkContext.setConf 里指定，也可以通过 SQL 语句的 SET key=value 命令指定。对于 SQLContext，该配置目前唯一的可选值就是”sql”，这个变种使用一个 Spark SQL 自带的简易 SQL 解析器。而对于 HiveContext，spark.sql.dialect 默认值为”hiveql”，当然你也可以将其值设回”sql”。仅就目前而言，HiveSQL 解析器支持更加完整的 SQL 语法，所以大部分情况下，推荐使用 HiveContext。

## 创建 DataFrame

Spark 应用可以用 SparkContext 创建 DataFrame，所需的数据来源可以是已有的 RDD（[existing `RDD`](http://spark.apache.org/docs/latest/sql-programming-guide.html#interoperating-with-rdds)），或者 Hive 表，或者其他数据源（[data sources](http://spark.apache.org/docs/latest/sql-programming-guide.html#data-sources).）

以下是一个从 JSON 文件创建 DataFrame 的小栗子：

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_1)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_1)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_1)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_1)

```
val sc: SparkContext // 已有的 SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df = sqlContext.read.json("examples/src/main/resources/people.json")

// 将DataFrame内容打印到stdout
df.show()
```

## DataFrame 操作

DataFrame 提供了结构化数据的领域专用语言支持，包括 [Scala](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame), [Java](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/DataFrame.html), [Python](http://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrame) and [R](http://spark.apache.org/docs/latest/api/R/DataFrame.html).

这里我们给出一个结构化数据处理的基本示例：

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_2)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_2)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_2)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_2)

```
val sc: SparkContext // 已有的 SparkContext.
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// 创建一个 DataFrame
val df = sqlContext.read.json("examples/src/main/resources/people.json")

// 展示 DataFrame 的内容
df.show()
// age  name
// null Michael
// 30   Andy
// 19   Justin

// 打印数据树形结构
df.printSchema()
// root
// |-- age: long (nullable = true)
// |-- name: string (nullable = true)

// select "name" 字段
df.select("name").show()
// name
// Michael
// Andy
// Justin

// 展示所有人，但所有人的 age 都加1
df.select(df("name"), df("age") + 1).show()
// name    (age + 1)
// Michael null
// Andy    31
// Justin  20

// 筛选出年龄大于21的人
df.filter(df("age") > 21).show()
// age name
// 30  Andy

// 计算各个年龄的人数
df.groupBy("age").count().show()
// age  count
// null 1
// 19   1
// 30   1
```

DataFrame 的完整 API 列表请参考这里：[API Documentation](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrame)

除了简单的字段引用和表达式支持之外，DataFrame 还提供了丰富的工具函数库，包括字符串组装，日期处理，常见的数学函数等。完整列表见这里：[DataFrame Function Reference](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.functions$).

## 编程方式执行 SQL 查询

SQLContext.sql 可以执行一个 SQL 查询，并返回 DataFrame 结果。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_3)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_3)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_3)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_3)

```
val sqlContext = ... // 已有一个 SQLContext 对象
val df = sqlContext.sql("SELECT * FROM table")
```

## 创建 Dataset

Dataset API 和 RDD 类似，不过 Dataset 不使用 Java 序列化或者 Kryo，而是使用专用的编码器（[Encoder](http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.Encoder) ）来序列化对象和跨网络传输通信。如果这个编码器和标准序列化都能把对象转字节，那么编码器就可以根据代码动态生成，并使用一种特殊数据格式，这种格式下的对象不需要反序列化回来，就能允许 Spark 进行操作，如过滤、排序、哈希等。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_4)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_4)

```
// 对普通类型数据的Encoder是由 importing sqlContext.implicits._ 自动提供的
val ds = Seq(1, 2, 3).toDS()
ds.map(_ + 1).collect() // 返回: Array(2, 3, 4)

// 以下这行不仅定义了case class，同时也自动为其创建了Encoder
case class Person(name: String, age: Long)
val ds = Seq(Person("Andy", 32)).toDS()

// DataFrame 只需提供一个和数据schema对应的class即可转换为 Dataset。Spark会根据字段名进行映射。
val path = "examples/src/main/resources/people.json"
val people = sqlContext.read.json(path).as[Person]
```

## 和 RDD 互操作

Spark SQL 有两种方法将 RDD 转为 DataFrame。

1\. 使用反射机制，推导包含指定类型对象 RDD 的 schema。这种基于反射机制的方法使代码更简洁，而且如果你事先知道数据 schema，推荐使用这种方式；

2\. 编程方式构建一个 schema，然后应用到指定 RDD 上。这种方式更啰嗦，但如果你事先不知道数据有哪些字段，或者数据 schema 是运行时读取进来的，那么你很可能需要用这种方式。

### 利用反射推导 schema

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_5)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_5)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_5)

Spark SQL 的 Scala 接口支持自动将包含 case class 对象的 RDD 转为 DataFrame。对应的 case class 定义了表的 schema。case class 的参数名通过反射，映射为表的字段名。case class 还可以嵌套一些复杂类型，如 Seq 和 Array。RDD 隐式转换成 DataFrame 后，可以进一步注册成表。随后，你就可以对表中数据使用 SQL 语句查询了。

```
// sc 是已有的 SparkContext 对象
val sqlContext = new org.apache.spark.sql.SQLContext(sc)
// 为了支持RDD到DataFrame的隐式转换
import sqlContext.implicits._

// 定义一个case class.
// 注意：Scala 2.10的case class最多支持22个字段，要绕过这一限制，
// 你可以使用自定义class，并实现Product接口。当然，你也可以改用编程方式定义schema
case class Person(name: String, age: Int)

// 创建一个包含Person对象的RDD，并将其注册成table
val people = sc.textFile("examples/src/main/resources/people.txt").map(_.split(",")).map(p => Person(p(0), p(1).trim.toInt)).toDF()
people.registerTempTable("people")

// sqlContext.sql方法可以直接执行SQL语句
val teenagers = sqlContext.sql("SELECT name, age FROM people WHERE age >= 13 AND age <= 19")

// SQL查询的返回结果是一个DataFrame，且能够支持所有常见的RDD算子
// 查询结果中每行的字段可以按字段索引访问:
teenagers.map(t => "Name: " + t(0)).collect().foreach(println)

// 或者按字段名访问:
teenagers.map(t => "Name: " + t.getAs[String]("name")).collect().foreach(println)

// row.getValuesMap[T] 会一次性返回多列，并以Map[String, T]为返回结果类型
teenagers.map(_.getValuesMap[Any](List("name", "age"))).collect().foreach(println)
// 返回结果: Map("name" -> "Justin", "age" -> 19)
```

### 编程方式定义 Schema

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_6)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_6)
*   **[Python](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_6)**

如果不能事先通过 case class 定义 schema（例如，记录的字段结构是保存在一个字符串，或者其他文本数据集中，需要先解析，又或者字段对不同用户有所不同），那么你可能需要按以下三个步骤，以编程方式的创建一个 DataFrame：

1.  从已有的 RDD 创建一个包含 Row 对象的 RDD
2.  用 StructType 创建一个 schema，和步骤 1 中创建的 RDD 的结构相匹配
3.  把得到的 schema 应用于包含 Row 对象的 RDD，调用这个方法来实现这一步：SQLContext.createDataFrame

For example:

例如：

```
// sc 是已有的SparkContext对象
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// 创建一个RDD
val people = sc.textFile("examples/src/main/resources/people.txt")

// 数据的schema被编码与一个字符串中
val schemaString = "name age"

// Import Row.
import org.apache.spark.sql.Row;

// Import Spark SQL 各个数据类型
import org.apache.spark.sql.types.{StructType,StructField,StringType};

// 基于前面的字符串生成schema
val schema =
  StructType(
    schemaString.split(" ").map(fieldName => StructField(fieldName, StringType, true)))

// 将RDD[people]的各个记录转换为Rows，即：得到一个包含Row对象的RDD
val rowRDD = people.map(_.split(",")).map(p => Row(p(0), p(1).trim))

// 将schema应用到包含Row对象的RDD上，得到一个DataFrame
val peopleDataFrame = sqlContext.createDataFrame(rowRDD, schema)

// 将DataFrame注册为table
peopleDataFrame.registerTempTable("people")

// 执行SQL语句
val results = sqlContext.sql("SELECT name FROM people")

// SQL查询的结果是DataFrame，且能够支持所有常见的RDD算子
// 并且其字段可以以索引访问，也可以用字段名访问
results.map(t => "Name: " + t(0)).collect().foreach(println)
```

# 数据源

Spark SQL 支持基于 DataFrame 操作一系列不同的数据源。DataFrame 既可以当成一个普通 RDD 来操作，也可以将其注册成一个临时表来查询。把 DataFrame 注册为 table 之后，你就可以基于这个 table 执行 SQL 语句了。本节将描述加载和保存数据的一些通用方法，包含了不同的 Spark 数据源，然后深入介绍一下内建数据源可用选项。

## 通用加载 / 保存函数

在最简单的情况下，所有操作都会以默认类型数据源来加载数据（默认是 Parquet，除非修改了 spark.sql.sources.default 配置）。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_7)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_7)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_7)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_7)

```
val df = sqlContext.read.load("examples/src/main/resources/users.parquet")
df.select("name", "favorite_color").write.save("namesAndFavColors.parquet")
```

### 手动指定选项

你也可以手动指定数据源，并设置一些额外的选项参数。数据源可由其全名指定（如，org.apache.spark.sql.parquet），而对于内建支持的数据源，可以使用简写名（json, parquet, jdbc）。任意类型数据源创建的 DataFrame 都可以用下面这种语法转成其他类型数据格式。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_8)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_8)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_8)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_8)

```
val df = sqlContext.read.format("json").load("examples/src/main/resources/people.json")
df.select("name", "age").write.format("parquet").save("namesAndAges.parquet")
```

### 直接对文件使用 SQL

Spark SQL 还支持直接对文件使用 SQL 查询，不需要用 read 方法把文件加载进来。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_9)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_9)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_9)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_9)

```
val df = sqlContext.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
```

### 保存模式

Save 操作有一个可选参数 SaveMode，用这个参数可以指定如何处理数据已经存在的情况。很重要的一点是，这些保存模式都没有加锁，所以其操作也不是原子性的。另外，如果使用 Overwrite 模式，实际操作是，先删除数据，再写新数据。

| 仅 Scala/Java | 所有支持的语言 | 含义 |
| `SaveMode.ErrorIfExists `(default) | `"error" `(default) | （默认模式）从 DataFrame 向数据源保存数据时，如果数据已经存在，则抛异常。 |
| `SaveMode.Append` | `"append"` | 如果数据或表已经存在，则将 DataFrame 的数据追加到已有数据的尾部。 |
| `SaveMode.Overwrite` | `"overwrite"` | 如果数据或表已经存在，则用 DataFrame 数据覆盖之。 |
| `SaveMode.Ignore` | `"ignore"` | 如果数据已经存在，那就放弃保存 DataFrame 数据。这和 SQL 里 CREATE TABLE IF NOT EXISTS 有点类似。 |

### 保存到持久化表

在使用 HiveContext 的时候，DataFrame 可以用 saveAsTable 方法，将数据保存成持久化的表。与 registerTempTable 不同，saveAsTable 会将 DataFrame 的实际数据内容保存下来，并且在 HiveMetastore 中创建一个游标指针。持久化的表会一直保留，即使 Spark 程序重启也没有影响，只要你连接到同一个 metastore 就可以读取其数据。读取持久化表时，只需要用用表名作为参数，调用 SQLContext.table 方法即可得到对应 DataFrame。

默认情况下，saveAsTable 会创建一个”managed table“，也就是说这个表数据的位置是由 metastore 控制的。同样，如果删除表，其数据也会同步删除。

## Parquet 文件

[Parquet](http://parquet.io/) 是一种流行的列式存储格式。Spark SQL 提供对 Parquet 文件的读写支持，而且 Parquet 文件能够自动保存原始数据的 schema。写 Parquet 文件的时候，所有的字段都会自动转成 nullable，以便向后兼容。

### 编程方式加载数据

仍然使用上面例子中的数据：

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_10)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_10)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_10)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_10)
*   [**Sql**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_sql_10)

```
// 我们继续沿用之前例子中的sqlContext对象
// 为了支持RDD隐式转成DataFrame
import sqlContext.implicits._

val people: RDD[Person] = ... // 和上面例子中相同，一个包含case class对象的RDD

// 该RDD将隐式转成DataFrame，然后保存为parquet文件
people.write.parquet("people.parquet")

// 读取上面保存的Parquet文件(多个文件 - Parquet保存完其实是很多个文件)。Parquet文件是自描述的，文件中保存了schema信息
// 加载Parquet文件，并返回DataFrame结果
val parquetFile = sqlContext.read.parquet("people.parquet")

// Parquet文件（多个）可以注册为临时表，然后在SQL语句中直接查询
parquetFile.registerTempTable("parquetFile")
val teenagers = sqlContext.sql("SELECT name FROM parquetFile WHERE age >= 13 AND age <= 19")
teenagers.map(t => "Name: " + t(0)).collect().foreach(println)
```

### 分区发现

像 Hive 这样的系统，一个很常用的优化手段就是表分区。在一个支持分区的表中，数据是保存在不同的目录中的，并且将分区键以编码方式保存在各个分区目录路径中。Parquet 数据源现在也支持自动发现和推导分区信息。例如，我们可以把之前用的人口数据存到一个分区表中，其目录结构如下所示，其中有 2 个额外的字段，gender 和 country，作为分区键：

```
path
└── to
    └── table
        ├── gender=male
        │   ├── ...
        │   │
        │   ├── country=US
        │   │   └── data.parquet
        │   ├── country=CN
        │   │   └── data.parquet
        │   └── ...
        └── gender=female
            ├── ...
            │
            ├── country=US
            │   └── data.parquet
            ├── country=CN
            │   └── data.parquet
            └── ...
```

在这个例子中，如果需要读取 Parquet 文件数据，我们只需要把 path/to/table 作为参数传给 SQLContext.read.parquet 或者 SQLContext.read.load。Spark SQL 能够自动的从路径中提取出分区信息，随后返回的 DataFrame 的 schema 如下：

```
root
|-- name: string (nullable = true)
|-- age: long (nullable = true)
|-- gender: string (nullable = true)
|-- country: string (nullable = true)
```

注意，分区键的数据类型将是自动推导出来的。目前，只支持数值类型和字符串类型数据作为分区键。

有的用户可能不想要自动推导出来的分区键数据类型。这种情况下，你可以通过 spark.sql.sources.partitionColumnTypeInference.enabled （默认是 true）来禁用分区键类型推导。禁用之后，分区键总是被当成字符串类型。

从 Spark-1.6.0 开始，分区发现默认只在指定目录的子目录中进行。以上面的例子来说，如果用户把 path/to/table/gender=male 作为参数传给 SQLContext.read.parquet 或者 SQLContext.read.load，那么 gender 就不会被作为分区键。如果用户想要指定分区发现的基础目录，可以通过 basePath 选项指定。例如，如果把 path/to/table/gender=male 作为数据目录，并且将 basePath 设为 path/to/table，那么 gender 仍然会最为分区键。

### Schema 合并

像 ProtoBuffer、Avro 和 Thrift 一样，Parquet 也支持 schema 演变。用户从一个简单的 schema 开始，逐渐增加所需的新字段。这样的话，用户最终会得到多个 schema 不同但互相兼容的 Parquet 文件。目前，Parquet 数据源已经支持自动检测这种情况，并合并所有文件的 schema。

因为 schema 合并相对代价比较大，并且在多数情况下不是必要的，所以从 Spark-1.5.0 之后，默认是被禁用的。你可以这样启用这一功能：

1.  读取 Parquet 文件时，将选项 mergeSchema 设为 true（见下面的示例代码）
2.  或者，将全局选项 spark.sql.parquet.mergeSchema 设为 true

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_11)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_11)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_11)

```
// 继续沿用之前的sqlContext对象
// 为了支持RDD隐式转换为DataFrame
import sqlContext.implicits._

// 创建一个简单的DataFrame，存到一个分区目录中
val df1 = sc.makeRDD(1 to 5).map(i => (i, i * 2)).toDF("single", "double")
df1.write.parquet("data/test_table/key=1")

// 创建另一个DataFrame放到新的分区目录中，
// 并增加一个新字段，丢弃一个老字段
val df2 = sc.makeRDD(6 to 10).map(i => (i, i * 3)).toDF("single", "triple")
df2.write.parquet("data/test_table/key=2")

// 读取分区表
val df3 = sqlContext.read.option("mergeSchema", "true").parquet("data/test_table")
df3.printSchema()

// 最终的schema将由3个字段组成（single，double，triple）
// 并且分区键出现在目录路径中
// root
// |-- single: int (nullable = true)
// |-- double: int (nullable = true)
// |-- triple: int (nullable = true)
// |-- key : int (nullable = true)
```

### Hive metastore Parquet table 转换

在读写 Hive metastore Parquet 表时，Spark SQL 用的是内部的 Parquet 支持库，而不是 Hive SerDe，因为这样性能更好。这一行为是由 spark.sql.hive.convertMetastoreParquet 配置项来控制的，而且默认是启用的。

#### Hive/Parquet schema 调和

Hive 和 Parquet 在表结构处理上主要有 2 个不同点：

1.  Hive 大小写敏感，而 Parquet 不是
2.  Hive 所有字段都是 nullable 的，而 Parquet 需要显示设置

由于以上原因，我们必须在 Hive metastore Parquet table 转 Spark SQL Parquet table 的时候，对 Hive metastore schema 做调整，调整规则如下：

1.  两种 schema 中字段名和字段类型必须一致（不考虑 nullable）。调和后的字段类型必须在 Parquet 格式中有相对应的数据类型，所以 nullable 是也是需要考虑的。
2.  调和后 Spark SQL Parquet table schema 将包含以下字段：
    *   只出现在 Parquet schema 中的字段将被丢弃
    *   只出现在 Hive metastore schema 中的字段将被添加进来，并显式地设为 nullable。

#### 刷新元数据

Spark SQL 会缓存 Parquet 元数据以提高性能。如果 Hive metastore Parquet table 转换被启用的话，那么转换过来的 schema 也会被缓存。这时候，如果这些表由 Hive 或其他外部工具更新了，你必须手动刷新元数据。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_12)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_12)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_12)
*   [**Sql**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_sql_12)

```
// 注意，这里sqlContext是一个HiveContext
sqlContext.refreshTable("my_table")
```

### 配置

Parquet 配置可以通过 SQLContext.setConf 或者 SQL 语句中 SET key=value 来指定。

| 属性名 | 默认值 | 含义 |
| `spark.sql.parquet.binaryAsString` | false | 有些老系统，如：特定版本的 Impala，Hive，或者老版本的 Spark SQL，不区分二进制数据和字符串类型数据。这个标志的意思是，让 Spark SQL 把二进制数据当字符串处理，以兼容老系统。 |
| `spark.sql.parquet.int96AsTimestamp` | true | 有些老系统，如：特定版本的 Impala，Hive，把时间戳存成 INT96。这个配置的作用是，让 Spark SQL 把这些 INT96 解释为 timestamp，以兼容老系统。 |
| `spark.sql.parquet.cacheMetadata` | true | 缓存 Parquet schema 元数据。可以提升查询静态数据的速度。 |
| `spark.sql.parquet.compression.codec` | gzip | 设置 Parquet 文件的压缩编码格式。可接受的值有：uncompressed, snappy, gzip（默认）, lzo |
| `spark.sql.parquet.filterPushdown` | true | 启用过滤器下推优化，可以讲过滤条件尽量推导最下层，已取得性能提升 |
| `spark.sql.hive.convertMetastoreParquet` | true | 如果禁用，Spark SQL 将使用 Hive SerDe，而不是内建的对 Parquet tables 的支持 |
| `spark.sql.parquet.output.committer.class` | `org.apache.parquet.hadoop.
ParquetOutputCommitter` | Parquet 使用的数据输出类。这个类必须是 org.apache.hadoop.mapreduce.OutputCommitter 的子类。一般来说，它也应该是 org.apache.parquet.hadoop.ParquetOutputCommitter 的子类。注意：1\. 如果启用 spark.speculation, 这个选项将被自动忽略

2\. 这个选项必须用 hadoop configuration 设置，而不是 Spark SQLConf

3\. 这个选项会覆盖 spark.sql.sources.outputCommitterClass

Spark SQL 有一个内建的 org.apache.spark.sql.parquet.DirectParquetOutputCommitter, 这个类的在输出到 S3 的时候比默认的 ParquetOutputCommitter 类效率高。

 |
| `spark.sql.parquet.mergeSchema` | `false` | 如果设为 true，那么 Parquet 数据源将会 merge 所有数据文件的 schema，否则，schema 是从 summary file 获取的（如果 summary file 没有设置，则随机选一个） |

## JSON 数据集

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_13)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_13)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_13)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_13)
*   **[Sql](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_sql_13)**

Spark SQL 在加载 JSON 数据的时候，可以自动推导其 schema 并返回 DataFrame。用 SQLContext.read.json 读取一个包含 String 的 RDD 或者 JSON 文件，即可实现这一转换。

注意，通常所说的 json 文件只是包含一些 json 数据的文件，而不是我们所需要的 JSON 格式文件。JSON 格式文件必须每一行是一个独立、完整的的 JSON 对象。因此，一个常规的多行 json 文件经常会加载失败。

```
// sc是已有的SparkContext对象
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// 数据集是由路径指定的
// 路径既可以是单个文件，也可以还是存储文本文件的目录
val path = "examples/src/main/resources/people.json"
val people = sqlContext.read.json(path)

// 推导出来的schema，可由printSchema打印出来
people.printSchema()
// root
//  |-- age: integer (nullable = true)
//  |-- name: string (nullable = true)

// 将DataFrame注册为table
people.registerTempTable("people")

// 跑SQL语句吧！
val teenagers = sqlContext.sql("SELECT name FROM people WHERE age >= 13 AND age <= 19")

// 另一种方法是，用一个包含JSON字符串的RDD来创建DataFrame
val anotherPeopleRDD = sc.parallelize(
  """{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
val anotherPeople = sqlContext.read.json(anotherPeopleRDD)
```

## Hive 表

Spark SQL 支持从 [Apache Hive](http://hive.apache.org/) 读写数据。然而，Hive 依赖项太多，所以没有把 Hive 包含在默认的 Spark 发布包里。要支持 Hive，需要在编译 spark 的时候增加 - Phive 和 - Phive-thriftserver 标志。这样编译打包的时候将会把 Hive 也包含进来。注意，hive 的 jar 包也必须出现在所有的 worker 节点上，访问 Hive 数据时候会用到（如：使用 hive 的序列化和反序列化 SerDes 时）。

Hive 配置在 conf / 目录下 hive-site.xml，core-site.xml（安全配置），hdfs-site.xml（HDFS 配置）文件中。请注意，如果在 YARN cluster（yarn-cluster mode）模式下执行一个查询的话，lib_mananged/jar / 下面的 datanucleus 的 jar 包，和 conf / 下的 hive-site.xml 必须在驱动器（driver）和所有执行器（executor）都可用。一种简便的方法是，通过 spark-submit 命令的–jars 和–file 选项来提交这些文件。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_14)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_14)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_14)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_14)

如果使用 Hive，则必须构建一个 HiveContext，HiveContext 是派生于 SQLContext 的，添加了在 Hive Metastore 里查询表的支持，以及对 HiveQL 的支持。用户没有现有的 Hive 部署，也可以创建一个 HiveContext。如果没有在 hive-site.xml 里配置，那么 HiveContext 将会自动在当前目录下创建一个 metastore_db 目录，再根据 HiveConf 设置创建一个 warehouse 目录（默认 / user/hive/warehourse）。所以请注意，你必须把 / user/hive/warehouse 的写权限赋予启动 spark 应用程序的用户。

```
// sc是一个已有的SparkContext对象
val sqlContext = new org.apache.spark.sql.hive.HiveContext(sc)

sqlContext.sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING)")
sqlContext.sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src")

// 这里用的是HiveQL
sqlContext.sql("FROM src SELECT key, value").collect().foreach(println)
```

### 和不同版本的 Hive Metastore 交互

Spark SQL 对 Hive 最重要的支持之一就是和 Hive metastore 进行交互，这使得 Spark SQL 可以访问 Hive 表的元数据。从 Spark-1.4.0 开始，Spark SQL 有专门单独的二进制 build 版本，可以用来访问不同版本的 Hive metastore，其配置表如下。注意，不管所访问的 hive 是什么版本，Spark SQL 内部都是以 Hive 1.2.1 编译的，而且内部使用的 Hive 类也是基于这个版本（serdes，UDFs，UDAFs 等）

以下选项可用来配置 Hive 版本以便访问其元数据：

| 属性名 | 默认值 | 含义 |
| `spark.sql.hive.metastore.version` | `1.2.1` | Hive metastore 版本，可选的值为 0.12.0 到 1.2.1 |
| `spark.sql.hive.metastore.jars` | `builtin` | 初始化 HiveMetastoreClient 的 jar 包。这个属性可以是以下三者之一：

1.  `builtin`

目前内建为使用 Hive-1.2.1，编译的时候启用 - Phive，则会和 spark 一起打包。如果没有 - Phive，那么 spark.sql.hive.metastore.version 要么是 1.2.1，要就是未定义

1.  `maven`

使用 maven 仓库下载的 jar 包版本。这个选项建议不要再生产环境中使用

1.  JVM 格式的 classpath。这个 classpath 必须包含所有 Hive 及其依赖的 jar 包，且包含正确版本的 hadoop。这些 jar 包必须部署在 driver 节点上，如果你使用 yarn-cluster 模式，那么必须确保这些 jar 包也随你的应用程序一起打包

 |
| `spark.sql.hive.metastore.sharedPrefixes` | `com.mysql.jdbc,
org.postgresql,
com.microsoft.sqlserver,
oracle.jdbc` | 一个逗号分隔的类名前缀列表，这些类使用 classloader 加载，且可以在 Spark SQL 和特定版本的 Hive 间共享。例如，用来访问 hive metastore 的 JDBC 的 driver 就需要这种共享。其他需要共享的类，是与某些已经共享的类有交互的类。例如，自定义的 log4j appender |
| `spark.sql.hive.metastore.barrierPrefixes` | `(empty)` | 一个逗号分隔的类名前缀列表，这些类在每个 Spark SQL 所访问的 Hive 版本中都会被显式的 reload。例如，某些在共享前缀列表（spark.sql.hive.metastore.sharedPrefixes）中声明为共享的 Hive UD 函数 |

## 用 JDBC 连接其他数据库

Spark SQL 也可以用 JDBC 访问其他数据库。这一功能应该优先于使用 JdbcRDD。因为它返回一个 DataFrame，而 DataFrame 在 Spark SQL 中操作更简单，且更容易和来自其他数据源的数据进行交互关联。JDBC 数据源在 java 和 python 中用起来也很简单，不需要用户提供额外的 ClassTag。（注意，这与 Spark SQL JDBC server 不同，Spark SQL JDBC server 允许其他应用执行 Spark SQL 查询）

首先，你需要在 spark classpath 中包含对应数据库的 JDBC driver，下面这行包括了用于访问 postgres 的数据库 driver

```
SPARK_CLASSPATH=postgresql-9.3-1102-jdbc41.jar bin/spark-shell
```

远程数据库的表可以通过 Data Sources API，用 DataFrame 或者 SparkSQL 临时表来装载。以下是选项列表：

| 属性名 | 含义 |
| `url` | 需要连接的 JDBC URL |
| `dbtable` | 需要读取的 JDBC 表。注意，任何可以填在 SQL 的 where 子句中的东西，都可以填在这里。（既可以填完整的表名，也可填括号括起来的子查询语句） |
| `driver` | JDBC driver 的类名。这个类必须在 master 和 worker 节点上都可用，这样各个节点才能将 driver 注册到 JDBC 的子系统中。 |
| `partitionColumn, lowerBound, upperBound, numPartitions` | 这几个选项，如果指定其中一个，则必须全部指定。他们描述了多个 worker 如何并行的读入数据，并将表分区。partitionColumn 必须是所查询的表中的一个数值字段。注意，lowerBound 和 upperBound 只是用于决定分区跨度的，而不是过滤表中的行。因此，表中所有的行都会被分区然后返回。 |
| `fetchSize` | JDBC fetch size，决定每次获取多少行数据。在 JDBC 驱动上设成较小的值有利于性能优化（如，Oracle 上设为 10） |

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_15)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_15)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_15)
*   [**R**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_15)
*   [**Sql**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_sql_15)

```
val jdbcDF = sqlContext.read.format("jdbc").options(
  Map("url" -> "jdbc:postgresql:dbserver",
  "dbtable" -> "schema.tablename")).load()
```

## 疑难解答

*   JDBC driver class 必须在所有 client session 或者 executor 上，对 java 的原生 classloader 可见。这是因为 Java 的 DriverManager 在打开一个连接之前，会做安全检查，并忽略所有对原声 classloader 不可见的 driver。最简单的一种方法，就是在所有 worker 节点上修改 compute_classpath.sh，并包含你所需的 driver jar 包。
*   一些数据库，如 H2，会把所有的名字转大写。对于这些数据库，在 Spark SQL 中必须也使用大写。

# 性能调整

对于有一定计算量的 Spark 作业来说，可能的性能改进的方式，不是把数据缓存在内存里，就是调整一些开销较大的选项参数。

## 内存缓存

Spark SQL 可以通过调用 SQLContext.cacheTable(“tableName”) 或者 DataFrame.cache() 把 tables 以列存储格式缓存到内存中。随后，Spark SQL 将会扫描必要的列，并自动调整压缩比例，以减少内存占用和 GC 压力。你也可以用 SQLContext.uncacheTable(“tableName”) 来删除内存中的 table。

你还可以使用 SQLContext.setConf 或在 SQL 语句中运行 SET key=value 命令，来配置内存中的缓存。

| 属性名 | 默认值 | 含义 |
| `spark.sql.inMemoryColumnarStorage.compressed` | true | 如果设置为 true，Spark SQL 将会根据数据统计信息，自动为每一列选择单独的压缩编码方式。 |
| `spark.sql.inMemoryColumnarStorage.batchSize` | 10000 | 控制列式缓存批量的大小。增大批量大小可以提高内存利用率和压缩率，但同时也会带来 OOM（Out Of Memory）的风险。 |

## 其他配置选项

以下选项同样也可以用来给查询任务调性能。不过这些选项在未来可能被放弃，因为 spark 将支持越来越多的自动优化。

| 属性名 | 默认值 | 含义 |
| `spark.sql.autoBroadcastJoinThreshold` | 10485760 (10 MB) | 配置 join 操作时，能够作为广播变量的最大 table 的大小。设置为 - 1，表示禁用广播。注意，目前的元数据统计仅支持 Hive metastore 中的表，并且需要运行这个命令：ANALYSE TABLE <tableName> COMPUTE STATISTICS noscan |
| `spark.sql.tungsten.enabled` | true | 设为 true，则启用优化的 Tungsten 物理执行后端。Tungsten 会显式的管理内存，并动态生成表达式求值的字节码 |
| `spark.sql.shuffle.partitions` | 200 | 配置数据混洗（shuffle）时（join 或者聚合操作），使用的分区数。 |

# 分布式 SQL 引擎

Spark SQL 可以作为 JDBC/ODBC 或者命令行工具的分布式查询引擎。在这种模式下，终端用户或应用程序，无需写任何代码，就可以直接在 Spark SQL 中运行 SQL 查询。

## 运行 Thrift JDBC/ODBC server

这里实现的 Thrift JDBC/ODBC server 和 Hive-1.2.1 中的 [`HiveServer2`](https://cwiki.apache.org/confluence/display/Hive/Setting+Up+HiveServer2)是相同的。你可以使用 beeline 脚本来测试 Spark 或者 Hive-1.2.1 的 JDBC server。

在 Spark 目录下运行下面这个命令，启动一个 JDBC/ODBC server

```
./sbin/start-thriftserver.sh
```

这个脚本能接受所有 bin/spark-submit 命令支持的选项参数，外加一个 –hiveconf 选项，来指定 Hive 属性。运行./sbin/start-thriftserver.sh –help 可以查看完整的选项列表。默认情况下，启动的 server 将会在 localhost:10000 端口上监听。要改变监听主机名或端口，可以用以下环境变量：

```
export HIVE_SERVER2_THRIFT_PORT=<listening-port>
export HIVE_SERVER2_THRIFT_BIND_HOST=<listening-host>
./sbin/start-thriftserver.sh \
  --master <master-uri> \
  ...
```

或者 Hive 系统属性 来指定

```
./sbin/start-thriftserver.sh \
  --hiveconf hive.server2.thrift.port=<listening-port> \
  --hiveconf hive.server2.thrift.bind.host=<listening-host> \
  --master <master-uri>
  ...
```

接下来，你就可以开始在 beeline 中测试这个 Thrift JDBC/ODBC server:

```
./bin/beeline
```

下面的指令，可以连接到一个 JDBC/ODBC server

```
beeline> !connect jdbc:hive2://localhost:10000
```

可能需要输入用户名和密码。在非安全模式下，只要输入你本机的用户名和一个空密码即可。对于安全模式，请参考 [beeline documentation](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients).

Hive 的配置是在 conf / 目录下的 hive-site.xml，core-site.xml，hdfs-site.xml 中指定的。

你也可以在 beeline 的脚本中指定。

Thrift JDBC server 也支持通过 HTTP 传输 Thrift RPC 消息。以下配置（在 conf/hive-site.xml 中）将启用 HTTP 模式：

```
hive.server2.transport.mode - Set this to value: http
hive.server2.thrift.http.port - HTTP port number fo listen on; default is 10001
hive.server2.http.endpoint - HTTP endpoint; default is cliservice
```

同样，在 beeline 中也可以用 HTTP 模式连接 JDBC/ODBC server:

```
beeline> !connect jdbc:hive2://<host>:<port>/<database>?hive.server2.transport.mode=http;hive.server2.thrift.http.path=<http_endpoint>

```

## 使用 Spark SQL 命令行工具

Spark SQL CLI 是一个很方便的工具，它可以用 local mode 运行 hive metastore service，并且在命令行中执行输入的查询。注意 Spark SQL CLI 目前还不支持和 Thrift JDBC server 通信。

用如下命令，在 spark 目录下启动一个 Spark SQL CLI

```
./bin/spark-sql
```

Hive 配置在 conf 目录下 hive-site.xml，core-site.xml，hdfs-site.xml 中设置。你可以用这个命令查看完整的选项列表：./bin/spark-sql –help

# 升级指南

## 1.5 升级到 1.6

*   从 Spark-1.6.0 起，默认 Thrift server 将运行于多会话并存模式下（multi-session）。这意味着，每个 JDBC/ODBC 连接有其独立的 SQL 配置和临时函数注册表。table 的缓存仍然是公用的。如果你更喜欢老的单会话模式，只需设置 spark.sql.hive.thriftServer.singleSession 为 true 即可。当然，你也可在 spark-defaults.conf 中设置，或者将其值传给 start-thriftserver.sh –conf（如下）：

```
./sbin/start-thriftserver.sh \
     --conf spark.sql.hive.thriftServer.singleSession=true \
     ...
```

## 1.4 升级到 1.5

*   Tungsten 引擎现在默认是启用的，Tungsten 是通过手动管理内存优化执行计划，同时也优化了表达式求值的代码生成。这两个特性都可以通过把 spark.sql.tungsten.enabled 设为 false 来禁用。
*   Parquet schema merging 默认不启用。需要启用的话，设置 spark.sql.parquet.mergeSchema 为 true 即可
*   Python 接口支持用点 (.) 来访问字段内嵌值，例如 df[‘table.column.nestedField’]。但这也意味着，如果你的字段名包含点号 (.) 的话，你就必须用重音符来转义，如：table.`column.with.dots`.nested。
*   列式存储内存分区剪枝默认是启用的。要禁用，设置 spark.sql.inMemoryColumarStorage.partitionPruning 为 false 即可
*   不再支持无精度限制的 decimal。Spark SQL 现在强制最大精度为 38 位。对于 BigDecimal 对象，类型推导将会使用（38，18）精度的 decimal 类型。如果 DDL 中没有指明精度，默认使用的精度是（10，0）
*   时间戳精确到 1us（微秒），而不是 1ns（纳秒）
*   在 “sql” 这个 SQL 变种设置中，浮点数将被解析为 decimal。HiveQL 解析保持不变。
*   标准 SQL/DataFrame 函数均为小写，例如：sum vs SUM。
*   当推测任务被启用是，使用 DirectOutputCommitter 是不安全的，因此，DirectOutputCommitter 在推测任务启用时，将被自动禁用，且忽略相关配置。
*   JSON 数据源不再自动加载其他程序产生的新文件（例如，不是 Spark SQL 插入到 dataset 中的文件）。对于一个 JSON 的持久化表（如：Hive metastore 中保存的表），用户可以使用 REFRESH TABLE 这个 SQL 命令或者 HiveContext.refreshTable 来把新文件包括进来。

## 1.3 升级到 1.4

#### DataFrame 数据读写接口

根据用户的反馈，我们提供了一个新的，更加流畅的 API，用于数据读（SQLContext.read）写（DataFrame.write），同时老的 API（如：SQLCOntext.parquetFile, SQLContext.jsonFile）将被废弃。

有关 SQLContext.read 和 DataFrame.write 的更详细信息，请参考 API 文档。

#### DataFrame.groupBy 保留分组字段

根据用户的反馈，我们改变了 DataFrame.groupBy().agg() 的默认行为，在返回的 DataFrame 结果中保留了分组字段。如果你想保持 1.3 中的行为，设置 spark.sql.retainGroupColumns 为 false 即可。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_16)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_16)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_16)

```
// 在1.3.x中，如果要保留分组字段"department", 你必须显式的在agg聚合时包含这个字段
df.groupBy("department").agg($"department", max("age"), sum("expense"))

// 而在1.4+，分组字段"department"默认就会包含在返回的DataFrame中
df.groupBy("department").agg(max("age"), sum("expense"))

// 要回滚到1.3的行为（不包含分组字段），按如下设置即可：
sqlContext.setConf("spark.sql.retainGroupColumns", "false")
```

## 1.2 升级到 1.3

在 Spark 1.3 中，我们去掉了 Spark SQL 的”Alpha“标签，并清理了可用的 API。从 Spark 1.3 起，Spark SQL 将对 1.x 系列二进制兼容。这个兼容性保证不包括显式的标注为”unstable（如：DeveloperAPI 或 Experimental）“的 API。

#### SchemaRDD 重命名为 DataFrame

对于用户来说，Spark SQL 1.3 最大的改动就是 SchemaRDD 改名为 DataFrame。主要原因是，DataFrame 不再直接由 RDD 派生，而是通过自己的实现提供 RDD 的功能。DataFrame 只需要调用其 rdd 方法就能转成 RDD。

在 Scala 中仍然有 SchemaRDD，只不过这是 DataFrame 的一个别名，以便兼容一些现有代码。但仍然建议用户改用 DataFrame。Java 和 Python 用户就没这个福利了，他们必须改代码。

#### 统一 Java 和 Scala API

在 Spark 1.3 之前，有单独的 java 兼容类（JavaSQLContext 和 JavaSchemaRDD）及其在 Scala API 中的镜像。Spark 1.3 中将 Java API 和 Scala API 统一。两种语言的用户都应该使用 SQLContext 和 DataFrame。一般这些类中都会使用两种语言中都有的类型（如：Array 取代各语言独有的集合）。有些情况下，没有通用的类型（例如：闭包或者 maps），将会使用函数重载来解决这个问题。

另外，java 特有的类型 API 被删除了。Scala 和 java 用户都应该用 org.apache.spark.sql.types 来编程描述一个 schema。

#### 隐式转换隔离，DSL 包移除 – 仅针对 scala

Spark 1.3 之前的很多示例代码，都在开头用 import sqlContext._，这行将会导致所有的 sqlContext 的函数都被引入进来。因此，在 Spark 1.3 我们把 RDDs 到 DataFrames 的隐式转换隔离出来，单独放到 SQLContext.implicits 对象中。用户现在应该这样写：import sqlContext.implicits._

另外，隐式转换也支持由 Product（如：case classes 或 tuples）组成的 RDD，但需要调用一个 toDF 方法，而不是自动转换。

如果需要使用 DSL（被 DataFrame 取代的 API）中的方法，用户之前需要导入 DSL（import org.apache.spark.sql.catalyst.dsl）， 而现在应该要导入 DataFrame API（import org.apache.spark.sql.functions._）

#### 移除 org.apache.spark.sql 中 DataType 别名 – 仅针对 scala

Spark 1.3 删除了 sql 包中的 DataType 类型别名。现在，用户应该使用 org.apache.spark.sql.types 中的类。

#### UDF 注册挪到 sqlContext.udf 中 – 针对 java 和 scala

注册 UDF 的函数，不管是 DataFrame，DSL 或者 SQL 中用到的，都被挪到 SQLContext.udf 中。

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_17)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_17)

```
sqlContext.udf.register("strLen", (s: String) => s.length())
```

Python UDF 注册保持不变。

#### Python DataTypes 不再是单例

在 python 中使用 DataTypes，你需要先构造一个对象（如：StringType()），而不是引用一个单例。

## Shark 用户迁移指南

### 调度

用户可以通过如下命令，为 JDBC 客户端 session 设定一个 [Fair Scheduler](http://spark.apache.org/docs/latest/job-scheduling.html#fair-scheduler-pools) pool。

```
SET spark.sql.thriftserver.scheduler.pool=accounting;

```

### Reducer 个数

在 Shark 中，默认的 reducer 个数是 1，并且由 mapred.reduce.tasks 设定。Spark SQL 废弃了这个属性，改为 spark.sql.shuffle.partitions, 并且默认 200，用户可通过如下 SET 命令来自定义：

```
SET spark.sql.shuffle.partitions=10;
SELECT page, count(*) c
FROM logs_last_month_cached
GROUP BY page ORDER BY c DESC LIMIT 10;

```

你也可以把这个属性放到 hive-site.xml 中来覆盖默认值。

目前，mapred.reduce.tasks 属性仍然能被识别，并且自动转成 spark.sql.shuffle.partitions

### 缓存

shark.cache 表属性已经不存在了，并且以”_cached” 结尾命名的表也不再会自动缓存。取而代之的是，CACHE TABLE 和 UNCACHE TABLE 语句，用以显式的控制表的缓存：

```
CACHE TABLE logs_last_month;
UNCACHE TABLE logs_last_month;

```

注意：CACHE TABLE tbl 现在默认是饥饿模式，而非懒惰模式。再也不需要手动调用其他 action 来触发 cache 了！

从 Spark-1.2.0 开始，Spark SQL 新提供了一个语句，让用户自己控制表缓存是否是懒惰模式

```
CACHE [LAZY] TABLE [AS SELECT] ...

```

以下几个缓存相关的特性不再支持：

*   用户定义分区级别的缓存逐出策略
*   RDD 重加载
*   内存缓存直接写入策略

## 兼容 Apache Hive

Spark SQL 设计时考虑了和 Hive metastore，SerDes 以及 UDF 的兼容性。目前这些兼容性斗是基于 Hive-1.2.1 版本，并且 Spark SQL 可以连到不同版本的 Hive metastore（从 0.12.0 到 1.2.1，参考：[http://spark.apache.org/docs/latest/sql-programming-guide.html#interacting-with-different-versions-of-hive-metastore](http://spark.apache.org/docs/latest/sql-programming-guide.html#interacting-with-different-versions-of-hive-metastore)）

#### 部署在已有的 Hive 仓库之上

Spark SQL Thrift JDBC server 采用了”out of the box”（开箱即用）的设计，使用很方便，并兼容已有的 Hive 安装版本。你不需要修改已有的 Hive metastore 或者改变数据的位置，或者表分区。

### 支持的 Hive 功能

Spark SQL 支持绝大部分 Hive 功能，如：

*   Hive 查询语句：
    *   `SELECT`
    *   `GROUP BY`
    *   `ORDER BY`
    *   `CLUSTER BY`
    *   `SORT BY`
*   所有的 Hive 操作符：
    *   Relational operators (`=`, `⇔`, `==`, `<>`, `<`, `>`, `>=`, `<=`, etc)
    *   Arithmetic operators (`+`, `-`, `*`, `/`, `%`, etc)
    *   Logical operators (`AND`, `&&`, `OR`, `||`, etc)
    *   Complex type constructors
    *   Mathematical functions (`sign`, `ln`, `cos`, etc)
    *   String functions (`instr`, `length`, `printf`, etc)
*   用户定义函数（UDF）
*   用户定义聚合函数（UDAF）
*   用户定义序列化、反序列化（SerDes）
*   窗口函数（Window functions）
*   Joins
    *   `JOIN`
    *   `{LEFT|RIGHT|FULL} OUTER JOIN`
    *   `LEFT SEMI JOIN`
    *   `CROSS JOIN`
*   Unions
*   查询子句
    *   `SELECT col FROM ( SELECT a + b AS col from t1) t2`
*   采样
*   执行计划详细（Explain）
*   分区表，包括动态分区插入
*   视图
*   所有 Hive DDL（data definition language）：
    *   `CREATE TABLE`
    *   `CREATE TABLE AS SELECT`
    *   `ALTER TABLE`
*   绝大部分 Hive 数据类型：
    *   `TINYINT`
    *   `SMALLINT`
    *   `INT`
    *   `BIGINT`
    *   `BOOLEAN`
    *   `FLOAT`
    *   `DOUBLE`
    *   `STRING`
    *   `BINARY`
    *   `TIMESTAMP`
    *   `DATE`
    *   `ARRAY<>`
    *   `MAP<>`
    *   `STRUCT<>`

### 不支持的 Hive 功能

以下是目前不支持的 Hive 特性的列表。多数是不常用的。

**不支持的** **Hive** **常见功能**

*   bucket 表：butcket 是 Hive 表的一个哈希分区

**不支持的** **Hive** **高级****功能**

*   UNION 类操作
*   去重 join
*   字段统计信息收集：Spark SQL 不支持同步的字段统计收集

**Hive 输入、输出格式**

*   CLI 文件格式：对于需要回显到 CLI 中的结果，Spark SQL 仅支持 TextOutputFormat。
*   Hadoop archive — Hadoop 归档

**Hive 优化**

一些比较棘手的 Hive 优化目前还没有在 Spark 中提供。有一些（如索引）对应 Spark SQL 这种内存计算模型来说并不重要。另外一些，在 Spark SQL 未来的版本中会支持。

*   块级别位图索引和虚拟字段（用来建索引）
*   自动计算 reducer 个数（join 和 groupBy 算子）：目前在 Spark SQL 中你需要这样控制混洗后（post-shuffle）并发程度：”SET spark.sql.shuffle.partitions=[num_tasks];”
*   元数据查询：只查询元数据的请求，Spark SQL 仍需要启动任务来计算结果
*   数据倾斜标志：Spark SQL 不会理会 Hive 中的数据倾斜标志
*   `STREAMTABLE` join 提示：Spark SQL 里没有这玩艺儿
*   返回结果时合并小文件：如果返回的结果有很多小文件，Hive 有个选项设置，来合并小文件，以避免超过 HDFS 的文件数额度限制。Spark SQL 不支持这个。

# 参考

## 数据类型

Spark SQL 和 DataFrames 支持如下数据类型：

*   Numeric types（数值类型）
    *   `ByteType`: 1 字节长的有符号整型，范围：`-128` 到 `127`.
    *   `ShortType`: 2 字节长有符号整型，范围：`-32768` 到 `32767`.
    *   `IntegerType`: 4 字节有符号整型，范围：`-2147483648` 到 `2147483647`.
    *   `LongType`: 8 字节有符号整型，范围： `-9223372036854775808` to `9223372036854775807`.
    *   `FloatType`: 4 字节单精度浮点数。
    *   `DoubleType`: 8 字节双精度浮点数
    *   `DecimalType`: 任意精度有符号带小数的数值。内部使用 java.math.BigDecimal, BigDecimal 包含任意精度的不缩放整型，和一个 32 位的缩放整型
*   String type（字符串类型）
    *   `StringType`: 字符串
*   Binary type（二进制类型）
    *   `BinaryType`: 字节序列
*   Boolean type（布尔类型）
    *   `BooleanType`: 布尔类型
*   Datetime type（日期类型）
    *   `TimestampType`: 表示包含年月日、时分秒等字段的日期
    *   `DateType`: 表示包含年月日字段的日期
*   Complex types（复杂类型）
    *   `ArrayType(elementType, containsNull)`：数组类型，表达一系列的 elementType 类型的元素组成的序列，containsNull 表示数组能否包含 null 值
    *   `MapType(keyType, valueType, valueContainsNull)`：映射集合类型，表示一个键值对的集合。键的类型是 keyType，值的类型则由 valueType 指定。对应 MapType 来说，键是不能为 null 的，而值能否为 null 则取决于 valueContainsNull。
    *   `StructType(fields)：`表示包含 StructField 序列的结构体。
        *   StructField(name, datatype, nullable): 表示 StructType 中的一个字段，name 是字段名，datatype 是数据类型，nullable 表示该字段是否可以为空

*   [**Scala**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_scala_18)
*   [**Java**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_java_18)
*   [**Python**](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_python_18)
*   **[R](http://spark.apache.org/docs/latest/sql-programming-guide.html#tab_r_18)**

所有 Spark SQL 支持的数据类型都在这个包里：org.apache.spark.sql.types，你可以这样导入之：

```
import  org.apache.spark.sql.types._
```


| Data type | Value type in Scala | API to access or create a data type |
| **ByteType** | Byte | ByteType |
| **ShortType** | Short | ShortType |
| **IntegerType** | Int | IntegerType |
| **LongType** | Long | LongType |
| **FloatType** | Float | FloatType |
| **DoubleType** | Double | DoubleType |
| **DecimalType** | java.math.BigDecimal | DecimalType |
| **StringType** | String | StringType |
| **BinaryType** | Array[Byte] | BinaryType |
| **BooleanType** | Boolean | BooleanType |
| **TimestampType** | java.sql.Timestamp | TimestampType |
| **DateType** | java.sql.Date | DateType |
| **ArrayType** | scala.collection.Seq | ArrayType(_elementType_, [_containsNull_]) 注意：默认 containsNull 为 true |
| **MapType** | scala.collection.Map | MapType(_keyType_, _valueType_, [_valueContainsNull_]) 注意：默认 valueContainsNull 为 true |
| **StructType** | org.apache.spark.sql.Row | StructType(_fields_) 注意：fields 是一个 StructFields 的序列，并且同名的字段是不允许的。 |
| **StructField** | 定义字段的数据对应的 Scala 类型（例如，如果 StructField 的 dataType 为 IntegerType，则其数据对应的 scala 类型为 Int） | StructField(_name_, _dataType_, _nullable_) |

## NaN 语义

这是 Not-a-Number 的缩写，某些 float 或 double 类型不符合标准浮点数语义，需要对其特殊处理：

*   NaN == NaN，即：NaN 和 NaN 总是相等
*   在聚合函数中，所有 NaN 分到同一组
*   NaN 在 join 操作中可以当做一个普通的 join key
*   NaN 在升序排序中排到最后，比任何其他数值都大
