---
title: Hadoop 一
date: 2018-07-11 08:36:03
tags: [hadoop,大数据]
categories: [大数据]
---


### 简介

1. 三大组件：HDFS, MR, YARN，相互不关联
   * HDFS：存储大数据文件，可以分成多份存储，采用类似bash的命令方式管理HDFS
   * MR：用于离线数据计算，主要过程：输入->默认分割按行->进行自定义Map操作->shiffe分割->自定义reduce合并->输出
   * YARN：调度框架，根据配置进行job和资源的调度操作

2. 物理架构/逻辑架构
   * Master / Salve
   * NameNode / DataNode(N)
