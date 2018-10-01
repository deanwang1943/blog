---
title: RabbitMQ之Docker构建
date: 2018-10-01 13:36:03
tags: [MQ,rabbitMQ]
categories: [MQ]
---

## RabbitMQ之Docker构建

>因为分布式项目中使用了rabbitmq的组件，故此写文关于采用官方的镜像完成基于docker的rabbitmq的搭建。

### 准备基础环境

1. 首先在系统中安装docker的相关软件，本文基于系统`ubuntu 18.04`版本构建，`docker version 17.12`
2. 安装docker，网上很多文章不载赘述

### 获取镜像

`docker pull rabbitmq:management`

### 启动实例

`docker run -d --hostname dean-rabbit -p 5671:5671 -p 5672:5672 -p 4369:4369 -p 25672:25672 -p 15671:15671 -p 15672:15672 --name dean-rabbit rabbitmq:management`

>15672端口为web ui界面默认端口，可以通过访问地址http://localhost:15671
>
>默认用户名和密码：guest/guest
