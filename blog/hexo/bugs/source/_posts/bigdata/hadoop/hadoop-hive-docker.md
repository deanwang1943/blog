---
title: Hadoop with hive in docker
date: 2018-07-31 08:36:03
tags:
  - Hadoop
  - 大数据
  - docker
categories:
  - 大数据
---

## 基于Docker的Hadoop集群环境搭建hive环境

>本文基于Hadoop in docker的文章后构建的，具体base的docker镜像都为hadoop3构建

### 构建镜像文件

`Dockerfile`

```Dockerfile
FROM dean1943/hadoop3

ENV HIVE_HOME /opt/hive
RUN mkdir -p $HIVE_HOME && mkdir -p $HIVE_HOME/tmp
COPY hive.tar.gz /opt/hive/installer.tgz
RUN cd /opt/hive && tar --strip-components=1 -xzf installer.tgz && rm installer.tgz

COPY hive-default.xml /opt/hive/conf/hive-site.xml
COPY hive-env.sh /opt/hive/conf/hive-env.sh

ENV PATH $PATH:$HIVE_HOME/bin


CMD ['/bin/bash', '/init.sh']
```

#### 配置文件

`hive-env.sh`

```Shell
export HADOOP_HOME=/opt/hadoop
export HIVE_CONF_DIR=/opt/hive/conf
```

`hive-site.xml`

>修改hive.metastore.schema.verification，设定为false
创建/usr/local/hive/tmp目录，替换${system:java.io.tmpdir}为该目录
替换${system:user.name}为root

#### 初始化数据库

```shell
schematool -initSchema -dbType derby
```

>会在当前目录下简历metastore_db的数据库。
>
>注意！！！下次执行hive时应该还在同一目录，默认到当前目录下寻找metastore。
>
>遇到问题，把metastore_db删掉，重新执行命令
>
>实际工作环境中，经常使用mysql作为metastore的数据

#### 启动hive

```Shell
hive
```

观察hadoop fs -ls /tmp/hive中目录的创建

```sql
show databases;
use default;
create table doc(line string);
show tables;
desc doc;
select * from doc;
drop table doc;
```

观察hadoop fs -ls /user
启动yarn

```sql
load data inpath '/wcinput' overwrite into table doc;
select * from doc;
select split(line, ' ') from doc;
select explode(split(line, ' ')) from doc;
select word, count(1) as count from (select explode(split(line, ' ')) as word from doc) w group by word;
select word, count(1) as count from (select explode(split(line, ' ')) as word from doc) w group by word order by word;
create table word_counts as select word, count(1) as count from (select explode(split(line, ' ')) as word from doc) w group by word order by word;
select * from word_counts;
dfs -ls /user/hive/...
```

使用sougou搜索日志做实验
将日志文件上传的hdfs系统，启动hive

```sql
create table sougou (qtime string, qid string, qword string, url string) row format delimited fields terminated by ',';
load data inpath '/sougou.dic' into table sougou;
select count(*) from sougou;
create table sougou_results as select keyword, count(1) as count from (select qword as keyword from sougou) t group by keyword order by count desc;
select * from sougou_results limit 10;
```
