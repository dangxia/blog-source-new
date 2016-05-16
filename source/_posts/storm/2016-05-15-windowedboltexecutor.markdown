---
layout: "post"
title: "WindowedBoltExecutor"
date: "2016-05-15 13:55"
categories: storm
---
document [Windowing Support in Core Storm][1]

### WindowLifecycleListener
```java
/**
 * A callback for expiry, activation of events tracked by the {@link WindowManager}
 *
 * @param <T> The type of Event in the window (e.g. Tuple).
 */
public interface WindowLifecycleListener<T> {
    /**
     * Called on expiry of events from the window due to {@link EvictionPolicy}
     *
     * @param events the expired events
     */
    void onExpiry(List<T> events);

    /**
     * Called on activation of the window due to the {@link TriggerPolicy}
     * @param events the list of current events in the window.
     * @param newEvents the newly added events since last activation.
     * @param expired the expired events since last activation.
     */
    void onActivation(List<T> events, List<T> newEvents, List<T> expired);
}
```
<!--more-->
`WindowedBoltExecutor`中的实现
```java
protected WindowLifecycleListener<Tuple> newWindowLifecycleListener() {
    return new WindowLifecycleListener<Tuple>() {
        @Override
        public void onExpiry(List<Tuple> tuples) {  
          //当tuples到期，调用ack，以实现WindowedBoltExecutor自动ack
            for (Tuple tuple : tuples) {
                windowedOutputCollector.ack(tuple);
            }
        }

        @Override
        public void onActivation(List<Tuple> tuples, List<Tuple> newTuples, List<Tuple> expiredTuples) {
          //自动锚定
            windowedOutputCollector.setContext(tuples);
            bolt.execute(new TupleWindowImpl(tuples, newTuples, expiredTuples));
        }
    };
}
```

### EvictionPolicy

```java
/**
 * Eviction policy tracks events and decides whether
 * an event should be evicted from the window or not.
 *
 * @param <T> the type of event that is tracked.
 */
public interface EvictionPolicy<T> {
    /**
     * The action to be taken when {@link EvictionPolicy#evict(Event)} is invoked.
     */
    enum Action {
        /**
         * expire the event and remove it from the queue
         */
        EXPIRE,
        /**
         * process the event in the current window of events
         */
        PROCESS,
        /**
         * don't include in the current window but keep the event
         * in the queue for evaluating as a part of future windows
         */
        KEEP,
        /**
         * stop processing the queue, there cannot be anymore events
         * satisfying the eviction policy
         */
        STOP
    }
    /**
     * Decides if an event should be expired from the window, processed in the current
     * window or kept for later processing.
     *
     * @param event the input event
     * @return the {@link org.apache.storm.windowing.EvictionPolicy.Action} to be taken based on the input event
     */
    Action evict(Event<T> event);

    /**
     * Tracks the event to later decide whether
     * {@link EvictionPolicy#evict(Event)} should evict it or not.
     *
     * @param event the input event to be tracked
     */
    void track(Event<T> event);

    /**
     * Sets a context in the eviction policy that can be used while evicting the events.
     * E.g. For TimeEvictionPolicy, this could be used to set the reference timestamp.
     *
     * @param context
     */
    void setContext(Object context);
}
```
+ CountEvictionPolicy

```java
@Override
public Action evict(Event<T> event) {
    /*
     * atomically decrement the count if its greater than threshold and
     * return if the event should be evicted
     */
    while (true) {
        int curVal = currentCount.get();
        if (curVal > threshold) {
            if (currentCount.compareAndSet(curVal, curVal - 1)) {
                return Action.EXPIRE;
            }
        } else {
            break;
        }
    }
    return Action.PROCESS;
}

@Override
public void track(Event<T> event) {
    if (!event.isWatermark()) {
        currentCount.incrementAndGet();
    }
}
```
+ TimeEvictionPolicy

```java
@Override
public Action evict(Event<T> event) {
    long now = referenceTime == null ? System.currentTimeMillis() : referenceTime;
    long diff = now - event.getTimestamp();
    if (diff >= windowLength) {
        return Action.EXPIRE;
    }
    return Action.PROCESS;
}

@Override
public void track(Event<T> event) {
    // NOOP
}

@Override
public void setContext(Object context) {
    referenceTime = ((Number) context).longValue();
}
```
+ WatermarkCountEvictionPolicy

