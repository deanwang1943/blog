---
title: Python从闭包到装饰器
date: 2018-09-11 08:36:03
tags: [python]
categories: [python]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://juejin.im/post/5b93deb2f265da0a8f35a3b1?utm_source=gold_browser_extension

## 闭包

### 闭包的概念

在一个外函数中定义了一个内函数，内函数里运用了外函数的临时变量，并且外函数的返回值是内函数的引用。这样就构成了一个闭包。[1]

以下给出一个闭包的例子：

```
def outer():
    a = 10
    def inner():
        b= 10
        print(b)
        print(a)
    return inner

if __name__ == '__main__':
    inner_func = outer()
    inner_func()

  >> 10
复制代码
```

在这里 a 作为 outer 的局部变量，一般情况下会在函数结束的时候释放为 a 分配到的内存。但是在闭包中，如果外函数在结束的时候发现有自己的临时变量将来会在内部函数中用到，就把这个临时变量绑定给了内部函数，然后自己再结束。[1]

> 在 inner 中，a 是一个自由变量 (free variable). 这是一个技术术语，指未在本地作用域绑定的变量。[2]

在 python 中，__code__属性中保存着局部变量的和自由变量的名称，对于 inner 函数，其局部变量和自由变量为：

```
inner_func = outer()
inner_func.__code__.co_freevars
>> ('a',)
inner_func.__code__.co_varnames
>> ('b',)
复制代码
```

那么，既然外部函数会把内部变量要用到的变量 (即内部函数的自由变量) 绑定给内部函数，那么 a 的绑定在哪里？a 的绑定在返回函数的 inner 的__closure__属性中，其中的 cell_contents 保存着真正的值。[2]

```
inner_func.__closure__[0].cell_contents
>> 10
复制代码
```

> 综上，闭包是一种函数，它会保留定义函数时存在的自由变量的绑定，这样调用函数时，虽然定义作用域不可用了，但是仍能使用那些绑定。[2]

### 更进一步

当我们尝试在 inner 改变 a 的值的时候

```
def outer():
    a = 10

    def inner():
        # nonlocal a
        b = 10
        print(b)
        a += 1
        print(a)
    return inner

if __name__ == '__main__':
    inner_func = outer()
    inner_func()

>> UnboundLocalError: local variable 'a' referenced before assignment
复制代码
```

之所以会出现这个错误的关键在于：当 a 是数字或任何不可变类型时，a += 1 等价于 a = a+1，这会把 a 变为局部变量。对于不可变类型如数字，字符串，元组来说，**只能读取，不能更新**。在 a += 1 中，等价于于 a = a + 1，这里隐式创建了一个局部变量 a，这样 a 就不再是自由变量了，也不存在在闭包中了。

解决方法：加入 nonlocal 声明。它的作用是把变量标记为自由变量，这样即使在函数中为变量赋予新值，也会变成自由变量。

```
def outer():
    a = 10

    def inner():
        nonlocal a
        b = 10
        print(b)
        a += 1
        print(a)
    return inner

if __name__ == '__main__':
    inner_func = outer()
    inner_func()
>> 10
   11
复制代码
```

BINGO!

## 装饰器

在装饰器这一部分主要讲解以下几种情形：

*   函数装饰器

*   类装饰器

*   装饰器链

*   带参数的装饰器

### 装饰器的作用

装饰器本质上是一个 Python 函数或类，它可以让其他函数或类在不需要做任何代码修改的前提下增加额外功能，装饰器的返回值也是一个函数 / 类对象。它经常用于有切面需求的场景，比如：插入日志、性能测试、事务处理、缓存、权限校验等场景，装饰器是解决这类问题的绝佳设计。有了装饰器，我们就可以抽离出大量与函数功能本身无关的雷同代码到装饰器中并继续重用。[3]

在网上，各种用的比较多的案例的是，如果我们有非常多的函数，我们现在希望统计每一个函数的运行时间以及打印其参数应该怎么做。

比较智障的方法是: 修改函数原来的内容，加上统计时间的代码和打印参数代码。但结合前面的闭包的知识，我们应该可以提出这样一种方法

```
def count_time(func):
    def wrapper(*args, **kwargs):
        tic = time.clock()
        func(*args, **kwargs)
        toc = time.clock()
        print('函数 %s 的运行时间为 %.4f' %(func.__name__, toc-tic))
        print('参数为:'+str(args)+str(kwargs))
    return wrapper

def test_func(*args, **kwargs):
    time.sleep(1)

if __name__ == '__main__':
    f = count_time(test_func)
    f(['hello', 'world'], hello=1, world=2)
复制代码
```

在这里 func 会绑定给 wrapper 函数，所以即使 count_time 函数结束了，其中传入的 func 也会绑定给 wrapper. 下述代码可验证之。

