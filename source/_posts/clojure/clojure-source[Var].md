---
layout: "post"
title: "Clojure [Var]"
date: "2016-05-29 14:13"
tags: [clojure]
category : clojure
keywords: clojure
---
### 类图
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
+ 创建 主要有`create`，`intern`两种
	```java
	public static Var intern(Namespace ns, Symbol sym, Object root) {
		return intern(ns, sym, root, true);
	}

	public static Var intern(Namespace ns, Symbol sym, Object root, boolean replaceRoot) {
		Var dvout = ns.intern(sym);
		if (!dvout.hasRoot() || replaceRoot)
			dvout.bindRoot(root);
		return dvout;
	}

	public static Var intern(Symbol nsName, Symbol sym) {
		Namespace ns = Namespace.findOrCreate(nsName);
		return intern(ns, sym);
	}

	public static Var internPrivate(String nsName, String sym) {
		Namespace ns = Namespace.findOrCreate(Symbol.intern(nsName));
		Var ret = intern(ns, Symbol.intern(sym));
		ret.setMeta(privateMeta);
		return ret;
	}

	public static Var intern(Namespace ns, Symbol sym) {
		return ns.intern(sym);
	}

	public static Var create() {
		return new Var(null, null);
	}

	public static Var create(Object root) {
		return new Var(null, null, root);
	}
	```
+ 属性
  + ns Namespace
  + sym Symbol
  + dynamic boolean 是否可以做`threadBingings`
  + threadBound AtomicBoolean 是否已经`threadBingings`
  + root 不绑定时求的值
  + \_meta 元数据
  + dvals Frame static 持有动态绑定

+ 方法
	```java
	public static void pushThreadBindings(Associative bindings) {
		Frame f = dvals.get();
		//获得当前Frame的bindings
		Associative bmap = f.bindings;
		//将新的bindings合并到f.bingings，生存新的bingings
		//并只有dynamic=true的才能pushThreadBindings
		//并将bindings的var设置成threadBound=true
		for (ISeq bs = bindings.seq(); bs != null; bs = bs.next()) {
			IMapEntry e = (IMapEntry) bs.first();
			Var v = (Var) e.key();
			if (!v.dynamic)
				throw new IllegalStateException(
						String.format("Can't dynamically bind non-dynamic var: %s/%s", v.ns, v.sym));
			v.validate(v.getValidator(), e.val());
			v.threadBound.set(true);
			bmap = bmap.assoc(v, new TBox(Thread.currentThread(), e.val()));
		}
		dvals.set(new Frame(bmap, f));
	}

	public static void popThreadBindings() {
		Frame f = dvals.get().prev;
		if (f == null) {
			throw new IllegalStateException("Pop without matching push");
		} else if (f == Frame.TOP) {
			dvals.remove();
		} else {
			dvals.set(f);
		}
	}
	/**
	 * 返回当前线程的bingings
	 *
	 */
	public static Associative getThreadBindings() {
		Frame f = dvals.get();
		IPersistentMap ret = PersistentHashMap.EMPTY;
		for (ISeq bs = f.bindings.seq(); bs != null; bs = bs.next()) {
			IMapEntry e = (IMapEntry) bs.first();
			Var v = (Var) e.key();
			TBox b = (TBox) e.val();
			ret = ret.assoc(v, b.val);
		}
		return ret;
	}
	/**
	 * 返回当前线程,当前Var的TBox
	 */
	public final TBox getThreadBinding() {
		if (threadBound.get()) {
			IMapEntry e = dvals.get().bindings.entryAt(this);
			if (e != null)
				return (TBox) e.val();
		}
		return null;
	}

	final public Object get() {
		//如果没有绑定过线程返回root
		if (!threadBound.get())
			return root;
		return deref();
	}

	final public Object deref() {
		//如果有线程绑定返回绑定值，否则返回root
		TBox b = getThreadBinding();
		if (b != null)
			return b.val;
		return root;
	}

	public Object set(Object val) {
		validate(getValidator(), val);
		TBox b = getThreadBinding();
		//可见若没有在pushThreadBindings，设置Var可以线程绑定，不能使用!set改变值。
		if (b != null) {
			if (Thread.currentThread() != b.thread)
				throw new IllegalStateException(String.format("Can't set!: %s from non-binding thread", sym));
			return (b.val = val);
		}
		throw new IllegalStateException(String.format("Can't change/establish root binding of: %s with set", sym));
	}

	public Object doSet(Object val) {
		return set(val);
	}

	public Object doReset(Object val) {
		bindRoot(val);
		return val;
	}
	```
