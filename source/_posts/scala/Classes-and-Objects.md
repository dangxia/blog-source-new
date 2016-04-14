title: Chapter4：Classes and Objects
date: 2016-01-24 15:44:29
tags: [Programming in Scala]
categories: [Scala]
---
### Classes, fields, and methods
>**The way you make members public in Scala is by not explicitly specifyingany access modifier. Put another way, where you’d say “public” in Java,you simply say nothing in Scala. Public is Scala’s default access level.**

###  Semicolon inference
+ single line
  one statement on a single line,semicolon is optional
  multiple statement on a single line,semicolone is require
+ multiple lines
  one statement on multiple lines,most of the time,is treated as one multiple lines statement

>**The rules of semicolon inference**
The precise rules for statement separation are surprisingly simple for how well they work. 
In short, a line ending is treated as a semicolon unless one of the following conditions is true:
  1. The line in question ends in a word that would not be legal as theend of a statement, such as a period or an infix operator.
  2. The next line begins with a word that cannot start a statement.
  3. The line ends while inside parentheses (...) or brackets [...],because these cannot contain multiple statements anyway.

### Singleton objects
Scala cannot have static members. Instead, Scala has singleton objects.
A singleton object definition looks like a class definition, except instead of the keyword class you use the keyword object.
When a singleton object shares the same name with a class, it is called that class’s companion object. You must define both the class and its companion object in the same source file. The class is called the companion class of the singleton object. A class and its companion object can access each other’s private members.
However, singleton objects extend a superclass and can mix in traits. Given each singleton object is an instance of its superclasses and mixed-in traits, you can invoke its methods via these types, refer to it from variables of these types, and pass it to methods expecting these types.
A singleton object that does not share the same name with a companion class is called a standalone object. You can use standalone objects for many purposes, including collecting related utility methods together, or defining an entry point to a Scala application

### A Scala application
To run a Scala program, you must supply the name of a standalone singleton object with a main method that takes one parameter, an Array[String], and has a result type of Unit. 
>**Scala implicitly imports members of packages java.lang and scala, as well as the members of a singleton object named Predef, into every Scala source file. Predef, which resides in package scala, contains many useful methods. For example, when you say println in a Scala source file, you’re actually invoking println on Predef. (Predef.println turns around and invokes Console.println, which does the real work.) When you say assert, you’re invoking Predef.assert.**

Neither ChecksumAccumulator.scala nor Summer.scala are scripts, because they end in a definition. A script, by contrast, must end in a result expression.
**fsc：**This compiles your source files, but there may be a perceptible delay before the compilation finishes. The reason is that every time the compiler starts up, it spends time scanning the contents of jar files and doing other initial work before it even looks at the fresh source files you submit to it. For this reason, the Scala distribution also includes a Scala compiler daemon called fsc (for fast Scala compiler). You use it like this:
```
$ fsc ChecksumAccumulator.scala Summer.scala
```
### The Application trait
Scala provides a trait, scala.Application, that can save you some finger typing.
To use the trait, you first write “extends Application” after the name of your singleton object. Then instead of writing a main method, you place the code you would have put in the main method directly between the curly braces of the singleton object. That’s it. You can compile and run this application just like any other.
Inheriting from Application is shorter than writing an explicit main method, but it also has some shortcomings. First, you can’t use this trait if you need to access command-line arguments, because the args array isn’t available. For example, because the Summer application uses command-line arguments, it must be written with an explicit main method, as shown in Listing 4.3. Second, because of some restrictions in the JVM threading model, you need an explicit main method if your program is multi-threaded. Finally, some implementations of the JVM do not optimize the initialization code of an object which is executed by the Application trait. So you should inherit from Application only when your program is relatively simple and single-threaded