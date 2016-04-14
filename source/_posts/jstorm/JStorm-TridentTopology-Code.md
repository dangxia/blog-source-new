title: TridentTopology源码
date: 2015-11-30 14:46:49
tags: [jstorm]
---
#### 参考：
+ http://www.cnblogs.com/hseagle/p/3756862.html
+ http://www.flyne.org/article/216

从TridentTopology到基本的Topology有三层，下图给出一个全局的视图。下图引自[徽沪一郎][]的blog
![][trident-view]


#### TridentTopology属性
```java
//一个simple directed graph
DefaultDirectedGraph<Node, IndexedEdge> _graph;
//state.node.id=>[self,stateQueryNode]
Map<String, List<Node>> _colocate = new HashMap();
//生成唯一的stream,state的ID
UniqueIdGen _gen;
```

#### Node Type
+ Node
+ SpoutNode
+ ProcessorNode
+ PartitionNode

```java
public static enum SpoutType {
    DRPC, BATCH
}
```

`TridentTopology#newStream` create a BATCH `SpoutNode` with `ITridentSpout`,若不是`ITridentSpout`最终也会被包装成`ITridentSpout`
+ IRichSpout : RichSpoutBatchExecutor
+ IBatchSpout : BatchSpoutExecutor
+ IPartitionedTridentSpout : PartitionedTridentSpoutExecutor
+ IOpaquePartitionedTridentSpout : OpaquePartitionedTridentSpoutExecutor

`TridentTopology#newDRPCStream` create a DRPC `SpoutNode` with `DRPCSpout`，没有txid

`TridentTopology#newStaticState` create a `Node` with `NodeStateInfo`
奇怪，一直以为只会创建`Node`的子类？

### Node name，Stream name，StreamId
TridentTopology 直接创建的Node name都为空，相应的Stream的name也为空。
Stream的name可以通过Stream#name(String name)来修改，但与之相依的Node的name不能相应改变。
当在Stream通过operation创建新的Node时，Node的name为创建它的Stream的name。

Stream operation create new Node,generally,create a new stream id,except operation `partition`,new node using it's parent streamId.


#### build
```java TridentTopology#build
//其中mergedGroups为spoutGroup,boltGroup
//spoutNodes 为SpoutNode集合

//已经省略了，完成drpc的环，以及node合并成group等。

//node => batchGroupName,ex:bg0,bg1
//可能有多个batchGroup,亲测可以{没有连接的多个拓扑图}
Map<Node, String> batchGroupMap = new HashMap();
List<Set<Node>> connectedComponents = new ConnectivityInspector<Node, IndexedEdge>(graph).connectedSets();
for (int i = 0; i < connectedComponents.size(); i++) {
  String groupId = "bg" + i;
  for (Node n : connectedComponents.get(i)) {
    batchGroupMap.put(n, groupId);
  }
}

//计算每个Group的parallelism
Map<Group, Integer> parallelisms = getGroupParallelisms(graph, grouper, mergedGroups);

TridentTopologyBuilder builder = new TridentTopologyBuilder();

//spoutNode => spoutId ,ex:spout0,spout1 String为componentId
Map<Node, String> spoutIds = genSpoutIds(spoutNodes);
//opretionNode => boltId,ex:b-0,b-1,b-2-kkk String为componentId
Map<Group, String> boltIds = genBoltIds(mergedGroups);

for (SpoutNode sn : spoutNodes) {
  Integer parallelism = parallelisms.get(grouper.nodeGroup(sn));
  if (sn.type == SpoutNode.SpoutType.DRPC) {
    //spout0,s0,IRichSpout,parallelism,bg0
    builder.setBatchPerTupleSpout(spoutIds.get(sn), sn.streamId, (IRichSpout) sn.spout, parallelism,
        batchGroupMap.get(sn));
  } else {
    ITridentSpout s;
    if (sn.spout instanceof IBatchSpout) {
      s = new BatchSpoutExecutor((IBatchSpout) sn.spout);
    } else if (sn.spout instanceof ITridentSpout) {
      s = (ITridentSpout) sn.spout;
    } else {
      throw new RuntimeException(
          "Regular rich spouts not supported yet... try wrapping in a RichSpoutBatchExecutor");
      // TODO: handle regular rich spout without batches (need
      // lots of updates to support this throughout)
    }
    //spout0,s0,txStateId,ITridentSpout,parallelism,bg0
    builder.setSpout(spoutIds.get(sn), sn.streamId, sn.txId, s, parallelism, batchGroupMap.get(sn));
  }
}

for (Group g : mergedGroups) {
  if (!isSpoutGroup(g)) {
    Integer p = parallelisms.get(g);
    //stream to batchGroup {s0=>bg0}
    Map<String, String> streamToGroup = getOutputStreamBatchGroups(g, batchGroupMap);
    //b-0,SubtopologyBolt(graph, g.nodes, batchGroupMap),parallelism,{bg0},{s0=>bg0}
    BoltDeclarer d = builder.setBolt(boltIds.get(g), new SubtopologyBolt(graph, g.nodes, batchGroupMap), p,
        committerBatches(g, batchGroupMap), streamToGroup);
    Collection<PartitionNode> inputs = uniquedSubscriptions(externalGroupInputs(g));
    for (PartitionNode n : inputs) {
      Node parent = TridentUtils.getParent(graph, n);
      String componentId;
      if (parent instanceof SpoutNode) {
        componentId = spoutIds.get(parent);
      } else {
        componentId = boltIds.get(grouper.nodeGroup(parent));
      }
      d.grouping(new GlobalStreamId(componentId, n.streamId), n.thriftGrouping);
    }
  }
}

return builder.buildTopology();
```


```java TridentTopologyBuilder#setBatchPerTupleSpout
public SpoutDeclarer setBatchPerTupleSpout(String id, String streamName, IRichSpout spout, Integer parallelism,
      String batchGroup) {
  Map<String, String> batchGroups = new HashMap();
  batchGroups.put(streamName, batchGroup);
  //_batchIds.put(new GlobalStreamId(id, streamName), batchGroup);GlobalStreamId=>batchGroup
  markBatchGroups(id, batchGroups);
  SpoutComponent c = new SpoutComponent(spout, streamName, parallelism, batchGroup);
  //componentId => SpoutComponent
  _batchPerTupleSpouts.put(id, c);
  return new SpoutDeclarerImpl(c);
}
```

```java TridentTopologyBuilder#setSpout
public SpoutDeclarer setSpout(String id, String streamName, String txStateId, ITridentSpout spout,
      Integer parallelism, String batchGroup) {
  Map<String, String> batchGroups = new HashMap();
  batchGroups.put(streamName, batchGroup);
  markBatchGroups(id, batchGroups);

  TransactionalSpoutComponent c = new TransactionalSpoutComponent(spout, streamName, parallelism, txStateId,
      batchGroup);
  _spouts.put(id, c);
  return new SpoutDeclarerImpl(c);
}
```





[trident-view]: /img/jstorm/trident-view.png  "trident-view"
[徽沪一郎]: http://www.cnblogs.com/hseagle/p/3490635.html "徽沪一郎"