---
layout: "post"
title: "Clojure [Namespace]"
date: "2016-05-29 14:13"
tags: [clojure]
category : clojure
keywords: clojure
---
### 类图

{% plantuml %}
class Namespace {
	+Symbol name
	~AtomicReference<IPersistentMap> mappings
	~AtomicReference<IPersistentMap> aliases
	~{static}ConcurrentHashMap<Symbol,Namespace> namespaces
	+String toString()
	~Namespace(Symbol name)
	+{static}ISeq all()
	+Symbol getName()
	+IPersistentMap getMappings()
	+Var intern(Symbol sym)
	-void warnOrFailOnReplace(Symbol sym, Object o, Object v)
	~Object reference(Symbol sym, Object val)
	+{static}boolean areDifferentInstancesOfSameClassName(Class cls1, Class cls2)
	~Class referenceClass(Symbol sym, Class val)
	+void unmap(Symbol sym)
	+Class importClass(Symbol sym, Class c)
	+Class importClass(Class c)
	+Var refer(Symbol sym, Var var)
	+{static}Namespace findOrCreate(Symbol name)
	+{static}Namespace remove(Symbol name)
	+{static}Namespace find(Symbol name)
	+Object getMapping(Symbol name)
	+Var findInternedVar(Symbol symbol)
	+IPersistentMap getAliases()
	+Namespace lookupAlias(Symbol alias)
	+void addAlias(Symbol alias, Namespace ns)
	+void removeAlias(Symbol alias)
	-Object readResolve()
}
class AReference {
}
AReference <|-- Namespace
class Serializable {
}
Serializable <|.. Namespace
{% endplantuml %}

+ Namespace的创建
  `findOrCreate（Symbol）`，使用一个`static`的`ConcurrentHashMap`维持整个clojure的命名空间，没有看到命名空间自动回收相关的代码。
+ mappings属性
  目前来看维持了一个`Symbol`到`class` or `Var`映射。默认加载`RT.DEFAULT_IMPORTS`
  主要通过
  + `public Class importClass(Symbol sym, Class c)`
  + `public Var intern(Symbol sym) `
  + `public Var refer(Symbol sym, Var var)`
  来增加，需要具体分析`TODO`
+ aliases属性
  起始为空。应该维持的是`Symbol`到`NameSpace`的映射。通过`public void addAlias(Symbol alias, Namespace ns)`来添加。