```java
@Override
public Action evict(Event<T> event) {
    if (event.getTimestamp() <= referenceTime) {
        return super.evict(event);
    } else {
        return Action.KEEP;
    }
}

@Override
public void track(Event<T> event) {
    // NOOP
}

@Override
public void setContext(Object context) {
    referenceTime = (Long) context;
    currentCount.set(windowManager.getEventCount(referenceTime));
}
```
+ WatermarkTimeEvictionPolicy

```java
/**
 * {@inheritDoc}
 * <p/>
 * Keeps events with future ts in the queue for processing in the next
 * window. If the ts difference is more than the lag, stops scanning
 * the queue for the current window.
 */
@Override
public Action evict(Event<T> event) {
    long diff = referenceTime - event.getTimestamp();
    if (diff < -lag) {
        return Action.STOP;
    } else if (diff < 0) {
        return Action.KEEP;
    } else {
        return super.evict(event);
    }
}
```

### TriggerPolicy

```java
/**
 * Triggers the window calculations based on the policy.
 *
 * @param <T> the type of the event that is tracked
 */
public interface TriggerPolicy<T> {
    /**
     * Tracks the event and could use this to invoke the trigger.
     *
     * @param event the input event
     */
    void track(Event<T> event);

    /**
     * resets the trigger policy
     */
    void reset();

    /**
     * Starts the trigger policy. This can be used
     * during recovery to start the triggers after
     * recovery is complete.
     */
    void start();

    /**
     * Any clean up could be handled here.
     */
    void shutdown();
}
```
+ CountTriggerPolicy

```java
@Override
public void track(Event<T> event) {
    if (started && !event.isWatermark()) {
        if (currentCount.incrementAndGet() >= count) {
            evictionPolicy.setContext(System.currentTimeMillis());
            handler.onTrigger();
        }
    }
}
```
+ TimeTriggerPolicy

```java
private Runnable newTriggerTask() {
    return new Runnable() {
        @Override
        public void run() {
            try {
                /*
                 * set the current timestamp as the reference time for the eviction policy
                 * to evict the events
                 */
                if (evictionPolicy != null) {
                    evictionPolicy.setContext(System.currentTimeMillis());
                }
                handler.onTrigger();
            } catch (Throwable th) {
                LOG.error("handler.onTrigger failed ", th);
                /*
                 * propagate it so that task gets canceled and the exception
                 * can be retrieved from executorFuture.get()
                 */
                throw th;
            }
        }
    };
}
```
+ WatermarkCountTriggerPolicy

```java
/**
 * Triggers all the pending windows up to the waterMarkEvent timestamp
 * based on the sliding interval count.
 *
 * @param waterMarkEvent the watermark event
 */
private void handleWaterMarkEvent(Event<T> waterMarkEvent) {
    long watermarkTs = waterMarkEvent.getTimestamp();
    List<Long> eventTs = windowManager.getSlidingCountTimestamps(lastProcessedTs, watermarkTs, count);
    for (long ts : eventTs) {
        evictionPolicy.setContext(ts);
        handler.onTrigger();
        lastProcessedTs = ts;
    }
}
```
+ WatermarkTimeTriggerPolicy

```java
/**
 * Invokes the trigger all pending windows up to the
 * watermark timestamp. The end ts of the window is set
 * in the eviction policy context so that the events falling
 * within that window can be processed.
 */
private void handleWaterMarkEvent(Event<T> event) {
    long watermarkTs = event.getTimestamp();
    long windowEndTs = nextWindowEndTs;
    LOG.debug("Window end ts {} Watermark ts {}", windowEndTs, watermarkTs);
    while (windowEndTs <= watermarkTs) {
        evictionPolicy.setContext(windowEndTs);
        if (handler.onTrigger()) {
            windowEndTs += slidingIntervalMs;
        } else {
            /*
             * No events were found in the previous window interval.
             * Scan through the events in the queue to find the next
             * window intervals based on event ts.
             */
            long ts = getNextAlignedWindowTs(windowEndTs, watermarkTs);
            LOG.debug("Next aligned window end ts {}", ts);
            if (ts == Long.MAX_VALUE) {
                LOG.debug("No events to process between {} and watermark ts {}", windowEndTs, watermarkTs);
                break;
            }
            windowEndTs = ts;
        }
    }
    nextWindowEndTs = windowEndTs;
}

/**
 * Computes the next window by scanning the events in the window and
 * finds the next aligned window between the startTs and endTs. Return the end ts
 * of the next aligned window, i.e. the ts when the window should fire.
 *
 * @param startTs the start timestamp (excluding)
 * @param endTs the end timestamp (including)
 * @return the aligned window end ts for the next window or Long.MAX_VALUE if there
 * are no more events to be processed.
 */
private long getNextAlignedWindowTs(long startTs, long endTs) {
    long nextTs = windowManager.getEarliestEventTs(startTs, endTs);
    if (nextTs == Long.MAX_VALUE || (nextTs % slidingIntervalMs == 0)) {
        return nextTs;
    }
    return nextTs + (slidingIntervalMs - (nextTs % slidingIntervalMs));
}
```
### WaterMarkEventGenerator

