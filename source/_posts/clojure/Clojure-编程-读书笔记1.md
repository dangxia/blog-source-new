title: Clojure 编程-读书笔记1(进入Clojure仙境)
date: 2015-06-27 14:01:17
tags: [读书笔记,clojure]
category : clojure
---
>**列表 在书中一般标识函数调用，而不是数据结构。刚开始没注意，看的很混乱。**

## 为什么选择Clojure?
+ Clojure是运行在JVM上的一种语言

  Clojure代码可以使用任何java类库，反之Clojure库也可以被任何Java代码使用
  `？`和原生的java类库的差别?

+ Clojure是Lisp
+ Clojure是函数式编程语言

  Clojure鼓励使用高阶函数，并且提供了一些高效、不可变的数据结构，避免由于状态的不加控制的修改而导致的一些bug，并且也使Clojure成为一种进行并行、并发编程的完美语言。
  `？`java并发编程是需要状态控制的，而clojure可以直接调用java代码？

+ clojure提供一种进行并行、并发编程的创新式解决方案

  clojure的引用类型强制我们把对象的状态和对象的标识区分开。`?`
  clojure对于多线程编程的支持使得我们不用手动加锁、解锁也能编写多线程的代码。

+ clojure是一种动态的编程语言

  clojure是动态的同时也是强类型的（和Python、Ruby类似）
  clojure支持运行时更新现有代码。`？`
<!--more-->

## 命名空间
  命名空间是Clojure最基本的代码模块组件，所有的Clojure代码都是在一个命名空间中被定义和求值的。
  命名空间可以看成Ruby和Python中的module，Java中package。
  java.lang包里面的类默认被引入到每一个Clojure命名空间中，所以可以不加包名直接访问这些Java类。

## 字面量

### 标量字面量
+ 字符串

  Clojure中的字符串就是Java的字符串，左右两边以双引号括起来。Clojure的字符串天然支持多行。
+ 布尔值

  true和false表示布尔值。
+ 字符

  Clojure中的字符字面量是通过反斜杠加字符来表示。ex：\c
  对于Unicode编码和octal编码对应\u00ff,\o41
  特殊字符：\space,\newline,\formfeed,\return
+ nil

  对应Java中的null
+ 关键字(key)

  key始终以冒号开头,并且不和任何命名空间限定，在任何命名空间中都可以使用，效果一样。但当key里面包含的/，表示这个key是某个命名空间限定的。
  如果key以两个冒号（：：）开头，表示是当前命名空间的关键字，若同时当key里面包含的/，表示这个key是某个命名空间限定的。
  虽然书里面没有提及，但是测试`（= :user/location ::user/location)`结果为true

  key求值成他们本身，因为key本身就是函数，他的作用就是查找他对应的值。

  ```
  (ns foo) ;create foo namespace,avoid java.lang.RuntimeException: Invalid token: ::foo/location
  (println *ns*)
  (ns user)
  (println *ns*)
  (def pizza {:name "Ramunto's" :location "Claremont,NH" ::location "43.3734,-72.3365" ::foo/location "test"})
  (println(= :user/location ::user/location))
  ;true
  (println(= :user/location ::foo/location))
  ;false
  (println(:user/location pizza))
  ;43.3734,-72.3365
  (println(::user/location pizza))
  ;43.3734,-72.3365
  (println(:location pizza))
  ;Claremont,NH
  (println(:foo/location pizza))
  ;test
  (println(::foo/location pizza))
  ;test
  (ns foo)
  (println(::location user/pizza))
  ;test
  ```
+ 符号(symbol)

  和关键字一样，符号也是一种标识符，但不同的是，符号的值是它所代表的Clojure运行时里面的那个值。这个值可以是var所持有的值（持有的可以是函数以及其他值）、JAVA类、本地引用等。
  ```
  (averager [60 80 100 400])
  ;=160
  ```
  这里的average就是一个符号，代表一个名叫average的var所指向的函数
  符号不能以数字开头，但是跟Java以及其他语言不一样的是，符号的名字中不但可以包括数字、字符、还可以有*+!-_以及?等特殊字符。
+ 数字

  java long,int,byte,short  ==>  long
  java float,double ==>  double
  任意进制（BrN，B是进制，N值），2r111 = 7，16rff = 255
  有理数,分子/分母

|字面量语法                |数字类型|
|------------------|:---------------:|
|42、0xff、2r111、040     |long(64位带符号整数)|
|3.14、6.023423e23|double(IEEE标准的64位浮点数)|
|42N              |clojure.lang.BigInt(任意精度的整数)|
|0.01M            |java.math.BigDecimal(任意精度的浮点数)|
|22/7             |clojure.lang.Ratio|
+ 正则表达式

  以#开头的字符串
```
(class #"(p|h)ail")
;=java.util.regex.Pattern
```
  clojure中的\不需要像java中那样转义
