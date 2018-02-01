# HDFS操作

--------------------------------------------------------------------------------

## Java中配置hdfs

常见项目中可以使用hdfs://IP:port/path的方式访问，但是如果是集群环境下，会配置多个namenode或者second namenode，那么如何来访问hdfs的文件呢？

hadoop中一般会配置多个配置文件：

```
core-site.xml
hdfs-site.xml
mapred-site.xml
yarn-site.xml
```

默认会加载core-site.xml和yarn-site.xml, core-site.xml，当然里面所有属性也会被加载，那么hdfs中文件我们在没有配置ip和端口的情况下是无法访问的，需要手动的加载

```java
Configuration conf = new Configuration();
//  不需要在程序中指定hdfs的url，可以通过hdfs-site.xml中配置的df的域名
conf.addResource(new Path("hdfs-site.xml"));
```

> 配置文件hdfs-site.xml在class的目录下

会把所有hdfs的配置加载到conf中，在创建FileSystem对象时会将url加入进来

```java
FileSystem fs = FileSystem.get(URL.create("hdfsPath"), conf);
```

这时直接传入hdfsPath路经即可了，会自动加入url的地址。