```java
/**
 * Tracks the timestamp of the event in the stream, returns
 * true if the event can be considered for processing or
 * false if its a late event.
 */
public boolean track(GlobalStreamId stream, long ts) {
    Long currentVal = streamToTs.get(stream);
    if (currentVal == null || ts > currentVal) {
        streamToTs.put(stream, ts);
    }
    checkFailures();
    return ts >= lastWaterMarkTs;
}

@Override
public void run() {
    try {
        long waterMarkTs = computeWaterMarkTs();
        if (waterMarkTs > lastWaterMarkTs) {
            this.windowManager.add(new WaterMarkEvent<T>(waterMarkTs));
            lastWaterMarkTs = waterMarkTs;
        }
    } catch (Throwable th) {
        LOG.error("Failed while processing watermark event ", th);
        throw th;
    }
}

/**
 * Computes the min ts across all streams.
 */
private long computeWaterMarkTs() {
    long ts = 0;
    // only if some data has arrived on each input stream
    if (streamToTs.size() >= inputStreams.size()) {
        ts = Long.MAX_VALUE;
        for (Map.Entry<GlobalStreamId, Long> entry : streamToTs.entrySet()) {
            ts = Math.min(ts, entry.getValue());
        }
    }
    return ts - eventTsLag;
}
```
### WindowManager

