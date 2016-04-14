title: JStormCache源码
date: 2015-11-25 14:46:49
tags: [jstorm]
---
### Interface
```java
void init(Map<Object, Object> conf) throws Exception;
void cleanup();
Object get(String key);
void getBatch(Map<String, Object> map);
void remove(String key);
void removeBatch(Collection<String> keys);
void put(String key, Object value, int timeoutSecond);
void put(String key, Object value);
void putBatch(Map<String, Object> map);
void putBatch(Map<String, Object> map, int timeoutSeconds);
```
### JStormCache的实现
+ com.alibaba.jstorm.cache.TimeoutMemCache
+ com.alibaba.jstorm.cache.RocksDBCache
+ com.alibaba.jstorm.cache.RocksTTLDBCache
<!--more-->
### TimeoutMemCache
`TreeMap<Integer, TimeCacheMap<String, Object>> cacheWindows`维持了多个timeout的TimeCacheMap:
+ default.cache.timeout default:60
+ cache.timeout.list  default:null

```java
@Override
public void put(String key, Object value, int timeoutSecond) {
    Entry<Integer, TimeCacheMap<String, Object>> ceilingEntry = cacheWindows.ceilingEntry(timeoutSecond);
    if (ceilingEntry == null) {
        put(key, value);
    } else {
        remove(key);
        ceilingEntry.getValue().put(key, value);
    }
}

@Override
public void put(String key, Object value) {
    remove(key);
    TimeCacheMap<String, Object> bestWindow = cacheWindows.get(defaultTimeout);
    bestWindow.put(key, value);
}
```

### RocksDBCache
使用RocksDB实现的一个key=>value持久化的DB.data_dir = ${storm.local.dir}/nimbus/rocksdb/
### RocksTTLDBCache
RocksDBCache的TTL实现,TreeMap<Integer, ColumnFamilyHandle> windowHandlers维持多个timeout的ColumnFamilyHandle
+ infinite lifetime `RocksDB.DEFAULT_COLUMN_FAMILY`
+ cache.timeout.list  default:null

```java
protected Entry<Integer, ColumnFamilyHandle> getHandler(int timeoutSecond) {
    ColumnFamilyHandle cfHandler = null;
    Entry<Integer, ColumnFamilyHandle> ceilingEntry = windowHandlers.ceilingEntry(timeoutSecond);
    if (ceilingEntry != null) {
        return ceilingEntry;
    } else {
        return windowHandlers.firstEntry();
    }
}
@Override
public void put(String key, Object value, int timeoutSecond) {
    // TODO Auto-generated method stub

    put(key, value, getHandler(timeoutSecond));

}
@Override
public void put(String key, Object value) {
    put(key, value, windowHandlers.firstEntry());
}
```

### NimbusCache
+ memCache 内存cache
+ dbCache DB cache
若dbCache为内存cache，memCache=dbCache;
```java
public String getNimbusCacheClass(Map conf) {
    boolean isLinux = OSInfo.isLinux();
    boolean isMac = OSInfo.isMac();
    boolean isLocal = StormConfig.local_mode(conf);

    if (isLocal == true) {
        return TIMEOUT_MEM_CACHE_CLASS;
    }

    if (isLinux == false && isMac == false) {
        return TIMEOUT_MEM_CACHE_CLASS;
    }

    String nimbusCacheClass = ConfigExtension.getNimbusCacheClass(conf);
    if (StringUtils.isBlank(nimbusCacheClass) == false) {
        return nimbusCacheClass;
    }

    return ROCKS_DB_CACHE_CLASS;

}
### JStormMetricCache
只有一个`JStormCache cache`与NimbusCache结构类似。

```
配置:
    ## Two type cache 
    ## "com.alibaba.jstorm.cache.TimeoutMemCache" is suitable for small cluster
    ## "com.alibaba.jstorm.cache.~~TimeoutMemCache~~RocksDBCache" can only run under linux/mac, it is suitable for huge cluster
    ## if it is null, it will detected by environment
    nimbus.cache.class: null
    ## if this is true, nimbus db cache will be reset when start nimbus
    nimbus.cache.reset: true
    cache.timeout.list: null