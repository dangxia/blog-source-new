title: TopologyBuilder源码
date: 2015-11-30 14:46:49
tags: [jstorm]
---
#### TopologyBuilder功能:
编织`ISpout，IBolt`的拓扑图，并生成StormTopology实例，以便thrift使用.

#### 用户编程的接口:IBolt，ISpout，IStateSpout
`IRichBolt，IBasicBolt，IRichSpout，IRichStateSpout`
+ `IBasicBolt`没有继承`IBolt`，在编织拓扑结构时，使用`BasicBoltExecutor`包装成`IRichBolt`
```java
public BoltDeclarer setBolt(String id, IBasicBolt bolt, Number parallelism_hint) {
    return setBolt(id, new BasicBoltExecutor(bolt), parallelism_hint);
}
```

+ `IRichStateSpout`暂时没有实现
```java
public void setStateSpout(String id, IRichStateSpout stateSpout, Number parallelism_hint) {
    validateUnusedId(id);
    // TODO: finish
}
```
<!--more-->
#### 编织拓扑图`BoltDeclarer，SpoutDeclarer`
`SpoutDeclarer`配置`IRichSpout`
`BoltDeclarer`配置`IRichBolt`并，通过grouping,配置`ComponentCommon`的`inputs`等。

#### `TopologyBuilder`与`IComponent`
```java
/**
 * Common methods for all possible components in a topology. This interface is used when defining topologies using the Java API.
 */
public interface IComponent extends Serializable {

    /**
     * Declare the output schema for all the streams of this topology.
     * 
     * @param declarer this is used to declare output stream ids, output fields, and whether or not each output stream is a direct stream
     */
    void declareOutputFields(OutputFieldsDeclarer declarer);

    /**
     * Declare configuration specific to this component. Only a subset of the "topology.*" configs can be overridden. The component configuration can be further
     * overridden when constructing the topology using {@link TopologyBuilder}
     * 
     */
    Map<String, Object> getComponentConfiguration();

}
```
TopologyBuilder#initCommon，调用ComponentConfiguration到ComponentCommon的json_conf中

```java TopologyBuilder#initCommon
private void initCommon(String id, IComponent component, Number parallelism) {
    ComponentCommon common = new ComponentCommon();
    common.set_inputs(new HashMap<GlobalStreamId, Grouping>());
    if (parallelism != null) {
        common.set_parallelism_hint(parallelism.intValue());
    } else {
        common.set_parallelism_hint(1);
    }
    Map conf = component.getComponentConfiguration();
    if (conf != null)
        common.set_json_conf(JSONValue.toJSONString(conf));
    _commons.put(id, common);
}
```
TopologyBuilder#getComponentCommon，调用getFieldsDeclaration到ComponentCommon的streams中
```java TopologyBuilder#getComponentCommon
private ComponentCommon getComponentCommon(String id, IComponent component) {
    ComponentCommon ret = new ComponentCommon(_commons.get(id));

    OutputFieldsGetter getter = new OutputFieldsGetter();
    component.declareOutputFields(getter);
    ret.set_streams(getter.getFieldsDeclaration());
    return ret;
}
```

#### 重点关注`ComponentCommon`
```
struct ComponentCommon {
  1: required map<GlobalStreamId, Grouping> inputs;
  2: required map<string, StreamInfo> streams; //key is stream id
  3: optional i32 parallelism_hint; //how many threads across the cluster should be dedicated to this component

  // component specific configuration respects:
  // topology.debug: false
  // topology.max.task.parallelism: null // can replace isDistributed with this
  // topology.max.spout.pending: null
  // topology.kryo.register // this is the only additive one
  
  // component specific configuration
  4: optional string json_conf;
}
```