```java
/**
 * Tracks a window event
 *
 * @param windowEvent the window event to track
 */
public void add(Event<T> windowEvent) {
    // watermark events are not added to the queue.
    if (!windowEvent.isWatermark()) {
        queue.add(windowEvent);
    } else {
        LOG.debug("Got watermark event with ts {}", windowEvent.getTimestamp());
    }
    track(windowEvent);
    compactWindow();
}

/**
 * The callback invoked by the trigger policy.
 */
@Override
public boolean onTrigger() {
    List<Event<T>> windowEvents = null;
    List<T> expired = null;
    try {
        lock.lock();
        /*
         * scan the entire window to handle out of order events in
         * the case of time based windows.
         */
        windowEvents = scanEvents(true);
        expired = new ArrayList<>(expiredEvents);
        expiredEvents.clear();
    } finally {
        lock.unlock();
    }
    List<T> events = new ArrayList<>();
    List<T> newEvents = new ArrayList<>();
    for (Event<T> event : windowEvents) {
        events.add(event.get());
        if (!prevWindowEvents.contains(event)) {
            newEvents.add(event.get());
        }
    }
    prevWindowEvents.clear();
    if (!events.isEmpty()) {
        prevWindowEvents.addAll(windowEvents);
        LOG.debug("invoking windowLifecycleListener onActivation, [{}] events in window.", events.size());
        windowLifecycleListener.onActivation(events, newEvents, expired);
    } else {
        LOG.debug("No events in the window, skipping onActivation");
    }
    triggerPolicy.reset();
    return !events.isEmpty();
}

public void shutdown() {
    LOG.debug("Shutting down WindowManager");
    if (triggerPolicy != null) {
        triggerPolicy.shutdown();
    }
}

/**
 * expires events that fall out of the window every
 * EXPIRE_EVENTS_THRESHOLD so that the window does not grow
 * too big.
 */
private void compactWindow() {
    if (eventsSinceLastExpiry.incrementAndGet() >= EXPIRE_EVENTS_THRESHOLD) {
        scanEvents(false);
    }
}

/**
 * feed the event to the eviction and trigger policies
 * for bookkeeping and optionally firing the trigger.
 */
private void track(Event<T> windowEvent) {
    evictionPolicy.track(windowEvent);
    triggerPolicy.track(windowEvent);
}

/**
 * Scan events in the queue, using the expiration policy to check
 * if the event should be evicted or not.
 *
 * @param fullScan if set, will scan the entire queue; if not set, will stop
 *                 as soon as an event not satisfying the expiration policy is found
 * @return the list of events to be processed as a part of the current window
 */
private List<Event<T>> scanEvents(boolean fullScan) {
    LOG.debug("Scan events, eviction policy {}", evictionPolicy);
    List<T> eventsToExpire = new ArrayList<>();
    List<Event<T>> eventsToProcess = new ArrayList<>();
    try {
        lock.lock();
        Iterator<Event<T>> it = queue.iterator();
        while (it.hasNext()) {
            Event<T> windowEvent = it.next();
            Action action = evictionPolicy.evict(windowEvent);
            if (action == EXPIRE) {
                eventsToExpire.add(windowEvent.get());
                it.remove();
            } else if (!fullScan || action == STOP) {
                break;
            } else if (action == PROCESS) {
                eventsToProcess.add(windowEvent);
            }
        }
        expiredEvents.addAll(eventsToExpire);
    } finally {
        lock.unlock();
    }
    eventsSinceLastExpiry.set(0);
    LOG.debug("[{}] events expired from window.", eventsToExpire.size());
    if (!eventsToExpire.isEmpty()) {
        LOG.debug("invoking windowLifecycleListener.onExpiry");
        windowLifecycleListener.onExpiry(eventsToExpire);
    }
    return eventsToProcess;
}

/**
 * Scans the event queue and returns the next earliest event ts
 * between the startTs and endTs
 *
 * @param startTs the start ts (exclusive)
 * @param endTs the end ts (inclusive)
 * @return the earliest event ts between startTs and endTs
 */
public long getEarliestEventTs(long startTs, long endTs) {
    long minTs = Long.MAX_VALUE;
    for (Event<T> event : queue) {
        if (event.getTimestamp() > startTs && event.getTimestamp() <= endTs) {
            minTs = Math.min(minTs, event.getTimestamp());
        }
    }
    return minTs;
}

/**
 * Scans the event queue and returns number of events having
 * timestamp less than or equal to the reference time.
 *
 * @param referenceTime the reference timestamp in millis
 * @return the count of events with timestamp less than or equal to referenceTime
 */
public int getEventCount(long referenceTime) {
    int count = 0;
    for (Event<T> event : queue) {
        if (event.getTimestamp() <= referenceTime) {
            ++count;
        }
    }
    return count;
}

/**
 * Scans the event queue and returns the list of event ts
 * falling between startTs (exclusive) and endTs (inclusive)
 * at each sliding interval counts.
 *
 * @param startTs the start timestamp (exclusive)
 * @param endTs the end timestamp (inclusive)
 * @param slidingCount the sliding interval count
 * @return the list of event ts
 */
public List<Long> getSlidingCountTimestamps(long startTs, long endTs, int slidingCount) {
    List<Long> timestamps = new ArrayList<>();
    if (endTs > startTs) {
        int count = 0;
        long ts = Long.MIN_VALUE;
        for (Event<T> event : queue) {
            if (event.getTimestamp() > startTs && event.getTimestamp() <= endTs) {
                ts = Math.max(ts, event.getTimestamp());
                if (++count % slidingCount == 0) {
                    timestamps.add(ts);
                }
            }
        }
    }
    return timestamps;
}
```
### 体会

#### 局限
不能适应长时间/大数据量的sliding
不适应多个sliding

#### watermark
`watermark = min(max(intputstream1.ts), max(intputstream2.ts), ...) - lag`
> 存在风险 当某个stream 不再接收到数据时，watermark将维持不变，从而影响全局的处理。

`watermark`只有在`ts in Tuple`是使用。
`watermark`确保早于`watermark`的数据已经ready，迟于`watermark`保持keep，再次接收到迟于`watermark`的数据将不再处理。
**WindowedBoltExecutor 中的处理可能存在问题，没有ack不处理的tuple，可能导致tuple超时replay**
```java
public void execute(Tuple input) {
    if (isTupleTs()) {
        long ts = input.getLongByField(tupleTsFieldName);
        if (waterMarkEventGenerator.track(input.getSourceGlobalStreamId(), ts)) {
            windowManager.add(input, ts);
        } else {
            LOG.info("Received a late tuple {} with ts {}. This will not processed.", input, ts);
        }
    } else {
        windowManager.add(input);
    }
}
```

**WatermarkCountTriggerPolicy 存在的问题**
当一个watermark时间内，同一个ts多于count的数据，只有windowLength会被处理，其余的会被expiry，或许设计就是如此。

#### compactWindow
避免了queue中的数据大于maxpending时，spout不再发送数据，而queue中的有效数据没有达到开启一个新window计算，job计算不能继续下去。
compactWindow 无效的数据被ack,spout可以发送新的数据。

[1]: http://storm.apache.org/releases/1.0.1/Windowing.html "Windowing Support in Core Storm"
