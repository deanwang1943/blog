---
title: MySQL 中的索引详讲
date: 2018-09-25 08:36:03
tags: [MySQL]
categories: [MySQL]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5ba5f443f265da0ab673bb93

> 今天看了一篇关于 mysql 索引的博客，感觉内容写的非常不错，但是排版说实话看得我头疼，所以将其转载过来，重新排了一下版，也是防止以后忘了的话可以方便重新温习
> 博客地址：[www.cnblogs.com/whgk/p/6179…](https://link.juejin.im?target=https%3A%2F%2Fwww.cnblogs.com%2Fwhgk%2Fp%2F6179612.html)

### 一、什么是索引？为什么要建立索引？

       索引用于快速找出在某个列中有一特定值的行，不使用索引，MySQL 必须从第一条记录开始读完整个表，直到找出相关的行，表越大，查询数据所花费的时间就越多，如果表中查询的列有一个索引，MySQL 能够快速到达一个位置去搜索数据文件，而不必查看所有数据，那么将会节省很大一部分时间。

       例如：有一张 person 表，其中有 2W 条记录，记录着 2W 个人的信息。有一个 Phone 的字段记录每个人的电话号码，现在想要查询出电话号码为 xxxx 的人的信息。

       如果没有索引，那么将从表中第一条记录一条条往下遍历，直到找到该条信息为止。

       如果有了索引，那么会将该 Phone 字段，通过一定的方法进行存储，好让查询该字段上的信息时，能够快速找到对应的数据，而不必在遍历 2W 条数据了。其中 MySQL 中的索引的存储类型有两种：BTREE、HASH。

       也就是用树或者 Hash 值来存储该字段，要知道其中详细是如何查找的，就需要会算法的知识了。我们现在只需要知道索引的作用，功能是什么就行。

### 二、MySQL 中索引的优点和缺点和使用原则

#### 优点：

1.  所有的 MySql 列类型 (字段类型) 都可以被索引，也就是可以给任意字段设置索引
2.  大大加快数据的查询速度

#### 缺点：

1.  创建索引和维护索引要耗费时间，并且随着数据量的增加所耗费的时间也会增加
2.  索引也需要占空间，我们知道数据表中的数据也会有最大上线设置的，如果我们有大量的索引，索引文件可能会比数据文件更快达到上线值
3.  当对表中的数据进行增加、删除、修改时，索引也需要动态的维护，降低了数据的维护速度。

#### 使用原则：

       通过上面说的优点和缺点，我们应该可以知道，并不是每个字段度设置索引就好，也不是索引越多越好，而是需要自己合理的使用。

1.  对经常更新的表就避免对其进行过多的索引，对经常用于查询的字段应该创建索引，
2.  数据量小的表最好不要使用索引，因为由于数据较少，可能查询全部数据花费的时间比遍历索引的时间还要短，索引就可能不会产生优化效果。
3.  在一同值少的列上 (字段上) 不要建立索引，比如在学生表的 "性别" 字段上只有男，女两个不同值。相反的，在一个字段上不同值较多可是建立索引。 上面说的只是很片面的一些东西，索引肯定还有很多别的优点或者缺点，还有使用原则，先基本上理解索引，然后等以后真正用到了，就会慢慢知道别的作用。注意，学习这张，很重要的一点就是必须先得知道索引是什么，索引是干嘛的，有什么作用，为什么要索引等等，如果不知道，就重复往上面看看写的文字，好好理解一下。一个表中很够创建多个索引，这些索引度会被存放到一个索引文件中(专门存放索引的地方)

### 三、索引的分类

注意：索引是在存储引擎中实现的，也就是说不同的存储引擎，会使用不同的索引

       MyISAM 和 InnoDB 存储引擎：只支持 BTREE 索引， 也就是说默认使用 BTREE，不能够更换

MEMORY/HEAP 存储引擎：支持 HASH 和 BTREE 索引

索引我们分为四类来讲

单列索引 (普通索引，唯一索引，主键索引)、组合索引、全文索引、空间索引

#### 单列索引：

一个索引只包含单个列，但一个表中可以有多个单列索引。 这里不要搞混淆了。

1.  普通索引： MySQL 中基本索引类型，没有什么限制，允许在定义索引的列中插入重复值和空值，纯粹为了查询数据更快一点。
2.  唯一索引： 索引列中的值必须是唯一的，但是允许为空值，
3.  主键索引： 是一种特殊的唯一索引，不允许有空值。

#### 组合索引

       在表中的多个字段组合上创建的索引，只有在查询条件中使用了这些字段的左边字段时，索引才会被使用，使用组合索引时遵循最左前缀集合。这个如果还不明白，等后面举例讲解时在细说 

#### 全文索引

       全文索引，只有在 MyISAM 引擎上才能使用，只能在 CHAR,VARCHAR,TEXT 类型字段上使用全文索引，介绍了要求，说说什么是全文索引，就是在一堆文字中，通过其中的某个关键字等，就能找到该字段所属的记录行，比如有 "好人，二货 ..."

       通过好人，可能就可以找到该条记录。这里说的是可能，因为全文索引的使用涉及了很多细节，我们只需要知道这个大概意思，如果感兴趣进一步深入使用它，那么看下面测试该索引时，会给出一个博文，供大家参考。

#### 空间索引

       空间索引是对空间数据类型的字段建立的索引，MySQL 中的空间数据类型有四种，GEOMETRY、POINT、LINESTRING、POLYGON。在创建空间索引时，使用 SPATIAL 关键字。要求，引擎为 MyISAM，创建空间索引的列，必须将其声明为 NOT NULL。具体细节看下面

### 四、索引操作 (创建和删除)

#### 创建索引

1.  创建表的时候创建索引

格式：CREATE TABLE 表名 [字段名 数据类型] [UNIQUE|FULLTEXT|SPATIAL|...] [INDEX|KEY] [索引名字] (字段名 [length])   [ASC|DESC]

|--------------------------------------| |-----------------------------------| |------------| |---------| |---------------|   |------------|

普通创建表语句        设置什么样的索引 (唯一、全文等)  索引关键字  索引名字 对哪个字段设置索引  对索引进行排序 

*   创建普通索引

```
CREATE TABLE book
(
bookid INT NOT NULL,
bookname VARCHAR(255) NOT NULL,
authors VARCHAR(255) NOT NULL,
info VARCHAR(255) NULL,
comment VARCHAR(255) NULL,
year_publication YEAR NOT NULL,
INDEX(year_publication)
)

CREATE TABLE book
(
bookid INT NOT NULL,
bookname VARCHAR(255) NOT NULL,
authors VARCHAR(255) NOT NULL,
info VARCHAR(255) NULL,
comment VARCHAR(255) NULL,
year_publication YEAR NOT NULL,
KEY(year_publication)
)

```

       上面两种方式创建度可以，通过这个例子可以对比一下格式，就差不多明白格式是什么意思了。

![](https://user-gold-cdn.xitu.io/2018/9/22/1660059ea7ecbc8a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

       通过打印结果，我们在创建索引时没写索引名的话，会自动帮我们用字段名当作索引名。 测试：看是否使用了索引进行查询。

```
SELECT * FROM book WHERE year_publication = 1990\G;

```

       解释：虽然表中没数据，但是有 EXPLAIN 关键字，用来查看索引是否正在被使用，并且输出其使用的索引的信息。

![](https://user-gold-cdn.xitu.io/2018/9/22/166005bf70915ffe?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

```
id:SELECT识别符。这是SELECT的查询序列号,也就是一条语句中，该select是第几次出现
。在次语句中，select就只有一个，所以是1.

select_type:所使用的SELECT查询类型，SIMPLE表示为简单的SELECT，不实用UNION或子
查询，就为简单的SELECT。也就是说在该SELECT查询时会使用索引。其他取值，

PRIMARY：最外面的SELECT.在拥有子查询时，就会出现两个以上的SELECT。UNION：union
(两张表连接)中的第二个或后面的select语句  SUBQUERY：在子查询中，第二SELECT。

table：数据表的名字。他们按被读取的先后顺序排列，这里因为只查询一张表，所以只
显示book

type: 指定本据表和其他数据表之间的关联关系，该表中所有符合检索值的记录都会被取
出来和从上一个表中取出来的记录作联合。ref用于连接程序使用键的最左前缀或者是该
键不是 primary key 或unique索引（换句话说，就是连接程序无法根据键值只取得一条
记录）的情况。当根据键值只查询到少数几条匹配的记录时，这就是一个不错的连接类型
。(注意，个人这里不是很理解，百度了很多资料，全是大白话，等以后用到了这类信息
时，在回过头来补充，这里不懂对后面的影响不大。)可能的取值有
system、const、eq_ref、index和All

possible_keys：MySQL在搜索数据记录时可以选用的各个索引，该表中就只有一个索引，y
ear_publication

key：实际选用的索引

key_len：显示了mysql使用索引的长度(也就是使用的索引个数)，当key字段的值为null
时，索引的长度就是null。注意，key_len的值可以告诉你在联合索引中mysql会真正使用
了哪些索引。这里就使用了1个索引，所以为1，

ref:给出关联关系中另一个数据表中数据列的名字。常量（const），这里使用的是1990
，就是常量。

rows：MySQL在执行这个查询时预计会从这个数据表里读出的数据行的个数。

extra：提供了与关联操作有关的信息，没有则什么都不写。

上面的一大堆东西能看懂多少看多少，我们最主要的是看possible_keys和key 这两个属性，上面显示了key为year_publication。说明使用了索引。

```

*   创建唯一索引

```
CREATE TABLE t1
(
id INT NOT NULL,
name CHAR(30) NOT NULL,
UNIQUE INDEX UniqIdx(id)
)

```

解释：对 id 字段使用了索引，并且索引名字为 UniqIdx。

```
SHOW CREATE TABLE t1\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/16600625f3244de8?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

       要查看其中查询时使用的索引，必须先往表中插入数据，然后在查询数据，不然查找一个没有的 id 值，是不会使用索引的。

```
INSERT INTO t1 VALUES(1,'xxx');
EXPLAIN SELECT * FROM t1 WHERE id = 1\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660062f02e56dc7?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

       可以看到，通过 id 查询时，会使用唯一索引。并且还实验了查询一个没有的 id 值，则不会使用索引，我觉得原因是所有的 id 应该会存储到一个 const tables 中，到其中并没有该 id 值，那么就没有查找的必要了。

*   创建主键索引

```
CREATE TABLE t2
(
id INT NOT NULL,
name CHAR(10),
PRIMARY KEY(id)
);

INSERT INTO t2 VALUES(1,'QQQ');
EXPLAIN SELECT * FROM t2 WHERE id = 1\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660068202842b0b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

       通过这个主键索引，我们就应该反应过来，其实我们以前声明的主键约束，就是一个主键索引，只是之前我们没学过，不知道而已。

*   创建单列索引

这个其实就不用在说了，前面几个就是单列索引。

* 创建组合索引

组合索引就是在多个字段上创建一个索引

创建一个表 t3，在表中的 id、name 和 age 字段上建立组合索引

```
CREATE TABLE t3
(
id INT NOT NULL,
name CHAR(30) NOT NULL,
age INT NOT NULL,
info VARCHAR(255),
INDEX MultiIdx(id,name,age)
);

SHOW CREATE t3\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166006a07eb76533?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

解释最左前缀

       组合索引就是遵从了最左前缀，利用索引中最左边的列集来匹配行，这样的列集称为最左前缀，不明白没关系，举几个例子就明白了，例如，这里由 id、name 和 age3 个字段构成的索引，索引行中就按 id/name/age 的顺序存放，索引可以索引下面字段组合 (id，name，age)、(id，name) 或者(id)。如果要查询的字段不构成索引最左面的前缀，那么就不会是用索引，比如，age 或者（name，age）组合就不会使用索引查询

在 t3 表中，查询 id 和 name 字段

```
EXPLAIN SELECT * FROM t3 WHERE id = 1 AND name = 'joe'\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166006aaf8204b92?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

在 t3 表中，查询 (age，name) 字段，这样就不会使用索引查询。来看看结果

```
EXPLAIN SELECT * FROM t3 WHERE age = 3 AND name = 'bob'\G;

```

*   创建全文索引

       全文索引可以用于全文搜索，但只有 MyISAM 存储引擎支持 FULLTEXT 索引，并且只为 CHAR、VARCHAR 和 TEXT 列服务。索引总是对整个列进行，不支持前缀索引，

```
CREATE TABLE t4
(
id  INT NOT NULL,
name CHAR(30) NOT NULL,
age INT NOT NULL,
info VARCHAR(255),
FULLTEXT INDEX FullTxtIdx(info)
)ENGINE=MyISAM;

SHOW CREATE TABLE t4\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166006c9ef8b4b32?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

使用一下什么叫做全文搜索。就是在很多文字中，通过关键字就能够找到该记录。

```
INSERT INTO t4 VALUES
(8,'AAA',3,'text is so good，hei，my name is bob')
,(9,'BBB',4,'my name is gorlr');

SELECT * FROM t4 WHERE MATCH(info) AGAINST('gorlr');

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166006da138e020f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

```
EXPLAIN SELECT * FROM t4 WHERE MATCH(info) AGAINST('gorlr');

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166006de597c6172?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)        注意：在使用全文搜索时，需要借助 MATCH 函数，并且其全文搜索的限制比较多，比如只能通过 MyISAM 引擎，比如只能在 CHAR,VARCHAR,TEXT 上设置全文索引。比如搜索的关键字默认至少要 4 个字符，比如搜索的关键字太短就会被忽略掉。等等，如果你们在实验的时候可能会实验不出来。感兴趣的同学可以看看这篇文章，[全文搜索的使用](https://link.juejin.im?target=http%3A%2F%2Fblog.sina.com.cn%2Fs%2Fblog_ae1611930101a063.html)

*   创建空间索引

空间索引也必须使用 MyISAM 引擎， 并且空间类型的字段必须为非空。

       这个空间索引具体能干嘛我也不知道，可能跟游戏开发有关，可能跟别的东西有关，等遇到了自然就知道了，现在只要求能够创建出来。

```
CREATE TABLE t5
(
g GEOMETRY NOT NULL,
SPATIAL INDEX spatIdx(g)
) ENGINE = MyISAM;

SHOW CREATE TABLE t5\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660070ccf22cc76?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

1.  在已经存在的表上创建索引

格式：ALTER TABLE 表名 ADD[UNIQUE|FULLTEXT|SPATIAL] [INDEX|KEY] [索引名] (索引字段名)[ASC|DESC] 有了上面的基础，这里就不用过多陈述了。

命令一：

```
SHOW INDEX FROM 表名\G

```

查看一张表中所创建的索引

```
SHOW INDEX FROM book\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660071f8b8dfa1f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

       挑重点讲，我们需要了解的就 5 个，用红颜色标记了的，如果想深入了解，可以去查查该方面的资料，我个人觉得，这些等以后实际工作中遇到了在做详细的了解把。

```
Table:创建索引的表

Non_unique：表示索引非唯一，1代表非唯一索引，0代表唯一索引，意思就是该索引是不是唯一索引

Key_name：索引名称

Seq_in_index :表示该字段在索引中的位置，单列索引的话该值为1，组合索引为每个字段在索引定义中的顺序(这个只需要知道单列索引该值就为1，组合索引为别的)

Column_name：表示定义索引的列字段

Sub_part：表示索引的长度

Null：表示该字段是否能为空值

Index_type：表示索引类型

```

*   为表添加索引

就拿上面的 book 表来说。本来已经有了一个 year_publication，现在我们为该表在加一个普通索引

```
ALTER TABLE book ADD INDEX BkNameIdx(bookname(30));

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660073789279d59?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

看输出结果，就能知道，添加索引成功了。

这里只是拿普通索引做个例子，添加其他索引也是一样的。依葫芦画瓢而已。这里就不一一做讲解了。

*   使用 CREATE INDEX 创建索引

格式：CREATE [UNIQUE|FULLTEXT|SPATIAL] [INDEX|KEY] 索引名称 ON 表名 (创建索引的字段名 [length])[ASC|DESC]

解释：其实就是换汤不换药，格式改变了一下而已，做的事情跟上面完全一样，做一个例子。

在为 book 表增加一个普通索引，字段为 authors。

```
CREATE INDEX BkBookNameIdx ON book(bookname);

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166007491a9fe388?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

```
SHOW INDEX FROM book\G;&emsp;&emsp;//查看book表中的索引

```

![](https://user-gold-cdn.xitu.io/2018/9/22/1660074ed21dd5be?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

解释：第一条截图没截到，因为图太大了，这里只要看到有我们新加进去的索引就证明成功了。。其他索引也是一样的创建。

### 删除索引

前面讲了对一张表中索引的添加，查询的方法。

添加的两种方式

1 在创建表的同时如何创建索引，

2 在创建了表之后如何给表添加索引的两种方式，

查询的方式

```
SHOW INDEX FROM 表名\G；

```

\G 只是让输出的格式更好看

现在来说说如何给表删除索引的两种操作。

1.  格式一：ALTER TABLE 表名 DROP INDEX 索引名

很简单的语句，现在通过一个例子来看看，还是对 book 表进行操作，删除我们刚才为其添加的索引。

1、删除 book 表中的名称为 BkBookNameIdx 的索引。

```
ALTER TABLE book DROP INDEX BkBookNameIdx;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/16600792876f25b5?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

```
SHOW INDEX FROM book\G;&emsp;&emsp;//在查看book表中的索引，就会发现BkBookNameIdx这个索引已经不在了

```

![](https://user-gold-cdn.xitu.io/2018/9/22/16600798a9857006?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

1.  格式二：DROP INDEX 索引名 ON 表名

删除 book 表中名为 BkNameIdx 的索引

```
DROP INDEX BkNameIdx ON book;
SHOW INDEX FROM book\G;

```

![](https://user-gold-cdn.xitu.io/2018/9/22/166007a207b21c7c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
