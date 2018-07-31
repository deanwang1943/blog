---
title: Hadoop in docker
date: 2018-07-26 08:36:03
tags:
  - Hadoop
  - 大数据
  - docker
categories:
  - 大数据
---

## 基于Docker的Hadoop集群环境搭建

### 准备基础环境

1. 首先在系统中安装docker的相关软件，本文基于系统`ubuntu 18.04`版本构建，`docker version 17.12`
2. 安装docker，网上很多文章不载赘述


### 编写基础镜像文件

1. 基于`ubuntu 18.04`的官方镜像

  > base/Dockerfile
  >
  > base/jdk.tar.gz
  >
  > base/hadoop.tar.gz
  >
  > base/workers
  >
  > base/init.sh



  base/Dockerfile

  ```Dockerfile
  FROM ubuntu:18.04

  MAINTAINER dean<wangjingxin1986@gmail.com>

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
  RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  	chmod 0600 ~/.ssh/authorized_keys

  COPY ssh_config /root/.ssh/ssh_config
  COPY etc/init.sh /

  RUN mkdir -p /opt/jdk
  COPY jdk.tar.gz /opt/jdk/installer.tgz
  RUN cd /opt/jdk && tar --strip-components=1 -xzf installer.tgz && rm installer.tgz

  ENV JAVA_HOME /opt/jdk
  ENV PATH $PATH:$JAVA_HOME/bin

  ENV HADOOP_HOME /opt/hadoop
  RUN mkdir -p $HADOOP_HOME && mkdir -p $HADOOP_HOME/tmp && mkdir -p $HADOOP_HOME/hdfs/name && mkdir -p $HADOOP_HOME/hdfs/data
  COPY hadoop.tar.gz /opt/hadoop/installer.tgz
  RUN cd /opt/hadoop && tar --strip-components=1 -xzf installer.tgz && rm installer.tgz

  ENV PATH $PATH:$HADOOP_HOME/bin
  ENV PATH $PATH:$HADOOP_HOME/sbin

  COPY etc/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
  COPY etc/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
  COPY etc/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
  COPY etc/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
  #COPY etc/workers $HADOOP_HOME/etc/workers

  RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  #    echo "export HDFS_DATANODE_SECURE_USER=hdfs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
      echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
      echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

  EXPOSE 8088 9870 9864 19888 8042 8888 22

  CMD ['/bin/bash', '/init.sh']
  ```
  >将jdk的tar.gz存放与路经base/jdk.tar.gz
  >
  >将Hadoop的tgz存放与路经base/hadoop.tar.gz

2. 构建基础镜像

  构建命令:

  ```Shell
  sudo docker build -t dean1943/hadoop3 .
  ```

### 编写master

1. 基于Base的基础镜像

  master/instance.sh

  ```Shell
  sudo docker run -it -h=master -p 8088:8088 -p 9870:9870 -p 9864:9864 -p 19888:19888 -p 8042:8042 -p 8888:8888 --name master -d dean1943/hadoop3 /bin/bash
  #sudo docker run -it -h=hadoop3 -p 8088:8088 -p 9870:9870 -p 9864:9864 -p 19888:19888 -p 8042:8042 -p 8888:8888 --name hadoop3 -d dean1943/hadoop3 /bin/bash
  #sudo docker exec -it master /bin/bash rm -f ~/.ssh/known_hosts
  sudo docker exec -it master /bin/bash /init.sh
  #sudo docker exec -it master /bin/bash /etc/init.d/ssh start
  sudo docker exec -it master /bin/bash /opt/hadoop/bin/hadoop namenode -format

  #sudo docker exec -it hadoop3 /bin/bash /etc/init.d/ssh start

  sudo docker exec -it master /bin/bash /opt/hadoop/sbin/start-dfs.sh
  #sudo docker exec -it master /bin/bash /opt/hadoop/sbin/stop-dfs.sh

  sudo docker exec -it master /bin/bash /opt/hadoop/sbin/start-yarn.sh
  #sudo docker exec -it master /bin/bash /opt/hadoop/sbin/stop-yarn.sh
  ```

  构建命令：
  ```Shell
  sudo sh instance.sh
  ```

### 编写worker镜像文件

1. 基于Base的基础镜像

  worker/instance.sh

  ```shell
  sudo docker run -it -h=master -p 8088:8088 -p 9870:9870 -p 9864:9864 -p 19888:19888 -p 8042:8042 -p 8888:8888 --name master -d dean1943/hadoop3 /bin/bash
  #sudo docker run -it -h=hadoop3 -p 8088:8088 -p 9870:9870 -p 9864:9864 -p 19888:19888 -p 8042:8042 -p 8888:8888 --name hadoop3 -d dean1943/hadoop3 /bin/bash
  #sudo docker exec -it master /bin/bash rm -f ~/.ssh/known_hosts
  sudo docker exec -it master /bin/bash /init.sh
  ```

  构建命令：
  ```Shell
  sudo sh instance.sh
  ```

### Hadoop配置文件

1. workers
  ```XML
  worker1
  worker2
  ```

2. init.sh
  ```Shell
  echo "172.17.0.2	master" >> /etc/hosts
  echo "172.17.0.3	worker1" >> /etc/hosts
  echo "172.17.0.4	worker2" >> /etc/hosts

  /bin/bash /etc/init.d/ssh start
  ```

### 构建命令

1. 启动命令

  >start-all.sh

  ```Shell
  sudo docker run -d -p 50001:6066 -p 50002:7077 -p 50003:8080 --name master -h master dean1943/hadoop3
  sudo docker run -d -p 50004:8081 --name worker1 -h worker1 dean1943/hadoop3
  sudo docker run -d -p 50005:8081 --name worker2 -h worker2 dean1943/hadoop3

  sudo docker exec -it worker1 /bin/bash /init.sh
  sudo docker exec -it worker2 /bin/bash /init.sh

  sudo docker exec -it master /bin/bash /init.sh
  sudo docker exec -it master /bin/bash /opt/hadoop/sbin/start-all.sh
  ```
2. 停止命令
  ```Shell
  sudo docker stop master worker1 worker2
  ```
