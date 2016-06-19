---
layout: "post"
title: "Clojure [Keyword]"
date: "2016-05-29 14:13"
tags: [clojure]
category : clojure
keywords: clojure
---
### 类图

{% plantuml %}
class Keyword {
	-{static}ConcurrentHashMap<Symbol,Reference<Keyword>> table
	~{static}ReferenceQueue rq
	+Symbol sym
	~int hasheq
	~String _str
	+{static}Keyword intern(Symbol sym)
	+{static}Keyword intern(String ns, String name)
	+{static}Keyword intern(String nsname)
	-Keyword(Symbol sym)
	+{static}Keyword find(Symbol sym)
	+{static}Keyword find(String ns, String name)
	+{static}Keyword find(String nsname)
	+int hashCode()
	+int hasheq()
	+String toString()
	+Object throwArity()
	+Object call()
	+void run()
	+Object invoke()
	+int compareTo(Object o)
	+String getNamespace()
	+String getName()
	-Object readResolve()
}
class IFn {
}
IFn <|.. Keyword
class Comparable {
}
Comparable <|.. Keyword
class Named {
}
Named <|.. Keyword
class Serializable {
}
Serializable <|.. Keyword
class IHashEq {
}
IHashEq <|.. Keyword
{% endplantuml %}

+ 属性
  sym 一个没有meta的Symbol
+ 缓存
  可能是Keyword用的比较多，使用WeakReference进行了缓存。从注释掉的代码来看，以前用的是SoftReference，不知道出于何种原因进行了修改。
+ 创建
	```java
	public static Keyword intern(String ns, String name) {
		return intern(Symbol.intern(ns, name));
	}

	public static Keyword intern(String nsname) {
		return intern(Symbol.intern(nsname));
	}
	```
