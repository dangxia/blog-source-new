---
layout: "post"
title: "Inline"
date: "2016-08-12 09:13"
tags: [program]
category : program
keywords: [clojure,inline,program]
---
昨天看Clojure源码，`nil?`还有一些比较函数等的函数实现都使用了`inline`来实现。

```clojure
(defn nil?
  "Returns true if x is nil, false otherwise."
  {:tag    Boolean
   :added  "1.0"
   :static true
   :inline (fn [x] (list 'clojure.lang.Util/identical x nil))}
  [x] (clojure.lang.Util/identical x nil))

(defn compare
  "Comparator. Returns a negative number, zero, or a positive number
  when x is logically 'less than', 'equal to', or 'greater than'
  y. Same as Java x.compareTo(y) except it also works for nil, and
  compares numbers and collections in a type-independent manner. x
  must implement Comparable"
  {
   :inline (fn [x y] `(. clojure.lang.Util compare ~x ~y))
   :added  "1.0"}
  [x y] (. clojure.lang.Util (compare x y)))
```
<!--more-->
[官方的设计文档][Inlined manual]，在我看来`inline`更像`Macro`，在用到`inline`函数的地方，将函数的代码内嵌进去。

由此想到其他地方遇到的`inline`

#### IDE
Eclipse、Idea重构都支持Inline
#### JIT
JIT优化有Inline优化
#### 王垠
王垠的Blog[Java 有值类型吗？][Java 有值类型吗？]中说道：Java在语义上应该都是引用类型，只是为了性能inline了基础类型。



[Java 有值类型吗？]: http://www.yinwang.org/blog-cn/2016/06/08/java-value-type
[Inlined manual]: http://dev.clojure.org/display/design/Inlined+code
