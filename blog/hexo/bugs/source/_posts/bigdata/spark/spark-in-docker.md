---
title: Spark in docker
date: 2018-07-24 08:36:03
tags:
  - spark
  - 大数据
  - docker
categories:
  - 大数据
---

## 基于Docker的Spark集群环境搭建

### 准备基础环境

1. 首先在系统中安装docker的相关软件，本文基于系统`ubuntu 18.04`版本构建，`docker version 17.12`
2. 安装docker，网上很多文章不载赘述


### 编写基础镜像文件

1. 基于`ubuntu 18.04`的官方镜像

  > base/Dockerfile
  >
  > base/jdk.tar.gz
  >
  > base/spark.tgz
  >
  > base/spark-env.sh
  >
  > base/slaves


  base/Dockerfile

  ```Dockerfile
  FROM ubuntu:18.04

  MAINTAINER deanwang<wangjingxin1986@gmail.com>

  ENV TZ "Asia/Shanghai"

  RUN apt-get update

  RUN apt-get install openssh-server -y
  RUN echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
  RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
  RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  RUN /etc/init.d/ssh start

  RUN apt-get install vim -y

  # 设置root ssh远程登录密码为123456
  RUN echo "root:123456" | chpasswd

  RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

  #install jdk and set JAVA_HOME
  RUN mkdir -p /opt/jdk
  COPY jdk.tar.gz /opt/jdk/installer.tgz
  RUN cd /opt/jdk && tar --strip-components=1 -xzf installer.tgz && rm installer.tgz

  ENV JAVA_HOME /opt/jdk
  ENV PATH $PATH:$JAVA_HOME/bin

  #install spark and set SPARK_HOME
  RUN mkdir -p /opt/spark
  COPY spark.tgz /opt/spark/installer.tgz
  RUN cd /opt/spark && tar --strip-components=1 -xzf installer.tgz && rm installer.tgz
  ENV SPARK_HOME /opt/spark
  ENV PATH $PATH:$SPARK_HOME/bin
  ENV PATH $PATH:$SPARK_HOME/sbin

  COPY spark-env.sh /opt/spark/conf/
  COPY slaves /opt/spark/conf/

  RUN mkdir -p /opt/spark/logs

  COPY init.sh /

  EXPOSE 22
  ```
  >将jdk的tar.gz存放与路经base/jdk.tar.gz
  >
  >将Spark的tgz存放与路经master/spark.tgz

2. 构建基础镜像

  构建命令:

  ```Shell
  sudo docker build -t dean1943/ubuntu-base .
  ```

### 编写master镜像文件

1. 基于Base的基础镜像加入Spark相关组建

  master/Dockerfile

  ```Dockerfile
  FROM dean1943/ubuntu-base

  MAINTAINER dean<wangjingxin1986@gmail.com>

  ENV SPARK_MASTER_PORT 7077
  ENV SPARK_MASTER_WEBUI_PORT 8080
  ENV SPARK_MASTER_LOG /opt/spark/logs

  EXPOSE 8080 7077 6066

  CMD ["/usr/sbin/sshd", "-D"]
  ```

  构建命令：
  ```Shell
  sudo docker build -t dean1943/spark-master .
  ```

### 编写worker镜像文件

1. 基于Base的基础镜像加入Spark相关组建

  worker/Dockerfile

  ```Dockerfile
  FROM dean1943/ubuntu-base

  MAINTAINER dean<wangjingxin1986@gmail.com>

  ENV SPARK_MASTER_WEBUI_PORT 8081
  ENV SPARK_MASTER_LOG /opt/spark/logs
  ENV SPARK_MASTER "spark://spark-master:7077"

  EXPOSE 8081

  CMD ["/usr/sbin/sshd", "-D"]
  ```

  构建命令：
  ```Shell
  sudo docker build -t dean1943/spark-worker .
  ```

### Spark配置文件

1. slaves
  ```XML
  #
  #
  # Licensed to the Apache Software Foundation (ASF) under one or more
  # contributor license agreements.  See the NOTICE file distributed with
  # this work for additional information regarding copyright ownership.
  # The ASF licenses this file to You under the Apache License, Version 2.0
  # (the "License"); you may not use this file except in compliance with
  # the License.  You may obtain a copy of the License at
  #
  #    http://www.apache.org/licenses/LICENSE-2.0
  #
  # Unless required by applicable law or agreed to in writing, software
  # distributed under the License is distributed on an "AS IS" BASIS,
  # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  # See the License for the specific language governing permissions and
  # limitations under the License.
  #

  # A Spark Worker will be started on each of the machines listed below.
  spark-worker1
  spark-worker2
  ```

