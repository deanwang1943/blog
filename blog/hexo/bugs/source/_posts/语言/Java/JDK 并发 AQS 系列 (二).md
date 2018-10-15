---
title: JDK 并发 AQS 系列 (二)
date: 2018-10-15 08:36:03
tags: [java,面试题]
categories: [java]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5bbfeace6fb9a05d1117a644?utm_source=gold_browser_extension

## 原子性

在研究 JDK 中 AQS 时，会发现这个类很多地方都使用了 CAS 操作，在并发实现中 CAS 操作必须具备原子性，而且是硬件级别的原子性，java 被隔离在硬件之上，明显力不从心，这时为了能直接操作操作系统层面，肯定要通过用 C++ 编写的 native 本地方法来扩展实现。JDK 提供了一个类来满足 CAS 的要求，sun.misc.Unsafe，从名字上可以大概知道它用于执行低级别、不安全的操作，AQS 就是使用此类完成硬件级别的原子操作。

## Unsafe 类

Unsafe 是一个很强大的类，它可以分配内存、释放内存、可以定位对象某字段的位置、可以修改对象的字段值、可以使线程挂起、使线程恢复、可进行硬件级别原子的 CAS 操作等等。

但平时我们没有这么特殊的需求去使用它，而且必须在受信任代码（一般由 JVM 指定）中调用此类，例如直接`Unsafe unsafe = Unsafe.getUnsafe();`获取一个 Unsafe 实例是不会成功的，因为这个类的安全性很重要，设计者对其进行了如下判断，它会检测调用它的类是否由启动类加载器 Bootstrap ClassLoader（它的类加载器为 null）加载，由此保证此类只能由 JVM 指定的类使用。判断逻辑如下，

```
public static Unsafe getUnsafe() {

   Class cc = sun.reflect.Reflection.getCallerClass(2);

   if (cc.getClassLoader() != null)

       throw new SecurityException("Unsafe");

   return theUnsafe;

}
复制代码
```

## 获取 Unsafe

当然可以通过反射绕过上面的限制，用下面的 getUnsafeInstance 方法可以获取 Unsafe 实例，这段代码演示了如何获取 java 对象的相对地址偏移量及使用 Unsafe 完成 CAS 操作，最终输出的是 flag 字段的内存偏移量及 CAS 操作后的值。分别为 8 和 101。另外如果使用开发工具如 Eclipse，可能会编译通不过，只要把编译错误提示关掉即可。

```
public class UnsafeTest {

privateint flag = 100;
privatestatic long offset;
privatestatic Unsafe unsafe = null;

static{
     try{
          unsafe= getUnsafeInstance();
          offset= unsafe.objectFieldOffset(UnsafeTest.class.getDeclaredField("flag"));
     }catch (Exception e) {
          e.printStackTrace();
     }
}

publicstatic void main(String[] args) throws Exception {

     intexpect = 100;
     intupdate = 101;

     UnsafeTestunsafeTest = new UnsafeTest();
     System.out.println("unsafeTest对象的flag字段的地址偏移量为："+offset);
     unsafeTest.doSwap(offset,expect, update);
     System.out.println("CAS操作后的flag值为：" +unsafeTest.getFlag());

}

privateboolean doSwap(long offset, int expect, int update) {
     returnunsafe.compareAndSwapInt(this, offset, expect, update);
}

publicint getFlag() {
     returnflag;
}

privatestatic Unsafe getUnsafeInstance() throws SecurityException,NoSuchFieldException,IllegalArgumentException,IllegalAccessException{
     FieldtheUnsafeInstance = Unsafe.class.getDeclaredField("theUnsafe");
     theUnsafeInstance.setAccessible(true);
     return(Unsafe) theUnsafeInstance.get(Unsafe.class);
}

}
复制代码
```

Unsafe 类让我们明白了 java 是如何实现对操作系统操作的，一般我们使用 java 是不需要在内存中处理 java 对象及内存地址位置的，但有的时候我们确实需要知道 java 对象相关的地址，于是我们使用 Unsafe 类，尽管 java 对其提供了足够的安全管理。

## 总结

Java 语言的设计者们极力隐藏涉及底层操作系统的相关操作，但这里我们为了探索 AQS 的实现，不得不剖析了 Unsafe 类，因为 AQS 里面即是使用 Unsafe 获取对象字段的地址偏移量、相关原子操作来实现 CAS 操作的。
