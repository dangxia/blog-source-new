title: redis-transactions
date: 2015-07-03 10:40:36
tags: [redis]
category : redis
---
[MULTI][MULTI], [EXEC][EXEC], [DISCARD][DISCARD] and [WATCH][WATCH] are the foundation of transactions in Redis. They allow the execution of a group of commands in a single step, with two important guarantees:
+ All the commands in a transaction are serialized and executed sequentially. It can never happen that a request issued by another client is served **in the middle of** the execution of a Redis transaction. This guarantees that the commands are executed as a single isolated operation.
+ Either all of the commands or none are processed, so a Redis transaction is also atomic. The [EXEC][EXEC] command triggers the execution of all the commands in the transaction, so if a client loses the connection to the server in the context of a transaction before calling the [MULTI][MULTI] command none of the operations are performed, instead if the [EXEC][EXEC] command is called, all the operations are performed. When using the append-only file Redis makes sure to use a single write(2) syscall to write the transaction on disk. However if the Redis server crashes or is killed by the system administrator in some hard way it is possible that only a partial number of operations are registered. Redis will detect this condition at restart, and will exit with an error. Using the redis-check-aof tool it is possible to fix the append only file that will remove the partial transaction so that the server can start again.

Starting with version 2.2, Redis allows for an extra guarantee to the above two, in the form of optimistic locking in a way very similar to a check-and-set (CAS) operation. This is documented later on this page.
## Usage
A Redis transaction is entered using the [MULTI][MULTI] command. The command always replies with OK. At this point the user can issue multiple commands. Instead of executing these commands, Redis will queue them. All the commands are executed once [EXEC][EXEC] is called.
Calling [DISCARD][DISCARD] instead will flush the transaction queue and will exit the transaction.
The following example increments keys foo and bar atomically.
    > MULTI
    OK
    > INCR foo
    QUEUED
    > INCR bar
    QUEUED
    > EXEC
    1) (integer) 1
    2) (integer) 1

As it is possible to see from the session above, [EXEC][EXEC] returns an array of replies, where every element is the reply of a single command in the transaction, in the same order the commands were issued.
When a Redis connection is in the context of a [MULTI][MULTI] request, all commands will reply with the string QUEUED (sent as a Status Reply from the point of view of the Redis protocol). A queued command is simply scheduled for execution when [EXEC][EXEC] is called.
<!--more-->
## Errors inside a transaction
During a transaction it is possible to encounter two kind of command errors:
+ A command may fail to be queued, so there may be an error before [EXEC][EXEC] is called. For instance the command may be syntactically wrong (wrong number of arguments, wrong command name, ...), or there may be some critical condition like an out of memory condition (if the server is configured to have a memory limit using the maxmemory directive).
+ A command may fail after [EXEC][EXEC] is called, for instance since we performed an operation against a key with the wrong value (like calling a list operation against a string value).

Clients used to sense the first kind of errors, happening before the [EXEC][EXEC] call, by checking the return value of the queued command: if the command replies with QUEUED it was queued correctly, otherwise Redis returns an error. If there is an error while queueing a command, most clients will abort the transaction discarding it.
However starting with Redis 2.6.5, the server will remember that there was an error during the accumulation of commands, and will refuse to execute the transaction returning also an error during [EXEC][EXEC], and discarding the transaction automatically.
Before Redis 2.6.5 the behavior was to execute the transaction with just the subset of commands queued successfully in case the client called [EXEC][EXEC] regardless of previous errors. The new behavior makes it much more simple to mix transactions with pipelining, so that the whole transaction can be sent at once, reading all the replies later at once.
Errors happening after [EXEC][EXEC] instead are not handled in a special way: all the other commands will be executed even if some command fails during the transaction.
This is more clear on the protocol level. In the following example one command will fail when executed even if the syntax is right:

    Trying 127.0.0.1...
    Connected to localhost.
    Escape character is '^]'.
    MULTI
    +OK
    SET a 3
    abc
    +QUEUED
    LPOP a
    +QUEUED
    EXEC
    *2
    +OK
    -ERR Operation against a key holding the wrong kind of value

