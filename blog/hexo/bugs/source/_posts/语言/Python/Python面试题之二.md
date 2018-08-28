---
title: Python面试题之二
date: 2018-08-28 08:36:03
tags: [Python，面试题]
categories: [Python]
---

### Q1. Python支持什么数据类型？
这是最基本的Python面试问题。
Python支持5种数据类型：
1. Numbers（数字）——用于保存数值
```python
>>> a=7.0
>>>
```
2. Strings（字符串）——字符串是一个字符序列。我们用单引号或双引号来声明字符串。
```python
>>> title="Ayushi's Book"
```
3. Lists（列表）——列表就是一些值的有序集合，我们用方括号声明列表。
```python
>>> colors=['red','green','blue']
>>> type(colors)
 <class 'list'>
```
4. Tuples（元组）——元组和列表一样，也是一些值的有序集合，区别是元组是不可变的，意味着我们无法改变元组内的值。
```python
>>> name=('Ayushi','Sharma')
>>> name[0]='Avery'
Traceback (most recent call last):
File "<pyshell#129>", line 1, in <module>
name[0]='Avery'
```
>TypeError：‘tuple’ 对象不支持数据项分配
5. Dictionary（字典）——字典是一种数据结构，含有键值对。我们用大括号声明字典。
```python
>>> squares={1:1,2:4,3:9,4:16,5:25}
>>> type(squares)
<class 'dict'>
>>> type({})
<class 'dict'>
```
我们还可以使用字典引导式：
```python
>>> squares={x:x**2 for x in range(1,6)}
>>> squares
{1: 1, 2: 4, 3: 9, 4: 16, 5: 25}
```

### Q2. docstring是什么？
Docstring是一种文档字符串，用于解释构造的作用。我们在函数、类或方法中将它放在首位来描述其作用。我们用三个单引号或双引号来声明docstring。
```python
>>> def sayhi():
    """
用该函数打印Hi
"""
  print("Hi")   
>>> sayhi()

Hi
```
要想获取一个函数的docstring，我们使用它的_doc_属性。
要想获取一个函数的docstring，我们使用它的_doc_属性。
```python
>>> sayhi.__doc__
‘\n\tThis function prints Hi\n\t’
```
和注释不同，docstring在运行时会保留下来。

### Q3. PYTHONPATH变量是什么？
PYTHONPATH是Python中一个重要的环境变量，用于在导入模块的时候搜索路径。因此它必须包含Python源库目录以及含有Python源代码的目录。你可以手动设置PYTHONPATH，但通常Python安装程序会把它呈现出来。

从Q 4到Q 20 都是Python面试基础题，是Python新手面试时常出现的问题。

### Q4. 什么是切片？
切片是Python中的一种方法，能让我们只检索列表、元素或字符串的一部分。在切片时，我们使用切片操作符[]。
```python
>>> (1,2,3,4,5)[2:4]
(3, 4)

>>> [7,6,8,5,9][2:]
[8, 5, 9]

>>> 'Hello'[:-1]
‘Hell’
```

### Q5. 什么是namedtuple ？
Namedtuple能让我们用名称/标签获取一个元组的元素，这里我们使用函数namedtuple()，将其从collections模块中导入。
```python
>>> from collections import namedtuple
>>> result=namedtuple('result','Physics Chemistry Maths') #format
>>> Ayushi=result(Physics=86,Chemistry=95,Maths=86) #declaring the tuple
>>> Ayushi.Chemistry

95
```
如上所示，它能让我们用对象Ayushi的Chemistry属性获取Chemistry中的符号。
更多关于namedtuples的知识，参考这里。

### Q6. 在Python中如何声明一条注释？
和C++等编程语言不同，Python并没有多行注释，只有散列字符（#）。在符号#后的内容都被视作注释，解释器会自动将其忽略。
```python
>>> #注释行1
>>> #注释行2
```
实际上你可以在代码中任何位置插入注释，用以解释代码。
### Q7. 在Python中怎样将字符串转换为整型变量？
如果字符串只含有数字字符，可以用函数int()将其转换为整数。
```python
>>> int('227')
227
```
我们检查一下变量类型：
```python
>>> type('227')
<class 'str'>
>>> type(int('227'))
<class 'int'>
```

