title: JStorm Local Dir
date: 2015-11-25 11:24:40
tags: [jstorm]
---
### storm.local.dir
```java
/**
  * A directory on the local filesystem used by Storm for any local filesystem usage it needs. The directory must exist and the Storm daemons must have
  * permission to read/write from this location.
  */
public static final String STORM_LOCAL_DIR = "storm.local.dir";
```

+ nimbus [nimbus local dir]
  + pids 
    + {$nimbus_pid}
  + rocksdb NimbusCache的data目录
+ metrics
  + rocksdb JStormMetricCache的data目录