+ 注释

  +	以分号（;）开头的当行注释
  +	形式级别的注释#_宏。这个宏告诉reader忽略下一个clojure形式。
```
(read-string "(+ 1 2 #_(* 2 2 ) 8)")
;= (+ 1 2 8)
```
  +	comment宏，和#_宏不同的是，comment返回nil
+ 空格和逗号

********************************
### 集合面量
```
‘（a b :name 12.5) ;;list
['a 'b :name 12.5] ;;vector
{:name "test" :age 31}  ;;map
#{1 2 3}    ;;set
```

  clojure中用列表标识函数调用，所以当要表示数据结构时前面加一个单引号，以防止列表被求值成一个函数调用。

## Clojure表达式
所有的clojure的代码都是由表达式组成的，每一个表达式会求值产生一个值。这跟其他很多语言依赖于大量无值控制语句不一样，比如跟if、for以及continue来命令式的控制程序流程不一样，clojure中的这些控制性语句都是有值的表达式，跟其他普通的表达式没有本质区别。

表达式求值：
  + 列表 表示函数调用，第一个元素（函数位置）为操作符，其他的为参数。求值成这个调用的返回值。
  + 符号 会被求值成一个函数、一个本地绑定等。
  + 其他表达式求值成他的字面量。

> Lisp中列表通常被称为S表达式(symbolic expressions、s-expression、sexprs)
> 能够被成功求值的s表达式称为形式(form)
> (1 2 3) 表示一个三个数字的正确的S表达式，但是他无法被成功求值，因为这个列表的第一个元素是数字，不能被调用，因此不是一个form


## 代码即数据（同像性）
clojure自身的数据结构：标量字面量和集合的字面量。
clojure的代码是直接用表示抽象语法树（AST）的clojure的数据结构来写的。这种特征学名叫做`同像性`，一般称为`代码即数据`

## Clojure REPL
+ Read

  代码被作为字符串从输入源读入。
+ Eval

  代码被求值，产生一个结果。
+ Print

  求值的结果被打印到某个输出设备。
+ Loop

  控制重新跳回到读入(Read)阶段。

**clojure从来没有被解释执行过。**
>我的理解是：repl的输入被编译成JVM的字节码，然后被动态加载而执行。

  ### reader
  clojure reader的职责：文本的代码处理成Clojure的数据结构。
  
  reader的所有操作是由read函数完成的。（read-string 函数原理类似)
  print --> pr -->pr-str
```
(read-string "42")
;=42
(read-string "\"42\"")
;="42"
(class (read-string "42"))
;=java.lang.Long
(class  (read-string "\"42\""))
;=java.lang.String


(read-string "(+ 1 2)")
;=(+ 1 2)
(class (read-string "(+ 1 2)"))
;=clojure.lang.PersistentLis
(class '(1 2))
;=clojure.lang.PersistentList
(read-string "'(+ 1 2)")
;=(quote (+ 1 2))
(class (read-string "'(+ 1 2)"))
;=clojure.lang.Cons

(read-string "\'(+ 1 2)")
;RuntimeException Unsupported escape character: \'  clojure.lang.Util.runtimeException (Util.java:221)
;3
;RuntimeException EOF while reading string  clojure.lang.Util.runtimeException (Util.java:221)
```
> 如何读入一个形式`？`

  ### reader一些语法糖
  + ‘ 阻止求值
  + \#() 匿名函数
  + \#’ var会被求值成var所代表的值，若加上#'则得到var的本身
  + @ @符号 得到这个引用所指向的值。
  + `、~、~@ 宏定义的特殊语法。

## 特殊形式

特殊形式是Clojure里面的基本构建单元，Clojure里面的其余部分都是基于这些特殊形式构建起来的。
\+ -不是Clojure的基本元语，而是用特殊形式构建出来的。你可以设计你喜欢的语法。

## 阻止求值(quote或')
+ clojure的数据结构表达式不作求值操作。阻止求值对数据结构没有意义。
+ 列表求值成函数调用，阻止求值，则求值成列表本身。

```
'(+ x x)
;= (+ x x)
(list? '(+ x x))
;=true
(= '(+ x x) (list '+ 'x 'x))
;=true
```
+ var符号，会被求值成对应的var的值，阻止求值后，会求值成符号本身。

```
(quote x)
;=x
(symbol? (quote x))
;=true
```

```
''x
;=(quote x)
'@x
;=(clojure.core/deref x)
'#(+ % %)
;=(fn* [p1__2210#] (+ p1__2210# p1__2210#))
#'`(a b ~c)
;=//#(clojure.core/seq (clojure.core/concat (clojure.core/list (quote user/a)) (clojure.core/list (quote user/b)) (clojure.core/list c)))

```

## 代码快：do
do会依次求值参数中的表达式，并把最后一个返回。
fn、let、loop、try、defn隐式的使用了do

## 定义Var:def