### Q8. 在Python中怎样获取输入？
我们用函数input()从用户那里获取输入。在Python 2中，我们还有另一个函数raw_input()。
比如input()将文本获取为参数值展现出来：

`>>> a=input('Enter a number')`

输入数字7

但是如果你多加注意，会发现它以字符串形式获取输入。
```python
>>> type(a)
<class 'str'>
```
将之乘以2能得到：
```python
>>> a*=2
>>> a
’77’
```
那么如果需要使用整数时呢？

我们使用int()函数。
```Python
>>> a=int(input('Enter a number'))
```
输入数字7.
现在当我们将之乘以2就会得到：
```python
>>> a*=2
>>> a

14
```

### Q9. Python中的不可变集合（frozenset）是什么？
我们举例来回答此类Python面试问题。
首先，我们讨论一下什么是集合。集合就是一系列数据项的合集，不存在任何副本。另外，集合是无序的。
```python
>>> myset={1,3,2,2}
>>> myset
{1, 2, 3}
```
这就意味着我们无法索引它。
```python
>>> myset[0]
Traceback (most recent call last):
File "<pyshell#197>", line 1, in <module>
myset[0]
```
>TypeError：‘set’不支持索引。

不过，集合是可变的。而不可变集合却不可变，这意味着我们无法改变它的值，从而也使其无法作为字典的键值。
```python
>>> myset=frozenset([1,3,2,2])
>>> myset
frozenset({1, 2, 3})
>>> type(myset)
<class 'frozenset'>
```
更多关于集合的内容，查看这里。

### Q 10. 在Python中如何生成一个随机数？
要想生成随机数，我们可以从random模块中导入函数random()。
```python
>>> from random import random
>>> random()
0.7931961644126482
```
这里我们调用help函数。
`>>> help(random)`

关于内置函数random的help运行结果：
```python
random(…) method of random.Random instance
random() -> x in the interval [0, 1).
```
这意味着random()会返回一个大于等于0且小于1 的随机数。
我们还可以使用函数randint()，它会用两个参数表示一个区间，返回该区间内的一个随机整数。
```python
>>> from random import randint
>>> randint(2,7)
6

>>> randint(2,7)
5

>>> randint(2,7)
7

>>> randint(2,7)
6
```

### Q11. 怎样将字符串中第一个字母大写？
最简单的方法就是用capitalize()方法。
```python
>>> 'ayushi'.capitalize()
‘Ayushi’
>>> type(str.capitalize)
<class 'method_descriptor'>
```
不过这也会让其它字母变为大写。
```Python
>>> '@yushi'.capitalize()
‘@yushi’
```
### Q 12. 如何检查字符串中所有的字符都为字母数字？
对于这个问题，我们可以使用isalnum()方法。
```python
>>> 'Ayushi123'.isalnum()
True

>>> 'Ayushi123!'.isalnum()
False
```
我们还可以用其它一些方法：
```python
>>> '123.3'.isdigit()
False

>>> '123'.isnumeric()
True

>>> 'ayushi'.islower()
True

>>> 'Ayushi'.isupper()
False

>>> 'Ayushi'.istitle()
True

>>> '   '.isspace()
True

>>> '123F'.isdecimal()
False
```
### Q13. 什么是Python中的连接（concatenation）？
Python中的连接就是将两个序列连在一起，我们使用+运算符完成。
```python
>>> '32'+'32'
‘3232’

>>> [1,2,3]+[4,5,6]
[1, 2, 3, 4, 5, 6]

>>> (2,3)+(4)
Traceback (most recent call last):
File "<pyshell#256>", line 1, in <module>
(2,3)+(4)
```
>TypeError：只能将元组（不是“整数”）连接到元组。

这里4被看作一个整数，我们再来一次。
```python
>>> (2,3)+(4,)
(2, 3, 4)
```
### Q14. 什么是函数？
当我们想执行一系列语句时，我们可以为其赋予一个名字。我们来定义一个函数，让它取两个数返回一个更大的数。
```python
>>> def greater(a,b):
返回 a if a>b else b
>>> greater(3,3.5)
3.5
```
你可以自己创建函数，也可以使用Python的很多内置函数，看这里。
### Q15. 解释拉姆达表达式，什么时候会用到它？

