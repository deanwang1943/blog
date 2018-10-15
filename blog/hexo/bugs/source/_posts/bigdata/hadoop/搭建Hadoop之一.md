---
title: 搭建Hadoop之一
date: 2018-07-11 08:36:03
tags:
  - hadoop
  - 大数据
categories:
  - 大数据
---

## 设置相互访问的使用名称代替ip的配置

编辑`/etc/hostname`

```
master
```

编辑`/etc/hosts`

```
172.17.0.2 master
```

## 多服务器之间ssh免密登录配置

启动ssh服务`/etc/init.d/ssh start`

设置ssh登录配置

编辑 `/etc/ssh/sshd_config` 添加

```xml
PermitRootLogin yes
```

运行生成密码命令：

`ssh-keygen -t rsa`

回车完成密码创建

```shell
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ssh-copy-id root@slave1
```

> 使用passwd来重新设置密码
