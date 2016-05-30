---
layout: "post"
title: "clojure-source-1"
date: "2016-05-29 14:13"
tags: [clojure]
category : clojure
keywords: clojure
---
### Symbol
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

+ 函数的功能
  具有函数的功能，代码来看只支持，一个参数。

+ immutable
  ns,name,_meta都为final,_meta修改会产生新的Symbol

<!--more-->

### Namespace

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

### Keyword

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

### Var
{% plantuml %}
class Var {
	~{static}ThreadLocal<Frame> dvals
	+{static}int rev
	~{static}Keyword privateKey
	~{static}IPersistentMap privateMeta
	~{static}Keyword macroKey
	~{static}Keyword nameKey
	~{static}Keyword nsKey
	~Object root
	~boolean dynamic
	~AtomicBoolean threadBound
	+Symbol sym
	+Namespace ns
	~{static}IFn assoc
	~{static}IFn dissoc
	+{static}Object getThreadBindingFrame()
	+{static}Object cloneThreadBindingFrame()
	+{static}void resetThreadBindingFrame(Object frame)
	+Var setDynamic()
	+Var setDynamic(boolean b)
	+boolean isDynamic()
	+{static}Var intern(Namespace ns, Symbol sym, Object root)
	+{static}Var intern(Namespace ns, Symbol sym, Object root, boolean replaceRoot)
	+String toString()
	+{static}Var find(Symbol nsQualifiedSym)
	+{static}Var intern(Symbol nsName, Symbol sym)
	+{static}Var internPrivate(String nsName, String sym)
	+{static}Var intern(Namespace ns, Symbol sym)
	+{static}Var create()
	+{static}Var create(Object root)
	~Var(Namespace ns, Symbol sym)
	~Var(Namespace ns, Symbol sym, Object root)
	+boolean isBound()
	+Object get()
	+Object deref()
	+void setValidator(IFn vf)
	+Object alter(IFn fn, ISeq args)
	+Object set(Object val)
	+Object doSet(Object val)
	+Object doReset(Object val)
	+void setMeta(IPersistentMap m)
	+void setMacro()
	+boolean isMacro()
	+boolean isPublic()
	+Object getRawRoot()
	+Object getTag()
	+void setTag(Symbol tag)
	+boolean hasRoot()
	+void bindRoot(Object root)
	~void swapRoot(Object root)
	+void unbindRoot()
	+void commuteRoot(IFn fn)
	+Object alterRoot(IFn fn, ISeq args)
	+{static}void pushThreadBindings(Associative bindings)
	+{static}void popThreadBindings()
	+{static}Associative getThreadBindings()
	+TBox getThreadBinding()
	+IFn fn()
	+Object call()
	+void run()
}
class ARef {
}
ARef <|-- Var
class IFn {
}
IFn <|.. Var
class IRef {
}
IRef <|.. Var
class Settable {
}
Settable <|.. Var
{% endplantuml %}

Var 比较复杂
+ 属性
  + ns Namespace
  + sym Symbol
  + dynamic boolean 是否可以做`threadBingings`
  + threadBound AtomicBoolean 是否已经`threadBingings`
  + root 不绑定时求的值
  + _meta 元数据
  + dvals Frame static 持有动态绑定