如果我们需要一个只有单一表达式的函数，我们可以匿名定义它。拉姆达表达式通常是在需要一个函数，但是又不想费神去命名一个函数的场合下使用，也就是指匿名函数。
假如我们想将上面Q 14中的函数定义为拉姆达表达式，可以在解释器中输入如下代码：
```python
>>> (lambda a,b:a if a>b else b)(3,3.5)
3.5
```
这里，a和b都是输入，a if a>b else b就是返回的输入，参数为3和3.5.
当然，也有可能没有任何输入。
```python
>>> (lambda :print("Hi"))()
Hi
```
更多关于拉姆达表达式的内容，参考这里。

### Q16. 什么是递归？
在调用一个函数的过程中，直接或间接地调用了函数本身这个就叫递归。但为了避免出现死循环，必须要有一个结束条件，举个例子：
```python
>>> def facto(n):
    if n==1: return 1
    return n*facto(n-1)
>>> facto(4)
24```

### Q17. 什么是生成器？
生成器会生成一系列的值用于迭代，这样看它又是一种可迭代对象。它是在for循环的过程中不断计算出下一个元素，并在适当的条件结束for循环。
我们定义一个能逐个“yield”值的函数，然后用一个for循环来迭代它。
```python
>>> def squares(n):
    i=1
    while(i<=n):
        yield i**2
        i+=1
>>> for i in squares(7):
    print(i)
1

4

9

16

25

36

49
```
更多关于生成器的内容，参看这里。

### Q18. 什么是迭代器？
迭代器是访问集合元素的一种方式。迭代器对象从集合的第一个元素开始访问，直到所有的元素被访问完结束。迭代器只能往前不会后退。我们使用inter()函数创建迭代器。
`odds=iter([1,3,5,7,9])`

每次想获取一个对象时，我们就调用next()函数。
```python
>>> next(odds)
1

>>> next(odds)
3

>>> next(odds)
5

>>> next(odds)
7

>>> next(odds)
9
```
现在我们再次调用它，会抛出StopIteration异常。这是因为它已经抵达需要迭代的值的尾部。
```python
>>> next(odds)
Traceback (most recent call last):
File "<pyshell#295>", line 1, in <module>
next(odds)
StopIteration
```
更多关乎迭代器的内容，参看这里。

### Q19. 请说说生成器和迭代器之间的区别


在使用生成器时，我们创建一个函数；在使用迭代器时，我们使用内置函数iter()和next()。


在生成器中，我们使用关键字‘yield’来每次生成/返回一个对象。


生成器中有多少‘yield’语句，你可以自定义。


每次‘yield’暂停循环时，生成器会保存本地变量的状态。而迭代器并不会使用局部变量，它只需要一个可迭代对象进行迭代。


使用类可以实现你自己的迭代器，但无法实现生成器。


生成器运行速度快，语法简洁，更简单。


迭代器更能节约内存。


关于生成器和迭代器二者的对比，更多内容查看这里。

### Q20. 我们都知道现在Python很火，但是对于一门技术我们不光要知道它的优点，也要知道它的缺点，请谈谈Python的不足之处。

Python有以下缺陷：

Python的可解释特征会拖累其运行速度。

虽然Python在很多方面都性能良好，但在移动计算和浏览器方面表现不够好。

由于是动态语言，Python使用鸭子类型，即duck-typing，这会增加运行时错误。

>从Q 21到Q 30都是进阶版Python面试问题，不过Python新手也可以参考。

### Q21. 函数zip()的是干嘛的？
Python新手可能对这个函数不是很熟悉，zip()可以返回元组的迭代器。
```python
>>> list(zip(['a','b','c'],[1,2,3]))
[(‘a’, 1), (‘b’, 2), (‘c’, 3)]
```
在这里zip()函数对两个列表中的数据项进行了配对，并用它们创建了元组。
```python
>>> list(zip(('a','b','c'),(1,2,3)))
[(‘a’, 1), (‘b’, 2), (‘c’, 3)]
```
### Q22. 如果你困在了死循环里，怎么打破它？
出现了这种问题时，我们可以按Ctrl+C，这样可以打断执行程序。我们创建一个死循环来解释一下。

