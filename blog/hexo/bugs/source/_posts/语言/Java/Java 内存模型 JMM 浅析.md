---
title: Java 内存模型 JMM 浅析
date: 2018-10-11 16:36:03
tags: [java]
categories: [java]
---
> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://liuzhengyang.github.io/2017/05/12/javamemorymodel/

# [](#JMM简介 "JMM简介")JMM 简介

Java Memory Model 简称 JMM, 是一系列的 Java 虚拟机平台对开发者提供的多线程环境下的内存可见性、是否可以重排序等问题的无关具体平台的统一的保证。(可能在术语上与 Java 运行时内存分布有歧义，后者指堆、方法区、线程栈等内存区域)。
并发编程有多种风格，除了 CSP(通信顺序进程)、Actor 等模型外，大家最熟悉的应该是基于线程和锁的共享内存模型了。在多线程编程中，需要注意三类并发问题:

1.  原子性
2.  可见性
3.  重排序
    原子性涉及到，一个线程执行一个复合操作的时候，其他线程是否能够看到中间的状态、或进行干扰。典型的就是 i++ 的问题了，两个线程同时对共享的堆内存执行 ++ 操作，而 ++ 操作在 JVM、运行时、CPU 中的实现都可能是一个复合操作, 例如在 JVM 指令的角度来看是将 i 的值从堆内存读到操作数栈、加上一、再写回到堆内存的 i，这几个操作的期间，如果没有正确的同步，其他线程也可以同时执行，可能导致数据丢失等问题。常见的原子性问题又叫竞太条件，是基于一个可能失效的结果进行判断，如读取 - 修改 - 写入。<a id="more"></a> 可见性和重排序问题都源于系统的优化。
    简单说重排序就是程序实际执行的顺序和程序中的顺序不一致。
    由于 CPU 的执行速度和内存的存取速度严重不匹配，为了优化性能，基于时间局部性、空间局部性等局部性原理，CPU 在和内存间增加了多层高速缓存，当需要取数据时，CPU 会先到高速缓存中查找对应的缓存是否存在，存在则直接返回，如果不存在则到内存中取出并保存在高速缓存中。现在多核处理器越基本已经成为标配，这时每个处理器都有自己的缓存，这就涉及到了缓存一致性的问题，CPU 有不同强弱的一致性模型，最强的一致性安全性最高，也符合我们的顺序思考的模式，但是在性能上因为需要不同 CPU 之间的协调通信就会有很多开销
    典型的 CPU 缓存结构示意图如下
    [![](https://liuzhengyang.github.io/images/cpu-arch.jpg)](/images/cpu-arch.jpg)
    CPU 的指令周期通常为取指令、解析指令读取数据、执行指令、数据写回寄存器或内存。串行执行指令时其中的读取存储数据部分占用时间较长，所以 CPU 普遍采取指令流水线的方式同时执行多个指令, 提高整体吞吐率，就像工厂流水线一样。
    [![](https://liuzhengyang.github.io/images/instruction-pipeline.jpg)](/images/instruction-pipeline.jpg)
    读取数据和写回数据到内存相比执行指令的速度不在一个数量级上，所以 CPU 使用寄存器、高速缓存作为缓存和缓冲，在从内存中读取数据时，会读取一个缓存行 (cache line) 的数据（类似磁盘读取读取一个 block）。数据写回的模块在旧数据没有在缓存中的情况下会将存储请求放入一个 store buffer 中继续执行指令周期的下一个阶段，如果存在于缓存中则会更新缓存，缓存中的数据会根据一定策略 flush 到内存。(可以用 git 模型类比理解缓存间的同步)

    |

    <pre>12345678910111213141516171819</pre>

     |

    <pre>public class MemoryModel {    private int count;    private boolean stop;    public void initCountAndStop() {        count = 1;        stop = false;    }    public void doLoop() {        while(!stop) {            count++;        }    }    public void printResult() {        System.out.println(count);        System.out.println(stop);    }}</pre>

     |

上面这段代码执行时我们可能认为`count = 1`会在`stop = false`前执行完成，这在上面的 CPU 执行图中显示的理想状态下是正确的，但是要考虑上寄存器、缓存缓冲的时候就不正确了, 例如 stop 本身在缓存中但是 count 不在，则可能 stop 更新后再 count 的 write buffer 写回之前刷新到了内存。
另外 CPU、编译器（对于 Java 一般指 JIT）都可能会修改指令执行顺序，例如上述代码中 count = 1 和 stop = false 两者并没有依赖关系，所以 CPU、编译器都有可能修改这两者的顺序，而在单线程执行的程序看来结果是一样的，这也是 CPU、编译器要保证的 as-if-sequantial(不管如何修改执行顺序，单线程的执行结果不变)。由于很大部分程序执行都是单线程的，所以这样的优化是可以接受并且带来了较大的性能提升。但是在多线程的情况下，如果没有进行必要的同步操作则可能会出现令人意想不到的结果。例如在线程 T1 执行完 initCountAndStop 方法后，线程 T2 执行 printResult，得到的可能是 0, false, 可能是 1, false, 也可能是 0, true。如果线程 T1 先执行 doLoop()，线程 T2 一秒后执行 initCountAndStop, 则 T1 可能会跳出循环、也可能由于编译器的优化永远无法看到 stop 的修改。
由于上述这些多线程情况下的各种问题，多线程中的程序顺序已经不是底层机制中的执行顺序和结果，编程语言需要给开发者一种保证，这个保证简单来说就是一个线程的修改何时对其他线程可见，因此 Java 语言提出了 JavaMemoryModel 即 Java 内存模型，对于 Java 语言、JVM、编译器等实现者需要按照这个模型的约定来进行实现。Java 提供了 volatile、synchronized、final 等机制来帮助开发者保证多线程程序在所有处理器平台上的正确性。

在 JDK1.5 之前，Java 的内存模型有着严重的问题，例如在旧的内存模型中，一个线程可能在构造器执行完成后看到一个 final 字段的默认值、volatile 字段的写入可能会和非 volatile 字段的读写重排序。
所以在 JDK1.5 中，通过 JSR133 提出了新的内存模型，修复之前出现的问题。

# [](#重排序规则 "重排序规则")重排序规则

## [](#volatile和监视器锁 "volatile和监视器锁")volatile 和监视器锁

| 是否可以重排序 | 第二个操作 | 第二个操作 | 第二个操作 |
| --- | --- | --- | --- |
| 第一个操作 | 普通读 / 普通写 | volatile 读 / monitor enter | volatile 写 / monitor exit |
| 普通读 / 普通写 |  |  | No |
| voaltile 读 / monitor enter | No | No | No |
| volatile 写 / monitor exit |  | No | No |

其中普通读指 getfield, getstatic, 非 volatile 数组的 arrayload, 普通写指 putfield, putstatic, 非 volatile 数组的 arraystore。
volatile 读写分别是 volatile 字段的 getfield, getstatic 和 putfield, putstatic。
monitorenter 是进入同步块或同步方法, monitorexist 指退出同步块或同步方法。
上述表格中的 No 指先后两个操作不允许重排序，如 (普通写, volatile 写) 指非 volatile 字段的写入不能和之后任意的 volatile 字段的写入重排序。当没有 No 时，说明重排序是允许的，但是 JVM 需要保证最小安全性 - 读取的值要么是默认值，要么是其他线程写入的（64 位的 double 和 long 读写操作是个特例，当没有 volatile 修饰时，并不能保证读写是原子的，底层可能将其拆分为两个单独的操作）。

## [](#final字段 "final字段")final 字段

final 字段有两个额外的特殊规则

1.  final 字段的写入（在构造器中进行）以及 final 字段对象本身的引用的写入都不能和后续的（构造器外的）持有该 final 字段的对象的写入重排序。例如, 下面的语句是不能重排序的

    |

    <pre>1</pre>

     |

    <pre>x.finalField = v; ...; sharedRef = x;</pre>

     |

2.  final 字段的第一次加载不能和持有这个 final 字段的对象的写入重排序，例如下面的语句是不允许重排序的

    |

    <pre>1</pre>

     |

    <pre>x = sharedRef; ...; i = x.finalField</pre>

     |

## [](#内存屏障 "内存屏障")内存屏障

处理器都支持一定的内存屏障 (memory barrier) 或栅栏 (fence) 来控制重排序和数据在不同的处理器间的可见性。将 CPU 和内存间的数据存取操作分为`load`和`store`。例如，CPU 将数据写回时，会将 store 请求放入 write buffer 中等待 flush 到内存，可以通过插入 barrier 的方式防止这个 store 请求与其他的请求重排序、保证数据的可见性。可以用一个生活中的例子类比屏障，例如坐地铁的斜坡式电梯时，大家按顺序进入电梯，但是会有一些人从左侧绕过去，这样出电梯时顺序就不相同了，如果有一个人携带了一个大的行李堵住了（屏障），则后面的人就不能绕过去了:)。另外这里的 barrier 和 GC 中用到的 write barrier 是不同的概念。

### [](#内存屏障的分类 "内存屏障的分类")内存屏障的分类

几乎所有的处理器都支持一定粗粒度的 barrier 指令，通常叫做 Fence(栅栏、围墙)，能够保证在 fence 之前发起的 load 和 store 指令都能严格的和 fence 之后的 load 和 store 保持有序。通常按照用途会分为下面四种 barrier

#### [](#LoadLoad-Barriers "LoadLoad Barriers")LoadLoad Barriers

Load1; LoadLoad; Load2;
保证 Load1 的数据在 Load2 及之后的 load 前加载

#### [](#StoreStore-Barriers "StoreStore Barriers")StoreStore Barriers

Store1; StoreStore; Store2
保证 Store1 的数据先于 Store2 及之后的数据 在其他处理器可见

#### [](#LoadStore-Barriers "LoadStore Barriers")LoadStore Barriers

Load1; LoadStore; Store2
保证 Load1 的数据的加载在 Store2 和之后 Store 的数据 flush 前

#### [](#StoreLoad-Barriers "StoreLoad Barriers")StoreLoad Barriers

Store1; StoreLoad; Load2
保证 Store1 的数据在其他处理器前可见 (如 flush 到内存) 先于 Load2 和之后的 load 的数据的加载。StoreLoad Barrier 能够防止 load 读取到 Store1 的旧数据而不是最近其他处理器写入的数据，例如 Store1 的写入在 Write Buffer 中, Load2 可能直接从 Write Buffer 中读取了 Store1 的值而不是其他处理器中可能的最新值。
几乎近代的所有的多处理器都需要 StoreLoad，StoreLoad 的开销通常是最大的，并且 StoreLoad 具有其他三种屏障的效果，所以 StoreLoad 可以当做一个通用的 (但是更高开销的) 屏障。

所以，利用上述的内存屏障，可以实现上面表格中的重排序规则

| 需要的屏障 | 第二个操作 | 第二个操作 | 第二个操作 | 第二个操作 |
| --- | --- | --- | --- | --- |
| 第一个操作 | 普通读 | 普通写 | volatile 读 / monitor enter | volatile 写 / monitor exit |
| 普通读 |  |  |  | LoadStore |
| 普通读 |  |  |  | StoreStore |
| voaltile 读 / monitor enter | LoadLoad | LoadStore | LoadLoad | LoadStore |
| volatile 写 / monitor exit |  |  | StoreLoad | StoreStore |

为了支持 final 字段的规则，需要对 final 的写入增加 barrier
x.finalField = v; StoreStore; sharedRef = x;

### [](#插入内存屏障 "插入内存屏障")插入内存屏障

单处理器上由于会保证透明的顺序一致性，所以并不需要明确的插入内存屏障。
在多处理器情况下，基于上面的规则，可以在 volatile 字段、synchronized 关键字的处理上增加屏障来满足内存模型的规则。
最保守的策略是在 volatile 的前后都加上所有的屏障，但是这样在大多数情况都是不必要且重复的，所以再以 volatile 字段通常读多写少的假设，可以得出以下一种策略供编译器开发者参考:

1.  volatile store 前插入 LoadStore;StoreStore 屏障
2.  所有 final 字段写入后但在构造器返回前插入 StoreStore
3.  volatile store 后插入 StoreLoad 屏障
4.  在 volatile load 后插入 LoadLoad 和 LoadStore 屏障
5.  monitor enter 和 volatile load 规则一致，monitor exit 和 volatile store 规则一致。

### [](#x86-64处理器 "x86/64处理器")x86/64 处理器

x86 处理器架构下，只需要插入 StoreLoad 屏障, 另外 JDK9 种的 Unsafe 类提供了新的 loadFence、storeFence 和 fullFence 方法。
可以看下 openjdk9 中的 templateTable_x86.cpp 和 assembler_x86.hpp。
x86 中通过`lock; addl $0,0(%%esp)`这样的空操作来实现 StoreLoad

|

<pre>12345678910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364656667686970717273747576</pre>

 |

<pre>templateTable_x86.cppvoid TemplateTable::volatile_barrier(Assembler::Membar_mask_bits order_constraint ) {  // Helper function to insert a is-volatile test and memory barrier  if(!os::is_MP()) return;    // Not needed on single CPU  __ membar(order_constraint);}assembler_x86.hpp// Serializes memory and blows flags  void membar(Membar_mask_bits order_constraint) {    if (os::is_MP()) {      // We only have to handle StoreLoad      if (order_constraint & StoreLoad) {        // All usable chips support "locked" instructions which suffice        // as barriers, and are much faster than the alternative of        // using cpuid instruction. We use here a locked add [esp-C],0\.        // This is conveniently otherwise a no-op except for blowing        // flags, and introducing a false dependency on target memory        // location. We can't do anything with flags, but we can avoid        // memory dependencies in the current method by locked-adding        // somewhere else on the stack. Doing [esp+C] will collide with        // something on stack in current method, hence we go for [esp-C].        // It is convenient since it is almost always in data cache, for        // any small C.  We need to step back from SP to avoid data        // dependencies with other things on below SP (callee-saves, for        // example). Without a clear way to figure out the minimal safe        // distance from SP, it makes sense to step back the complete        // cache line, as this will also avoid possible second-order effects        // with locked ops against the cache line. Our choice of offset        // is bounded by x86 operand encoding, which should stay within        // [-128; +127] to have the 8-byte displacement encoding.        //        // Any change to this code may need to revisit other places in        // the code where this idiom is used, in particular the        // orderAccess code.        int offset = -VM_Version::L1_line_size();        if (offset < -128) {          offset = -128;        }        lock();  lock前缀        addl(Address(rsp, offset), 0);// Assert the lock# signal here  addl $0,0(%%esp)      }    }  }orderAccess_linux_x86.inline.hpp  // Compiler version last used for testing: gcc 4.8.2// Please update this information when this file changes// Implementation of class OrderAccess.// A compiler barrier, forcing the C++ compiler to invalidate all memory assumptionsstatic inline void compiler_barrier() {  __asm__ volatile ("" : : : "memory");}inline void OrderAccess::loadload()   { compiler_barrier(); }inline void OrderAccess::storestore() { compiler_barrier(); }inline void OrderAccess::loadstore()  { compiler_barrier(); }inline void OrderAccess::storeload()  { fence();            }inline void OrderAccess::acquire()    { compiler_barrier(); }inline void OrderAccess::release()    { compiler_barrier(); }inline void OrderAccess::fence() {  if (os::is_MP()) {    // always use locked addl since mfence is sometimes expensive#ifdef AMD64    __asm__ volatile ("lock; addl $0,0(%%rsp)" : : : "cc", "memory");#else    __asm__ volatile ("lock; addl $0,0(%%esp)" : : : "cc", "memory");#endif  }  compiler_barrier();}</pre>

 |

# [](#Happens-Before "Happens-Before")Happens-Before

前面提到的各种内存屏障对应开发者来说还是比较复杂底层，因此 JMM 又可以使用一系列 Happens-Before 的偏序关系的规则方式来说明，要想保证执行操作 B 的线程看到操作 A 的结果（无论 A 和 B 是否在同一个线程中执行), 那么在 A 和 B 之间必须要满足 Happens-Before 关系，否则 JVM 可以对它们任意重排序。

> Two actions can be ordered by a happens-before relationship. If one action happens-before another, then the first is visible to and ordered before the second.
> Happens-Before 术语来自于 Lamport 的”Time, Clocks and the Ordering of Events in a Distributed System” 论文，用于描述分布式环境中发生的事件的偏序关系，偏序是指 A Happens-Before B, A Happens-Before C，但是 B 和 C 不一定具有 Happens-Before 关系。

## [](#Happens-Before规则列表 "Happens-Before规则列表")Happens-Before 规则列表

HappendBefore 规则包括

1.  程序顺序规则: 如果程序中操作 A 在操作 B 之前，那么同一个线程中操作 A 将在操作 B 之前进行
2.  监视器锁规则: 在监视器锁上的锁操作必须在同一个监视器锁上的加锁操作之前执行
3.  volatile 变量规则: volatile 变量的写入操作必须在该变量的读操作之前执行
4.  线程启动规则: 在线程上对 Thread.start 的调用必须在该线程中执行任何操作之前执行
5.  线程结束规则: 线程中的任何操作都必须在其他线程检测到该线程已经结束之前执行
6.  中断规则: 当一个线程在另一个线程上调用 interrupt 时，必须在被中断线程检测到 interrupt 之前执行
7.  传递性: 如果操作 A 在操作 B 之前执行，并且操作 B 在操作 C 之前执行，那么操作 A 在操作 C 之前执行。

其中显示锁与监视器锁有相同的内存语义，原子变量与 volatile 有相同的内存语义。锁的获取和释放、volatile 变量的读取和写入操作满足全序关系，所以可以使用 volatile 的写入在后续的 volatile 的读取之前进行。
可以利用上述 Happens-Before 的多个规则进行组合。
例如线程 A 进入监视器锁后，在释放监视器锁之前的操作根据程序顺序规则 Happens-Before 于监视器释放操作，而监视器释放操作 Happens-Before 于后续的线程 B 的对相同监视器锁的获取操作，获取操作 Happens-Before 与线程 B 中的操作。

# [](#总结 "总结")总结

上面说了那么多，如果要用几句话总结的话：

1.  JMM 是 Java 程序对线程如何交互的统一的约定协议
2.  Happens-Before 顺序: 保证了一个线程的操作结果能够对另一个线程可见
3.  `synchronized`关键字提供互斥区和内存可见性, 防止重排序
4.  `volatile`提供内存可见性, 防止重排序，保证 64 位元素 (double、long) 的原子性读写

# [](#更多参考 "更多参考")更多参考

*   [http://gee.cs.oswego.edu/dl/jmm/cookbook.html](http://gee.cs.oswego.edu/dl/jmm/cookbook.html)
*   《Java Concurrency in practice》
*   [https://www.cs.umd.edu/~pugh/java/memoryModel/jsr-133-faq.html](https://www.cs.umd.edu/~pugh/java/memoryModel/jsr-133-faq.html)
*   [https://en.wikipedia.org/wiki/Java_memory_model](https://en.wikipedia.org/wiki/Java_memory_model)
*   [https://en.wikipedia.org/wiki/Happened-before](https://en.wikipedia.org/wiki/Happened-before)
*   [https://zeroturnaround.com/rebellabs/java-memory-model-pragmatics-by-aleksey-shipilev/](https://zeroturnaround.com/rebellabs/java-memory-model-pragmatics-by-aleksey-shipilev/)
*   [https://dzone.com/articles/java-memory-model-programer%E2%80%99s](https://dzone.com/articles/java-memory-model-programer%E2%80%99s)
*   [http://www.cs.umd.edu/~pugh/java/memoryModel/Dagstuhl.pdf](http://www.cs.umd.edu/~pugh/java/memoryModel/Dagstuhl.pdf)
*   [https://shipilev.net/blog/2014/jmm-pragmatics/](https://shipilev.net/blog/2014/jmm-pragmatics/)
*   [https://www.youtube.com/watch?v=TxqsKzxyySo](https://www.youtube.com/watch?v=TxqsKzxyySo)
*   [http://tutorials.jenkov.com/java-concurrency/java-memory-model.html](http://tutorials.jenkov.com/java-concurrency/java-memory-model.html)
*   [http://gee.cs.oswego.edu/dl/cpj/jmm.html](http://gee.cs.oswego.edu/dl/cpj/jmm.html)
*   [http://www.cs.umd.edu/~pugh/java/memoryModel/](http://www.cs.umd.edu/~pugh/java/memoryModel/)
*   [http://www.cs.umd.edu/~pugh/java/memoryModel/jsr133.pdf](http://www.cs.umd.edu/~pugh/java/memoryModel/jsr133.pdf)
*   [http://docs.oracle.com/javase/specs/jls/se8/html/jls-17.html#jls-17.4.2](http://docs.oracle.com/javase/specs/jls/se8/html/jls-17.html#jls-17.4.2)
*   [http://preshing.com/20120913/acquire-and-release-semantics/](http://preshing.com/20120913/acquire-and-release-semantics/)
*   [https://shipilev.net/blog/2014/on-the-fence-with-dependencies/](https://shipilev.net/blog/2014/on-the-fence-with-dependencies/)
*   [https://www.slideshare.net/frogd/cpu-cache-and-memory-ordering?ref=http://hedengcheng.com/?paged=2](https://www.slideshare.net/frogd/cpu-cache-and-memory-ordering?ref=http://hedengcheng.com/?paged=2)
