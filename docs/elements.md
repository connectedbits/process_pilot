# Supported BPMN Elements

- [x] Process

A process is the work someone (or something) does to accomplish an objective. A process represents a sequence of activities in the form of a graph.

- [x] Sequence Flow

A sequence flow represents the transition in a process from one activity to another. Sequence flows can specify conditions that are checked to determine if the path should be taken.

## Activities

An activity represents a unit of work performed (a step inside a process). It has a defined start and end and generally requires some kind of input to produce an output. Processable supports the following activities:

- [ ] SubProcess

On the other hand, a SubProcess (Embedded, Event, or AdHoc) has parts that are modeled in a child-level process, a process with its own activity flow and start and end states. 

- [ ] CallActivity

A CallActivity invokes a process that is defined external to the model enabling reuse.

A task (Task, UserTask, ServiceTask, ScriptTask, BusinessRuleTask) has no internal parts, it represents a single action.

- [x] Task 

This is a generic representation of a task.

- [ ] User Task

This task represents work done by a human user.

- [ ] Service Task

This task represents work done by a ruby service proc when supplied to the Processable context.

- [ ] Script Task

This task represents work done by the Processable runtime written in Javascript.

- [ ] Business Rule Task

This task represents work done by the Processable rule engine, generally, a complex decision.

## Events

An event is something important that happens during a business process. Events are classified by their:

* Trigger: why the event is fired (ie: reception of message, time condition, etc.)
* Behavior: throwing/catching, interupting/non-interupting
* Type: start, end, intermediate, boundary

This engine supports the following event types:

- [ ] Start Event

Represents the start of a process or subprocess.

- [ ] Boundary Event

Intermediate events are either placed between activities or attached to the boundary of an activity. The latter are called boundary events. Boundary events are entered when the attached element is started and wait for an event to occur such as a timer, message, or error. Boundary events can be interupting or non-interupting. If the host ends before an event occurs the boundary events are canceled.

- [ ] Intermediate Throw Event

- [ ] Intermediate Catch Event

- [ ] End Event

## Event Definitions

Event definitions describe the behavior of an event.

- [ ] Message Event Definition

- [ ] Signal Event Definition

- [ ] Terminate Event Definition

- [ ] Timer Event Definition

- [ ] Error Event Definition

## Gateways

Gateways are elements that control the flow of the process. For example if you want to include alternative paths depending on the output of something, you use a gateway.

Gateways have two behaviors:

* Converging, how they handle incoming flows.
* Diverging, how they handle outgoing flows.

This engine supports the following gateway types:

- [x] Exclusive Gateway

An exclusive gateway evaluates all outgoing paths and the token flows into one of the two or more mutally exclusive paths. One of the conditions must evaluate to true. If none of the conditions evaluate to true the process will get stuck. For this reason it's always a good idea to have a default path.

- [ ] Event Based Gateway

An event-based gateway is similar to an exclusive gateway because both involve one path in the flow. In the case of an event-based gateway, however, you evaluate which event has occurred, not which condition has been met. Once the event occurs, all other waiting events are canceled.

- [ ] Parallel Gateway

A parallel gateway generates a token for each outgoing path and doesn't evaluate any conditions.

- [ ] Inclusive Gateway

An inclusive gateway breaks the process flow into one or more flows. It behaves like a parallel gateway execept the conditions are checked on each path and only those paths (or default) will be taken.