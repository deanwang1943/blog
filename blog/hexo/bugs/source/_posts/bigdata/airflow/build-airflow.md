---
title: 构建Apache airflow开发环境
date: 2018-08-05 08:36:03
tags:
  - airflow
  - 大数据
  - docker
categories:
  - 大数据
---

## 构建基于Apache airflow调度开发环境

### 下载python

1. 本文基于`ubuntu 18`的版本搭建，虽然自带python考虑从新安装python到3.6.6的版本
2. 安装pyenv,使用git安装
  ```Shell
  git clone git://github.com/yyuu/pyenv.git ~/.pyenv
  ```
3. 配置pyenv
  ```Shell
  vim ~/.bashrc

  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  ```
4. 启用配置
  ```shell
  source ~/.bashrc
  ```
5. 安装python
  ```shell
  pyenv install 3.6.6
  pyenv global 3.6.6
  ```
  > 因各种原因, 下载速度可能只有几KB, 甚至超时, 可将下载地址替换成国内镜像后在下载.
  >cd  ~/.pyenv/plugins/python-build/share/python-build/
  >vim 3.6.6 (如果你下载别的版本, 你就改别的文件)

  > 将里面下载地址改成sohu的镜像地址：
  >
  >https://www.python.org/ftp/python/3.5.2/Python-3.6.6.tar.xz
  >http://mirrors.sohu.com/python/3.5.2/Python-3.6.6.tar.xz
  >
  >附搜狐镜像地址：http://mirrors.sohu.com/python/

### 安装pip

1. 使用系统安装工具安装pip
  ```Shell
  sudo apt-get install pip3
  ```
2. 配置pip的仓库地址为国内的仓库加速
  ```Shell
  mkdir ~/.pip
  touch ~/.pip/pip.config

  vim ~/.pip/pip.config

  [global]
  index-url = http://pypi.douban.com/simple
  [install]
  trusted-host=pypi.douban.com
  ```
3. 升级pip到最新版本
  ```Shell
  pip install --upgrade pip
  ```

### 安装apache airflow
1. 配置airflow，编辑/etc/profile
  ```shell
  export AIRFLOW_HOME=/home/airflow
  PATH=$PATH:$AIRFLOW_HOME
  export PATH
  ```
  > 启动 `source /etc/profile`

2. 使用pip安装apache airflow
  ```shell
  pip install apache-airflow
  ```

### 配置airflow

[默认版本]
airflow有很多个版本的，包含不同数据库的。
目前采用默认的sqllit3作为数据库为实例。

### airflow使用

1. 初始化airflow的数据库，其他版本数据库也需要先初始化后在配置再次的初始化，主要是数据库和配置文件，
  ```shell
  airflow initdb
  ```
  > 第一次执行该命令时，在/home/airflow目录下生产airflow的相关配置文件

2. 创建dags目录存储调度脚本

3. 修改airflow配置文件,默认版本sqllit3,不需要修改配置

  [MYSQL]

  `vi /home/airflow/airflow.cfg`

  配置Execotr：

  executor = CeleryExecutor

  配置元数据库

  sql_alchemy_conn = mysql://{USERNAME}:{PASSWORD}@{MYSQL_HOST}:3306/airflow

  配置Broker URL

  broker_url = amqp://guest:guest@{RABBITMQ_HOST}:5672

  配置Celery元数据库

  celery_result_backend = db+mysql://{USERNAME}:{PASSWORD}@{MYSQL_HOST}:3306/airflow

  初始化Mysql

  新建airflow数据库

  CREATE DATABASE airflow CHARACTER SET utf8 COLLATE utf8_unicode_ci;

  创建airflow用户

  grant all on airflow.* TO 'airflow'@'%' IDENTIFIED BY 'airflow';

  `airflow initdb`

4. 启动UI命令
  ```shell
  airflow webserver -p 8081
  ```

5. 定时任务
  ```Shell
  airflow scheduler
  ```

6. 监控命令
  ```Shell
  airflow worker
  ```
> 访问地址：http://ip:8081
>
> http://ip:5555  #flower位celery的监控

### airflow实例