[EXEC][EXEC] returned two-element Bulk string reply where one is an OK code and the other an -ERR reply. It's up to the client library to find a sensible way to provide the error to the user.
It's important to note that **even when a command fails, all the other commands in the queue are processed** – Redis will not stop the processing of commands.
Another example, again using the wire protocol with telnet, shows how syntax errors are reported ASAP instead:

    MULTI
    +OK
    INCR a b c
    -ERR wrong number of arguments for 'incr' command

This time due to the syntax error the bad INCR command is not queued at all.

## Why Redis does not support roll backs?
If you have a relational databases background, the fact that Redis commands can fail during a transaction, but still Redis will execute the rest of the transaction instead of rolling back, may look odd to you.
However there are good opinions for this behavior:
+ Redis commands can fail only if called with a wrong syntax (and the problem is not detectable during the command queueing), or against keys holding the wrong data type: this means that in practical terms a failing command is the result of a programming errors, and a kind of error that is very likely to be detected during development, and not in production.
+ Redis is internally simplified and faster because it does not need the ability to roll back.

An argument against Redis point of view is that bugs happen, however it should be noted that in general the roll back does not save you from programming errors. For instance if a query increments a key by 2 instead of 1, or increments the wrong key, there is no way for a rollback mechanism to help. Given that no one can save the programmer from his errors, and that the kind of errors required for a Redis command to fail are unlikely to enter in production, we selected the simpler and faster approach of not supporting roll backs on errors.

## Discarding the command queue
[DISCARD][DISCARD] can be used in order to abort a transaction. In this case, no commands are executed and the state of the connection is restored to normal.

    > SET foo 1
    OK
    > MULTI
    OK
    > INCR foo
    QUEUED
    > DISCARD
    OK
    > GET foo
    "1"

## Optimistic locking using check-and-set
[WATCH][WATCH] is used to provide a check-and-set (CAS) behavior to Redis transactions.
[WATCH][WATCH]ed keys are monitored in order to detect changes against them. If at least one watched key is modified before the [EXEC][EXEC] command, the whole transaction aborts, and [EXEC][EXEC] returns a Null reply to notify that the transaction failed.
For example, imagine we have the need to atomically increment the value of a key by 1 (let's suppose Redis doesn't have INCR).
The first try may be the following:

    val = GET mykey
    val = val + 1
    SET mykey $val

This will work reliably only if we have a single client performing the operation in a given time. If multiple clients try to increment the key at about the same time there will be a race condition. For instance, client A and B will read the old value, for instance, 10. The value will be incremented to 11 by both the clients, and finally SET as the value of the key. So the final value will be 11 instead of 12.
Thanks to [WATCH][WATCH] we are able to model the problem very well:

    WATCH mykey
    val = GET mykey
    val = val + 1
    MULTI
    SET mykey $val
    EXEC

Using the above code, if there are race conditions and another client modifies the result of val in the time between our call to [WATCH][WATCH] and our call to [EXEC][EXEC], the transaction will fail.
We just have to repeat the operation hoping this time we'll not get a new race. This form of locking is called optimistic locking and is a very powerful form of locking. In many use cases, multiple clients will be accessing different keys, so collisions are unlikely – usually there's no need to repeat the operation.

## [WATCH][WATCH] explained
So what is [WATCH][WATCH] really about? It is a command that will make the [EXEC][EXEC] conditional: we are asking Redis to perform the transaction only if no other client modified any of the WATCHed keys. Otherwise the transaction is not entered at all. (**Note that if you [WATCH][WATCH] a volatile key and Redis expires the key after you WATCHed it, [EXEC][EXEC] will still work. More on this.**)
[WATCH][WATCH] can be called multiple times. Simply all the [WATCH][WATCH] calls will have the effects to watch for changes starting from the call, up to the moment [EXEC][EXEC] is called. You can also send any number of keys to a single [WATCH][WATCH] call.
When [EXEC][EXEC] is called, all keys are UNWATCHed, regardless of whether the transaction was aborted or not. Also when a client connection is closed, everything gets UNWATCHed.
It is also possible to use the [UNWATCH][UNWATCH] command (without arguments) in order to flush all the watched keys. Sometimes this is useful as we optimistically lock a few keys, since possibly we need to perform a transaction to alter those keys, but after reading the current content of the keys we don't want to proceed. When this happens we just call [UNWATCH][UNWATCH] so that the connection can already be used freely for new transactions.