```python
>>> def counterfunc(n):
    while(n==7):print(n)
>>> counterfunc(7)
7

7

7

7

7

7

7

7

7

7

7

7

7

7

7

7

7

Traceback (most recent call last):
 File "<pyshell#332>", line 1, in <module>
   counterfunc(7)
 File "<pyshell#331>", line 2, in counterfunc
   while(n==7):print(n)
KeyboardInterrupt

>>>
```

### Q23. 解释Python的参数传递机制
Python使用按引用传递（pass-by-reference）将参数传递到函数中。如果你改变一个函数内的参数，会影响到函数的调用。这是Python的默认操作。不过，如果我们传递字面参数，比如字符串、数字或元组，它们是按值传递，这是因为它们是不可变的。

### Q24. 如何用Python找出你目前在哪个目录？
我们可以使用函数/方法getcwd()，从模块os中将其导入。
```python
>>> import os
>>> os.getcwd()
'C:\\Users\\lifei\\AppData\\Local\\Programs\\Python\\Python36-32'
>>> type(os.getcwd)
<class 'builtin_function_or_method'>
```
我们还可以用chdir()修改当前工作目录。
```python
>>> os.chdir('C:\\Users\\lifei\\Desktop')
>>> os.getcwd()
'C:\\Users\\lifei\\Desktop'
```

### Q25. 怎样发现字符串中与‘cake’押韵的第一个字？
我们可以使用函数search()，然后用group()获取输出。
```python
>>> import re
>>> rhyme=re.search('.ake','I would make a cake, but I hate to bake')
>>> rhyme.group()
'make'
```
我们知道，函数search()会在第一次匹配时停止运行，这样我们就能得到第一个与‘cake’押韵的字。

### Q26. 如何以相反顺序展示一个文件的内容？

我们首先回到桌面，使用模块os中的chdir()函数/方法。
```python
>>> import os
>>> os.chdir('C:\\Users\\lifei\\Desktop')
```
这里我们要使用的文件时Today.txt，它的内容如下：
```shell
OS, DBMS, DS, ADA

HTML, CSS, jQuery, JavaScript

Python, C++, Java

This sem’s subjects

Debugger

itertools

Container
```
我们将内容读取为一个列表，然后在上面调用reversed()函数：
```python
>>> for line in reversed(list(open('Today.txt'))):
   print(line.rstrip())
container

itertools

Debugger

This sem’s subjects

Python, C++, Java

HTML, CSS, jQuery, JavaScript

OS, DBMS, DS, ADA
```
如果没有rstrip()，我们会在输出中得到空行。

### Q27. 什么是Tkinter ？

TKinter是一款很知名的Python库，用它我们可以制作图形用户界面。其支持不同的GUI工具和窗口构件，比如按钮、标签、文本框等等。这些工具和构件均有不同的属性，比如维度、颜色、字体等。
我们也能导入Tkinter模块。
```python
>>> import tkinter
>>> top=tkinter.Tk()
```
这会为你创建一个新窗口，然后可以在窗口上添加各个构件。

### Q28. 请谈谈.pyc文件和.py文件的不同之处

虽然这两种文件均保存字节代码，但.pyc文件是Python文件的编译版本，它有平台无关的字节代码，因此我们可以在任何支持.pyc格式文件的平台上执行它。Python会自动生成它以优化性能（加载时间，而非运行速度）。

### Q29. 如何在Python中创建自己的包？

Python中创建包是比较方便的，只需要在当前目录建立一个文件夹，文件夹中包含一个__init__.py文件和若干个模块文件，其中__init__.py可以是一个空文件，但还是建议将包中所有需要导出的变量放到__all__中，这样可以确保包的接口清晰明了，易于使用。
### Q30. 如何计算一个字符串的长度？

这个也比较简单，在我们想计算长度的字符串上调用函数len()即可。
```python
>>> len('Ayushi Sharma')
13
```
结语

本文我们紧接着上篇总结了另外一些常见的Python面试题，当然肯定无法涵盖所有的知识点，后面如有机会再另行补充，欢迎关注。
