# Shell编程

* * *

## 基础

### 变量

#### 1.定义变量

实例:

```shell
#变量名一般都是由字母、数字、下划线组成的，变量名不能以数字开头
变量名=0
变量名='xxxx'
变量名="yyyy"
```

> 变量的内容可以用单引号、双引号引起来，同时也可以不加引号，但是这三者的含义是不一样的

    1.当我们不加单引号时必须是连续的字符串才可以；如果加了''号那么结论是当变量名写什么那么它就会输出什么
    2.""这种定义的方式特点是：输出变量内容时引号变量及命令会经过解析后在输出

```shell
变量名=`ifconfig`
变量名=$("ifconfig")
#可以执行ifconfig的命令
```

同时我们也可以在命令段的前后加``反撇号

```shell
IP=`ifconfig`
```

> 注意：在=之后没有空格，当变量名称容易和紧跟其后的其他字符混淆时，我们可以用{}来解决

#### 2.特殊变量

在shell中存在着一些特殊而又重要的变如：$1 $0 $#，我们称为特殊的位置变量要从命令行，函数，脚本，等传递参数时，就需要在shell脚本中使用位置参数变量

-   $0:显示当前的脚本文件名，如果在执行脚本时添加了路径，那么全部都会输出
-   $n:获取当前执行的shell脚本的第n个参数值比如：[n=1..9]，如果N大于9那么就要使用{}来定义 比如${10}
-   $#:获取当前shell脚本后面接的参数的个数
-   $_:获取当前脚本的参数，不加引号和$@是一样的 加了引号；例如"$_" 则表示单个字符串。相当于"$1 $2 $3"
-   $@:同样也是获取当前shell的参数，不加引号和$\*是一样的，那么加了引号如："$@" 表示将所有的参数视为不同独立的字符串，相当于"$1" "$2"..
-   $?:表示上一个命令执行的结果0为成功，1为失败
-   $$ 和 $!都是获取脚本进程号PID

```shell
#!/bin/sh

for TOKEN in "$*"
do
   echo $TOKEN
done

for token in "$@"
do
   echo $token
done
```

#### 3.变量数值计算

shell也有很多的运算符如下：

    +、-、：代表着加号 和减号 或者，负号
    *、/、%：代表着乘号，除号，和取模。
    **   :幂运算
    ++、-- ：表示着增加或者减少，它可以放在前置，也可以放在变量的结尾
    ！、||、&&:（取反）（或）（and）
    <、<=、>、>= ：比较符号，小于、小于等于、大于、大于等于
    ==、！=、= ：相等，不相等， =表示相等于
    <<     >> :向左移动 向右移动

算术运算命令:

    （（））  用于整数之间常用的运算符，效率高
    let ：用于整数运算，类似于（（））
    expr ：用于整数运算，但是还有其他功能
    bc ：Linux下的一个计算程序，适合整数及小数运算
    $[] ：用于整数运算
    awk：awk既可以整数运算，也可以小数运算
    declare: 定义变量值和属性，-i参数可以用于定义整形变量，做运算

实例

```shell
[ ${#a} -le 0 ] #a是一个变量了 如果a长度小于0

echo $((1+1))  #计算1+1后输出
2

((a=1+2**3-4%3)) #先算乘除，后算加减
echo $a
8

b=$((1+2**3-4%3)) #在这里b是一个变量 将变量名的计算结果赋值给b
echo $b
8

echo $((6==6)) #6==6 那么就输出1
echo $((2>3))  #当条件2>3错误后输出0
echo "a**b=$((a**b))"

let a=a+8  #使用let,对a重新赋值

# 利用expr做计算，将一个未知的变量和一个已知的一个整数相加，看返回的值是否为0，如果默认是0 那么就是一个整数。如果非0则输入的就是字符串不是整数。
expr 4 / 2
2
```

### 判断

#### if语句

### 循环

## 函数

## 调用

## 常用命令

### 文件

创建文件

```shell
touch text.sh #创建文件
cp -[a f r p] path/file1 path/file2 #复制文件 a:表示拷贝所有属性，p:拷贝可以的属性，r:目录,f:强制
rm path/file #删除文件 -f表示强制
mkdir path/folder #创建目录
rm -rf path/folder #删除目录
cat path/file #cat命令是显示文本,-n参数会给所有的行加上行号
ls path #命令并未输出太多每个文件的相关信息 -l参数会产生长列表格式的输出
```

### 重定向

```shell
echo "xxxx" > path/file.log #重新创建，存在则删除
echo "xxxx" >> path/file.log #不存在则创建，存在则追加到尾部
```