## Using [WATCH][WATCH] to implement ZPOP
A good example to illustrate how [WATCH][WATCH] can be used to create new atomic operations otherwise not supported by Redis is to implement ZPOP, that is a command that pops the element with the lower score from a sorted set in an atomic way. This is the simplest implementation:

    WATCH zset
    element = ZRANGE zset 0 0
    MULTI
    ZREM zset element
    EXEC

If [EXEC][EXEC] fails (i.e. returns a Null reply) we just repeat the operation.

## Redis scripting and transactions
A Redis script is transactional by definition, so everything you can do with a Redis transaction, you can also do with a script, and usually the script will be both simpler and faster.
This duplication is due to the fact that scripting was introduced in Redis 2.6 while transactions already existed long before. However we are unlikely to remove the support for transactions in the short time because it seems semantically opportune that even without resorting to Redis scripting it is still possible to avoid race conditions, especially since the implementation complexity of Redis transactions is minimal.
However it is not impossible that in a non immediate future we'll see that the whole user base is just using scripts. If this happens we may deprecate and finally remove transactions.
## Jedis
```java usage
public static void usage() {
  Jedis jedis = RedisCreator.createJedis();
  Transaction transaction = jedis.multi();
  Response<Long> foo = transaction.incr("foo");
  Response<Long> bar = transaction.incr("bar");
  List<Object> results = transaction.exec();
  jedis.close();

  LOG.info("foo: " + foo.get());
  LOG.info("bar: " + bar.get());
  LOG.info("results: " + (Joiner.on(',').join(results)));
}
```
    [INFO ] 14:40:14,511  foo: 1
    [INFO ] 14:40:14,511  bar: 1
    [INFO ] 14:40:14,536  results: 1,1

```java error
public static void error() {
  Jedis jedis = RedisCreator.createJedis();
  Transaction transaction = jedis.multi();
  Response<String> r1 = transaction.set("a", "1");
  Response<String> r2 = transaction.lpop("a");
  Response<String> r3 = transaction.set("a", "2");
  List<Object> results = transaction.exec();
  jedis.close();

  LOG.info("r1: " + r1.get());
  try {
    LOG.info("r2: " + r2.get());
  } catch (Exception e) {
    LOG.warn("r2 get() throw a exception", e);
  }
  LOG.info("r3: " + r3.get());
  LOG.info("results: " + (Joiner.on(',').join(results)));
}
```

    [INFO ] 14:42:12,900  r1: OK
    [WARN ] 14:42:12,901  r2 get() throw a exception
    redis.clients.jedis.exceptions.JedisDataException: WRONGTYPE Operation against a key holding the wrong kind of value
      at redis.clients.jedis.Protocol.processError(Protocol.java:117)
      at redis.clients.jedis.Protocol.process(Protocol.java:142)
      at redis.clients.jedis.Protocol.processMultiBulkReply(Protocol.java:187)
      at redis.clients.jedis.Protocol.process(Protocol.java:138)
      at redis.clients.jedis.Protocol.read(Protocol.java:196)
      at redis.clients.jedis.Connection.readProtocolWithCheckingBroken(Connection.java:288)
      at redis.clients.jedis.Connection.getRawObjectMultiBulkReply(Connection.java:233)
      at redis.clients.jedis.Connection.getObjectMultiBulkReply(Connection.java:239)
      at redis.clients.jedis.Transaction.exec(Transaction.java:38)
      at com.github.dangxia.jedis.RedisTransactions.error(RedisTransactions.java:39)
      at com.github.dangxia.jedis.RedisTransactions.main(RedisTransactions.java:53)
    [INFO ] 14:42:12,904  r3: OK
    [INFO ] 14:42:12,908  results: OK,redis.clients.jedis.exceptions.JedisDataException: WRONGTYPE Operation against a key holding the wrong kind of value,OK


