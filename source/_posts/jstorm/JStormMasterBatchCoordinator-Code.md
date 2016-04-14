title: MasterBatchCoordinator源码
date: 2015-12-02 14:46:49
tags: [jstorm]
---
#### CoordinatorState Zk
```
${spout_id}
  -coordinator
    -currtx 当前txid
    -currattempts txid => attempt
  -meta
    -txid1 存储的metaData
    -txid2
  -user
```

```java AttemptStatus
private static enum AttemptStatus {
  PROCESSING, PROCESSED, COMMITTING
}
```

```java
//multi spout state relate to zk
private List<TransactionalState> _states = new ArrayList();
//active Tx txid => {status,attempt}
//processing--[first ack]-->processed--[second ack]-->committing--[third ack]-->{removed,_currTransaction++}
//any status --[fail ack]-->{remove all larger or equals tx}
TreeMap<Long, TransactionStatus> _activeTx = new TreeMap<Long, TransactionStatus>();
TreeMap<Long, Integer> _attemptIds;

private SpoutOutputCollector _collector;
Long _currTransaction;
int _maxTransactionActive;

List<ITridentSpout.BatchCoordinator> _coordinators = new ArrayList();

List<String> _managedSpoutIds;
List<ITridentSpout> _spouts;
WindowedTimeThrottler _throttler;
```