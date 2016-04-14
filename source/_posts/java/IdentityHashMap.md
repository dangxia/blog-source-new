title: IdentityHashMap
date: 2015-11-06 09:35:36
tags: [java,map]
category: java
---
[IdentityHashMap.html](http://tool.oschina.net/uploads/apidocs/jdk-zh/java/util/IdentityHashMap.html)
[http://www.28im.com/java/a757966.html](http://www.28im.com/java/a757966.html)
[bitops](http://www.leepoint.net/data/expressions/bitops.html)
[URL_URI_URN](http://www.ibm.com/developerworks/cn/xml/x-urlni.html)
load factor = 2 / 3
max = capacity * $(load factor)
table[2i] = key
table[2i+1] = value
linear probing
```java hash nextKeyIndex
private static int hash(Object x, int length) {
  int h = System.identityHashCode(x);
  // Multiply by -127, and left-shift to use least bit as part of hash
  return ((h << 1) - (h << 8)) & (length - 1);
}

/**
  * Circularly traverses table of size len.
  */
private static int nextKeyIndex(int i, int len) {
   return (i + 2 < len ? i + 2 : 0);
}
```
```java put get remove
public V put(K key, V value) {
  Object k = maskNull(key);
  Object[] tab = table;
  int len = tab.length;
  int i = hash(k, len);

  Object item;
  while ( (item = tab[i]) != null) {
    if (item == k) {
        V oldValue = (V) tab[i + 1];
        tab[i + 1] = value;
        return oldValue;
    }
    i = nextKeyIndex(i, len);
  }

  modCount++;
  tab[i] = k;
  tab[i + 1] = value;
  if (++size >= threshold)
    resize(len); // len == 2 * current capacity.
  return null;
}

public V get(Object key) {
    Object k = maskNull(key);
    Object[] tab = table;
    int len = tab.length;
    int i = hash(k, len);
    while (true) {
        Object item = tab[i];
        if (item == k)
            return (V) tab[i + 1];
        if (item == null)
            return null;
        i = nextKeyIndex(i, len);
    }
}

private void closeDeletion(int d) {
    // Adapted from Knuth Section 6.4 Algorithm R
    Object[] tab = table;
    int len = tab.length;

    // Look for items to swap into newly vacated slot
    // starting at index immediately following deletion,
    // and continuing until a null slot is seen, indicating
    // the end of a run of possibly-colliding keys.
    Object item;
    for (int i = nextKeyIndex(d, len); (item = tab[i]) != null;
      i = nextKeyIndex(i, len) ) {
      // The following test triggers if the item at slot i (which
      // hashes to be at slot r) should take the spot vacated by d.
      // If so, we swap it in, and then continue with d now at the
      // newly vacated i.  This process will terminate when we hit
      // the null slot at the end of this run.
      // The test is messy because we are using a circular table.
      int r = hash(item, len);
      if ((i < r && (r <= d || d <= i)) || (r <= d && d <= i)) {
          tab[d] = item;
          tab[d + 1] = tab[i + 1];
          tab[i] = null;
          tab[i + 1] = null;
          d = i;
      }
    }
}
```