2. spark-env.sh
  ```Shell
  #!/usr/bin/env bash

  #
  # Licensed to the Apache Software Foundation (ASF) under one or more
  # contributor license agreements.  See the NOTICE file distributed with
  # this work for additional information regarding copyright ownership.
  # The ASF licenses this file to You under the Apache License, Version 2.0
  # (the "License"); you may not use this file except in compliance with
  # the License.  You may obtain a copy of the License at
  #
  #    http://www.apache.org/licenses/LICENSE-2.0
  #
  # Unless required by applicable law or agreed to in writing, software
  # distributed under the License is distributed on an "AS IS" BASIS,
  # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  # See the License for the specific language governing permissions and
  # limitations under the License.
  #

  # This file is sourced when running various Spark programs.
  # Copy it as spark-env.sh and edit that to configure Spark for your site.

  # Options read when launching programs locally with
  # ./bin/run-example or ./bin/spark-submit
  # - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
  # - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
  # - SPARK_PUBLIC_DNS, to set the public dns name of the driver program

  # Options read by executors and drivers running inside the cluster
  # - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
  # - SPARK_PUBLIC_DNS, to set the public DNS name of the driver program
  # - SPARK_LOCAL_DIRS, storage directories to use on this node for shuffle and RDD data
  # - MESOS_NATIVE_JAVA_LIBRARY, to point to your libmesos.so if you use Mesos

  # Options read in YARN client/cluster mode
  # - SPARK_CONF_DIR, Alternate conf dir. (Default: ${SPARK_HOME}/conf)
  # - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
  # - YARN_CONF_DIR, to point Spark towards YARN configuration files when you use YARN
  # - SPARK_EXECUTOR_CORES, Number of cores for the executors (Default: 1).
  # - SPARK_EXECUTOR_MEMORY, Memory per Executor (e.g. 1000M, 2G) (Default: 1G)
  # - SPARK_DRIVER_MEMORY, Memory for Driver (e.g. 1000M, 2G) (Default: 1G)
  SPARK_MASTER_HOST=spark-master
  SPARK_MASTER_PORT=7077
  SPARK_WORKER_CORES=1
  SPARK_WORKER_MEMORY=1G
  JAVA_HOME=/opt/jdk
  # Options for the daemons used in the standalone deploy mode
  # - SPARK_MASTER_HOST, to bind the master to a different IP address or hostname
  # - SPARK_MASTER_PORT / SPARK_MASTER_WEBUI_PORT, to use non-default ports for the master
  # - SPARK_MASTER_OPTS, to set config properties only for the master (e.g. "-Dx=y")
  # - SPARK_WORKER_CORES, to set the number of cores to use on this machine
  # - SPARK_WORKER_MEMORY, to set how much total memory workers have to give executors (e.g. 1000m, 2g)
  # - SPARK_WORKER_PORT / SPARK_WORKER_WEBUI_PORT, to use non-default ports for the worker
  # - SPARK_WORKER_DIR, to set the working directory of worker processes
  # - SPARK_WORKER_OPTS, to set config properties only for the worker (e.g. "-Dx=y")
  # - SPARK_DAEMON_MEMORY, to allocate to the master, worker and history server themselves (default: 1g).
  # - SPARK_HISTORY_OPTS, to set config properties only for the history server (e.g. "-Dx=y")
  # - SPARK_SHUFFLE_OPTS, to set config properties only for the external shuffle service (e.g. "-Dx=y")
  # - SPARK_DAEMON_JAVA_OPTS, to set config properties for all daemons (e.g. "-Dx=y")
  # - SPARK_DAEMON_CLASSPATH, to set the classpath for all daemons
  # - SPARK_PUBLIC_DNS, to set the public dns name of the master or workers

  # Generic options for the daemons used in the standalone deploy mode
  # - SPARK_CONF_DIR      Alternate conf dir. (Default: ${SPARK_HOME}/conf)
  # - SPARK_LOG_DIR       Where log files are stored.  (Default: ${SPARK_HOME}/logs)
  # - SPARK_PID_DIR       Where the pid file is stored. (Default: /tmp)
  # - SPARK_IDENT_STRING  A string representing this instance of spark. (Default: $USER)
  # - SPARK_NICENESS      The scheduling priority for daemons. (Default: 0)
  # - SPARK_NO_DAEMONIZE  Run the proposed command in the foreground. It will not output a PID file.
  # Options for native BLAS, like Intel MKL, OpenBLAS, and so on.
  # You might get better performance to enable these options if using native BLAS (see SPARK-21305).
  # - MKL_NUM_THREADS=1        Disable multi-threading of Intel MKL
  # - OPENBLAS_NUM_THREADS=1   Disable multi-threading of OpenBLAS

  ```

3. init.sh
  ```Shell
  echo "172.17.0.2	spark-master" >> /etc/hosts
  echo "172.17.0.3	spark-worker1" >> /etc/hosts
  echo "172.17.0.4	spark-worker2" >> /etc/hosts

  /bin/bash /etc/init.d/ssh start
  ```

### 构建命令

1. 启动命令

  >start-all.sh

  ```Shell
  sudo docker run -d -p 50001:6066 -p 50002:7077 -p 50003:8080 --name spark-master -h spark-master dean1943/spark-master
  sudo docker run -d -p 50004:8081 --name spark-worker1 -h spark-worker1 dean1943/spark-worker
  sudo docker run -d -p 50005:8081 --name spark-worker2 -h spark-worker2 dean1943/spark-worker

  sudo docker exec -it spark-worker1 /bin/bash /init.sh
  sudo docker exec -it spark-worker2 /bin/bash /init.sh

  sudo docker exec -it spark-master /bin/bash /init.sh
  sudo docker exec -it spark-master /bin/bash /opt/spark/sbin/start-all.sh
  ```
2. 停止命令
  ```Shell
  sudo docker stop spark-master spark-worker1 spark-worker2
  ```
