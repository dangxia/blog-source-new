title: Get the JVM Pid
date: 2015-11-25 11:18:02
tags: [java]
categories: [java]
---
```java
/**
  * Gets the pid of this JVM, because Java doesn't provide a real way to do this.
  * 
  * @return
  */
public static String process_pid() {
    String name = ManagementFactory.getRuntimeMXBean().getName();
    String[] split = name.split("@");
    if (split.length != 2) {
        throw new RuntimeException("Got unexpected process name: " + name);
    }

    return split[0];
}
```
