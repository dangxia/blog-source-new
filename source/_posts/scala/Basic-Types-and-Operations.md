title: Chapter5：Basic Types and Operations
date: 2015-12-06 11:21:24
tags: [Programming in Scala]
categories: [Scala]
---
### Literals
+ String literals

Scala includes a special syntaxfor raw strings. You start and end a `raw string` with three double quotationmarks in a row ("""). The interior of a raw string may contain any characterswhatsoever, including newlines, quotation marks, and special characters, except of course three quotes in a row. 

```scala example
println("""Welcome to Ultamix 3000.
           Type "HELP" for help.""")
//Welcome to Ultamix 3000.
//         Type "HELP" for help.
```

```scala put a pipe character (|) at the front of each line,then call stripMargin on strings,to escape the leading spaces
println("""|Welcome to Ultamix 3000.
|Type "HELP" for help.""".stripMargin)
//Welcome to Ultamix 3000.
//Type "HELP" for help.""".stripMargin
```
+ Symbol literals

A symbol literal is written 'ident, where ident can be any alphanumericidentifier. Such literals are mapped to instances of the predefined classscala.Symbol. Specifically, the literal 'cymbal will be expanded by thecompiler to a factory method invocation: Symbol("cymbal"). 

>**NOTE:**
Another thing that’s noteworthy is that symbols are interned(限定的). If you write the same symbol literal twice, both expressions will refer to the exact same Symbol object.

### Operators and methods
Scala provides a rich set of operators for its basic types. As mentioned inprevious chapters, these operators are actually just a nice syntax for ordinary method calls.
>**Any method can be an operator**
In Scala operators are not special language syntax: any method can be an operator. What makes a method an operator is how you use it. When you write “s.indexOf('o')”, indexOf is not an operator. But when you write “s indexOf 'o'”, indexOf is an operator, because you’re using it in operator notation.

+ infix operator

```scala
//single argument
s indexOf 'o'
//multiple arguments
s indexOf ('o', 5)
```

+ prefix operator

Scala will transform the expression -2.0 into the method invocation “(2.0).unary_-”
>**NOTE**:The only identifiers that can be used as prefix operators are` +, -, !, and ~`.Thus, if you define a method named unary\_!, you could invoke that methodon a value or variable of the appropriate type using prefix operator notation,such as !p. But if you define a method named unary\_\*, you wouldn’t be ableto use prefix operator notation, because \* isn’t one of the four identifiers thatcan be used as prefix operators. 

+ postfix operator

Postfix operators are methods that take no arguments, when they are invoked without a dot or parentheses.

### Relational and logical operations

>**Note:** You may be wondering how short-circuiting can work given operators are just methods. Normally, all arguments are evaluated before entering a method, so how can a method avoid evaluating its second argument? The answer is that all Scala methods have a facility for delaying the evaluation of their arguments, or even declining to evaluate them at all. The facility is called by-name parameters and is discussed in Section 9.5.

### Object equality

If you want to compare two objects for equality, you can use either ==, or its inverse !=.

>**How Scala’s == differs from Java’s **
 In Java,you can use == to compare both primitive and reference types. On primitive types, Java’s == compares value equality, as in Scala. On reference types, however, Java’s == compares reference equality, which means the two variables point to the same object on the JVM’s heap. Scala provides a facility for comparing reference equality, as well, under the name eq. However, eq and its opposite, ne, only apply to objects that directly map to Java objects. The full details about eq and ne are given in Sections 11.1 and 11.2. Also, see Chapter 30 on how to write a good equals method.

### Operator precedence and associativity

|Operator precedence|
|-------------------|
|(all other special characters)|
|* / %|
|+ -|
|:|
|= !|
|< >|
|& ˆ &#124; |
|(all letters)|
|(all assignment operators)|

+ Scala decides precedence based on the first character of the methods used in operator notation

```scala
a +++ b *** c //a +++ (b *** c)
```
+ The one exception to the precedence rule

The one exception to the precedence rule, alluded to above, concerns **assignment operators**, which end in an equals character. If an operator ends in an equals character (=), and the operator is not one of the comparison operators <=, >=, ==, or !=, then the precedence of the operator is the same as that of **simple assignment (=)**. 
```scala because *= is classified as an assignment operator whose precedence is lower than +, even though the operator’s first character is *, which would suggest a precedence higher than +.
x *= y + 1 //x *= (y + 1)
```
+ associativity

No matter what associativity an operator has, however, its operands are always evaluated left to right
If the methods end in ‘:’, they are grouped right to left; otherwise, they are grouped left to right. For example,`a ::: b ::: c` is treated as `a ::: (b ::: c)`. But `a * b * c`, by contrast, is treated as `(a * b) * c`.

### Rich wrappers

**Some rich operations**

|Code |Result|
|-----|-----|
|0 max 5 |5|
|0 min 5 |0|
|-2.7 abs |2.7|
|-2.7 round |-3L|
|1.5 isInfinity |false|
|(1.0 / 0) isInfinity |true|
|4 to 6 |Range(4, 5, 6)|
|"bob" capitalize |"Bob"|
|"robert" drop 2 |"bert"|

**Rich wrapper classes**

|Basic| type Rich wrapper|
|-----|-----|
|Byte| scala.runtime.RichByte|
|Short| scala.runtime.RichShort|
|Int| scala.runtime.RichInt|
|Char| scala.runtime.RichChar|
|Float| scala.runtime.RichFloat|
|Double| scala.runtime.RichDouble|
|Boolean| scala.runtime.RichBoolean|
|String| scala.collection.immutable.StringOps|

