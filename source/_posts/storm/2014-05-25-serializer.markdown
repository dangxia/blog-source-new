---
layout: post
title: "Serializer"
date: 2014-05-25 19:25:58 +0800
comments: true
categories: storm
---
+	###参考	
https://github.com/nathanmarz/storm/wiki/Serialization
+	###原由	
storm的部分逻辑会与hadoop的MapReduce共用，MapReduce使用的ProtoBuff，所以希望在storm中能和MapReduce中一样使用ProtoBuff生成的Proto消息类	
但是，在storm中使用定义的类，在序列化时默认使用java自带的序列化方法，效力低下。所以尝试使用ProtoBuff的序列化方法注册到storm中。
+	###Serializer	
```java	GeneratedMessage的Serializer
public class ProtoBuffSerializer<T extends GeneratedMessage> extends
		Serializer<T> {

	@Override
	public void write(Kryo kryo, Output output, T object) {
		try {
			object.writeTo(output);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public T read(Kryo kryo, Input input, Class<T> type) {
		try {
			return (T) type.getMethod("parseFrom", InputStream.class).invoke(
					null, input);
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
}
```
+	###使用registerSerialization	
试着使用registerSerialization注册GeneratedMessage，但发现不起作用，需要每个子类都注册一次，比较麻烦
```java 注册GeneratedMessage的Serializer not work
Config conf = new Config();
conf.registerSerialization(GeneratedMessage.class, ProtoBuffSerializer.class);
```

```java 注册Person的Serializer is work
Config conf = new Config();
conf.registerSerialization(Person.class, ProtoBuffSerializer.class);
....
```
<!--more-->
+	###使用setKryoFactory	
```java MyKryoFactory代替默认的DefaultKryoFactory
public static class MyKryoFactory extends DefaultKryoFactory {

	public static class KryoSerializableDefault2 extends
			KryoSerializableDefault {
		private final Serializer serializer;

		public KryoSerializableDefault2() {
			serializer = new ProtoBuffSerializer<GeneratedMessage>();
		}

		@Override
		public Serializer getDefaultSerializer(Class type) {
			if (GeneratedMessage.class.isAssignableFrom(type)) {
				return serializer;
			}
			return super.getDefaultSerializer(type);
		}

	}

	@Override
	public Kryo getKryo(Map conf) {
		KryoSerializableDefault2 k = new KryoSerializableDefault2();
		k.setRegistrationRequired(!((Boolean) conf
				.get(Config.TOPOLOGY_FALL_BACK_ON_JAVA_SERIALIZATION)));
		k.setReferences(false);
		return k;
	}
}
```
这是一个很好的解决办法。		

+	###注意and发现
在LocalCluter中测试时发现当两个Compont(spout or bolt)在同一个worker process中时直接传输对象，不需要序列化传输,
所以，在测试时写了一个Spout（parallelism_hint=1），一个Bolt（parallelism_hint=1），并且conf.setNumWorkers(2)，这样spout和bolt会位于不同的worker process中，
观察日志，ProtoBuffSerializer working
