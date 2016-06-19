---
layout: "post"
title: "Clojure [Symbol]"
date: "2016-05-29 14:13"
tags: [clojure]
category : clojure
keywords: clojure
---
### 类图

{% plantuml %}
class Symbol {
	~String ns
	~String name
	-int _hasheq
	~IPersistentMap _meta
	~String _str
	+String toString()
	+String getNamespace()
	+String getName()
	+{static}Symbol create(String ns, String name)
	+{static}Symbol create(String nsname)
	+{static}Symbol intern(String ns, String name)
	+{static}Symbol intern(String nsname)
	-Symbol(String ns_interned, String name_interned)
	+boolean equals(Object o)
	+int hashCode()
	+int hasheq()
	+IObj withMeta(IPersistentMap meta)
	-Symbol(IPersistentMap meta, String ns, String name)
	+int compareTo(Object o)
	-Object readResolve()
	+Object invoke(Object obj)
	+Object invoke(Object obj, Object notFound)
	+IPersistentMap meta()
}
class AFn {
}
AFn <|-- Symbol
class IObj {
}
IObj <|.. Symbol
class Comparable {
}
Comparable <|.. Symbol
class Named {
}
Named <|.. Symbol
class Serializable {
}
Serializable <|.. Symbol
class IHashEq {
}
IHashEq <|.. Symbol
{% endplantuml %}

+ Symbol 主要属性
  ns 命名空间
  name 名称
  _meta 元数据

+ Symbol 分两种
  区别在于ns是否为空，ns不为空时为ns下的Symbol，ns为空时，从目前的代码来看，主要是global的import，或者本生就是namespace的Symbol。
	**NOTE:以下方法都没有传入`meta`**
	```java
		static public Symbol intern(String ns, String name) {
			return new Symbol(ns, name);
		}

		static public Symbol intern(String nsname) {
			int i = nsname.indexOf('/');
			if (i == -1 || nsname.equals("/"))
				return new Symbol(null, nsname);
			else
				return new Symbol(nsname.substring(0, i), nsname.substring(i + 1));
		}
	```

+ 函数的功能
  具有函数的功能，代码来看只支持，一个参数。
	```java
	public Object invoke(Object obj) {
		return RT.get(obj, this);
	}

	public Object invoke(Object obj, Object notFound) {
		return RT.get(obj, this, notFound);
	}
	```
	`RT.get(coll, key)`,coll支持ILookUp,Collection,Map,String,Array等。

+ immutable
  ns,name,_meta都为final,_meta修改会产生新的Symbol
	```java
	public IObj withMeta(IPersistentMap meta) {
		return new Symbol(meta, ns, name);
	}
	```
+ 备忘

	+ readResolve

		**返回了一个不含meta的Symbol**
		```java
		private Object readResolve() throws ObjectStreamException {
			return intern(ns, name);
		}
		```

	+ IHashEq

		**hasheq ???**
		```java
		public int hashCode() {
			return Util.hashCombine(name.hashCode(), Util.hash(ns));
		}

		public int hasheq() {
			if (_hasheq == 0) {
				_hasheq = Util.hashCombine(Murmur3.hashUnencodedChars(name), Util.hash(ns));
			}
			return _hasheq;
		}
		```