`IComponent`是通过主动push的方式，这就涉及到问题push给谁？
从`ComponentCommon`定义来看，它只声明了生成的stream的相关信息。
```java Task#makeSendTargets
private TaskSendTargets makeSendTargets() {
    String component = topologyContext.getThisComponentId();

    // get current task's output
    // <Stream_id,<component, Grouping>>
    Map<String, Map<String, MkGrouper>> streamComponentGrouper = Common.outbound_components(topologyContext, workerData);

    return new TaskSendTargets(stormConf, component, streamComponentGrouper, topologyContext, taskStats);
}
```
`Common#outbound_components`从`ComponentCommon`声明中的谁消费什么，转变为我push给谁。
```java Common#outbound_components
public static Map<String, Map<String, MkGrouper>> outbound_components(TopologyContext topology_context, WorkerData workerData) {
    Map<String, Map<String, MkGrouper>> rr = new HashMap<String, Map<String, MkGrouper>>();

    // <Stream_id,<component,Grouping>>
    Map<String, Map<String, Grouping>> output_groupings = topology_context.getThisTargets();

    for (Entry<String, Map<String, Grouping>> entry : output_groupings.entrySet()) {

        String stream_id = entry.getKey();
        Map<String, Grouping> component_grouping = entry.getValue();

        Fields out_fields = topology_context.getThisOutputFields(stream_id);

        Map<String, MkGrouper> componentGrouper = new HashMap<String, MkGrouper>();

        for (Entry<String, Grouping> cg : component_grouping.entrySet()) {

            String component = cg.getKey();
            Grouping tgrouping = cg.getValue();

            List<Integer> outTasks = topology_context.getComponentTasks(component);
            // ATTENTION: If topology set one component parallelism as 0
            // so we don't need send tuple to it
            if (outTasks.size() > 0) {
                MkGrouper grouper = new MkGrouper(topology_context, out_fields, tgrouping, outTasks, stream_id, workerData);
                componentGrouper.put(component, grouper);
            }
            LOG.info("outbound_components, outTasks=" + outTasks + " for task-" + topology_context.getThisTaskId());
        }
        if (componentGrouper.size() > 0) {
            rr.put(stream_id, componentGrouper);
        }
    }
    return rr;
}
```

#### thrift
```
union JavaObjectArg {
  1: i32 int_arg;
  2: i64 long_arg;
  3: string string_arg;
  4: bool bool_arg;
  5: binary binary_arg;
  6: double double_arg;
}

struct JavaObject {
  1: required string full_class_name;
  2: required list<JavaObjectArg> args_list;
}

struct NullStruct {
  
}

struct GlobalStreamId {
  1: required string componentId;
  2: required string streamId;
  #Going to need to add an enum for the stream type (NORMAL or FAILURE)
}

union Grouping {
  1: list<string> fields; //empty list means global grouping
  2: NullStruct shuffle; // tuple is sent to random task
  3: NullStruct all; // tuple is sent to every task
  4: NullStruct none; // tuple is sent to a single task (storm's choice) -> allows storm to optimize the topology by bundling tasks into a single process
  5: NullStruct direct; // this bolt expects the source bolt to send tuples directly to it
  6: JavaObject custom_object;
  7: binary custom_serialized;
  8: NullStruct local_or_shuffle; // prefer sending to tasks in the same worker process, otherwise shuffle
  9: NullStruct localFirst; //  local worker shuffle > local node shuffle > other node shuffle
}

struct StreamInfo {
  1: required list<string> output_fields;
  2: required bool direct;
}

struct ShellComponent {
  // should change this to 1: required list<string> execution_command;
  1: string execution_command;
  2: string script;
}
union ComponentObject {
  1: binary serialized_java;
  2: ShellComponent shell;
  3: JavaObject java_object;
}

struct ComponentCommon {
  1: required map<GlobalStreamId, Grouping> inputs;
  2: required map<string, StreamInfo> streams; //key is stream id
  3: optional i32 parallelism_hint; //how many threads across the cluster should be dedicated to this component

  // component specific configuration respects:
  // topology.debug: false
  // topology.max.task.parallelism: null // can replace isDistributed with this
  // topology.max.spout.pending: null
  // topology.kryo.register // this is the only additive one
  
  // component specific configuration
  4: optional string json_conf;
}

struct SpoutSpec {
  1: required ComponentObject spout_object;
  2: required ComponentCommon common;
  // can force a spout to be non-distributed by overriding the component configuration
  // and setting TOPOLOGY_MAX_TASK_PARALLELISM to 1
}

struct Bolt {
  1: required ComponentObject bolt_object;
  2: required ComponentCommon common;
}

// not implemented yet
// this will eventually be the basis for subscription implementation in storm
struct StateSpoutSpec {
  1: required ComponentObject state_spout_object;
  2: required ComponentCommon common;
}

struct StormTopology {
  //ids must be unique across maps
  // #workers to use is in conf
  1: required map<string, SpoutSpec> spouts;
  2: required map<string, Bolt> bolts;
  3: required map<string, StateSpoutSpec> state_spouts;
}
```