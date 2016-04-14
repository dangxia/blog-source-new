title: java Binary Literals
date: 2015-11-08 12:11:54
tags: [java]
---
[binary-literals.html](http://docs.oracle.com/javase/7/docs/technotes/guides/language/binary-literals.html)
[stackoverflow:binary-literals-in-java](http://stackoverflow.com/questions/10961091/are-there-binary-literals-in-java)
[wikibooks:Java-Literals](https://en.wikibooks.org/wiki/Java_Programming/Literals)

```java
byte b = 0b01111111;
System.out.println(b);
//:127
b = (byte)0b11111111;
System.out.println(b);
//:-1
b = 0b11111111;
System.out.println(b);
//javac errr:
//Test.java:3: 错误: 可能损失精度
//    byte b = 0b11111111;
//             ^
//  需要: byte
//  找到:    int
//1 个错误
```
**byte,short的Binary Literal的首位是1时，需要转型。**