```java testWatchFailed
public static void testWatchFailed() throws InterruptedException {
  final CountDownLatch countDownLatch = new CountDownLatch(1);
  final CountDownLatch countDownLatch2 = new CountDownLatch(1);
  new Thread() {
    public void run() {
      try {
        countDownLatch.await();
        Jedis jedis = RedisCreator.createJedis();
        jedis.set(WATCHED_KEY, "10");
        jedis.close();
        countDownLatch2.countDown();
      } catch (Exception e) {
      }

    };
  }.start();
  Jedis jedis = RedisCreator.createJedis();
  jedis.set(WATCHED_KEY, "10");
  jedis.watch(WATCHED_KEY);
  countDownLatch.countDown();
  countDownLatch2.await();
  Transaction transaction = jedis.multi();
  Response<String> setResp = transaction.set(WATCHED_KEY, "1");
  List<Object> results = transaction.exec();
  jedis.close();
  LOG.info("results :" + String.valueOf(results));
  try {
    LOG.info("setResp :" + String.valueOf(setResp.get()));
  } catch (Exception e) {
    LOG.warn("watched keys changed", e);
  }
}
```

    [INFO ] 14:44:04,185  results :null
    [WARN ] 14:44:04,186  watched keys changed
    redis.clients.jedis.exceptions.JedisDataException: Please close pipeline or multi block before calling this method.
      at redis.clients.jedis.Response.get(Response.java:33)
      at com.github.dangxia.jedis.RedisTransactions.testWatchFailed(RedisTransactions.java:83)
      at com.github.dangxia.jedis.RedisTransactions.main(RedisTransactions.java:53)


```java CAS
public static void testWatch() throws InterruptedException {
  Jedis jedis = RedisCreator.createJedis();
  jedis.del(WATCHED_KEY);

  int threadNum = 10;
  CountDownLatch countDownLatch = new CountDownLatch(threadNum);

  for (int i = 0; i < threadNum; i++) {
    new Incr(countDownLatch).start();
  }

  countDownLatch.await();

  LOG.info(jedis.get(WATCHED_KEY));
  jedis.close();
}
public static class Incr extends Thread {
  private final Jedis jedis;
  private final CountDownLatch countDownLatch;
  private long retryTimes = 0l;

  public Incr(CountDownLatch countDownLatch) {
    this.jedis = RedisCreator.createJedis();
    this.countDownLatch = countDownLatch;
  }

  protected void incr() {
    while (true) {
      if (doIncr()) {
        break;
      } else {
        retryTimes++;
      }
    }
  }

  protected boolean doIncr() {
    jedis.watch(WATCHED_KEY);
    String val = jedis.get(WATCHED_KEY);
    Transaction transaction = jedis.multi();
    if (val == null) {
      transaction.set(WATCHED_KEY, "1");
    } else {
      transaction.set(WATCHED_KEY,
          String.valueOf(Integer.parseInt(val) + 1));
    }
    List<Object> results = transaction.exec();
    if (results == null) {
      return false;
    }
    return true;
  }

  @Override
  public void run() {
    int i = 0;
    while (i++ < 100) {
      incr();
    }
    LOG.info(getName() + " retry " + retryTimes + " times");
    jedis.close();
    countDownLatch.countDown();
  }
}
```

    [INFO ] 14:46:22,540  Thread-7 retry 376 times
    [INFO ] 14:46:24,389  Thread-2 retry 480 times
    [INFO ] 14:46:25,673  Thread-6 retry 542 times
    [INFO ] 14:46:25,802  Thread-1 retry 570 times
    [INFO ] 14:46:26,843  Thread-5 retry 616 times
    [INFO ] 14:46:27,093  Thread-8 retry 631 times
    [INFO ] 14:46:27,275  Thread-0 retry 650 times
    [INFO ] 14:46:27,638  Thread-4 retry 660 times
    [INFO ] 14:46:28,060  Thread-9 retry 672 times
    [INFO ] 14:46:28,794  Thread-3 retry 696 times
    [INFO ] 14:46:28,800  1000

## copy from
[transactions][transactions]

[DISCARD]: http://redis.io/commands/discard
[EXEC]: http://redis.io/commands/exec
[MULTI]: http://redis.io/commands/multi
[UNWATCH]: http://redis.io/commands/unwatch
[WATCH]: http://redis.io/commands/watch

[transactions]: http://redis.io/topics/transactions