```
f.__code__.co_freevars
>> ('func',)
f.__closure__[0].cell_contents
>> <function test_func at 0x0000014234165AE8>
复制代码
```

而上述的代码就是 python 装饰器的原理，只不过在我们可以使用 `@`语法糖简化代码。

```
def count_time(func):
    def wrapper(*args, **kwargs):
        tic = time.clock()
        func(*args, **kwargs)
        toc = time.clock()
        print('函数 %s 的运行时间为 %.4f' %(func.__name__, toc-tic))
        print('参数为:'+str(args)+str(kwargs))
    return wrapper

@count_time
def test_func(*args, **kwargs):
    time.sleep(1)

if __name__ == '__main__':
    test_func(['hello', 'world'], hello=1, world=2)

>> 函数 test_func 的运行时间为 1.9999
    参数为:(['hello', 'world'],){'hello': 1, 'world': 2}

复制代码
```

一个函数同样也可以被多个装饰器装饰，其原理于单个装饰器相同。重要的是理解装饰器实际上的调用顺序。

```
def count_time(func):
    print('count_time_func')

    def wrapper_in_count_time(*args, **kwargs):
        tic = time.clock()
        func(*args, **kwargs)
        toc = time.clock()
        running_time = toc - tic
        print('函数 %s 运行时间 %f'% (func.__name__, running_time))
    return wrapper_in_count_time

def show_args(func):
    print('show_args func')

    def wrapper_in_show_args(*args, **kwargs):
        print('函数参数为'+str(args)+str(kwargs))
        return func()
    return wrapper_in_show_args

@count_time
@show_args
def test_func(*args, **kwargs):
    print('test_func')

if __name__ == '__main__':
    f = test_func(['hello', 'world'], hello=1, world=2)

>> show_args func
    count_time_func
    函数参数为(['hello', 'world'],){'hello': 1, 'world': 2}
    test_func
    函数 wrapper_in_show_args 运行时间 0.000025
复制代码
```

先忽视 @count_time 装饰器，假如只有 @show_args 装饰器。 那么，装饰器背后其实是这样的:

```
f = show_args(test func)
f(...)

# 加上@count_time后
f = show_args(test func)
g = count_time(f)
g(...)
复制代码
```

我们可以打印下 f,g 看下返回的是什么。

```
f.__name__
>> wrapper_in_show_args
g.__name__
>> wrapper_in_count_time
复制代码
```

所以整个函数的运行流程是： 首先调用了 show_args，show_args 打印了'show_args_func', 之后返回 wrapper_in_show_args。接着调用 count_time, 并把 wrapper_in_show_args 传给了 count_time，首先打印'count_time_func', 之后返回 wrapper_in_count_time. 最后用户调用 wrapper_in_count_time 函数，并传入了相关参数。在 wrapper_in_count_time 函数里，首先调用了 func 函数，这里的 func 是一个自由变量，即之前传入的 wrapper_in_show_args, 所以打印函数参数。在 wrapper_in_show_args 里，调用了 func(), 这里的 func 又是之前传入的 test_func，所以打印'test_func'。最后打印函数运行时间，整个调用过程结束。

总而言之，装饰器的核心就是**闭包**, 只要理解了闭包，就能理解透彻装饰器。

另外装饰器不仅可以是函数，还可以是类，相比函数装饰器，类装饰器具有灵活度大、高内聚、封装性等优点。使用类装饰器主要依靠类的__call__方法，当使用 @ 形式将装饰器附加到函数上时，就会调用此方法。[3]

```
class deco_class(object):
    def __init__(self, func):
        self.func = func

    def __call__(self, *args, **kwargs):
        print('初始化装饰器')
        self.func(*args, **kwargs)
        print('中止装饰器')

@deco_class
def klass(*args, **kwargs):
    print(args, kwargs)

if __name__ == '__main__':
    klass(['hello', 'world'], hello=1, world=2)
>> 初始化装饰器
    (['hello', 'world'],) {'hello': 1, 'world': 2}
    中止装饰器
复制代码
```

## 参考资料

[1] [www.cnblogs.com/Lin-Yi/p/73…](https://link.juejin.im?target=https%3A%2F%2Fwww.cnblogs.com%2FLin-Yi%2Fp%2F7305364.html)

[2] Fluent Python, Luciano Ramalho

[3] [foofish.net/python-deco…](https://link.juejin.im?target=https%3A%2F%2Ffoofish.net%2Fpython-decorator.html)

[4] [blog.apcelent.com/python-deco…](https://link.juejin.im?target=https%3A%2F%2Fblog.apcelent.com%2Fpython-decorator-tutorial-with-example.html)
