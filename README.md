# Process Pilot

Process Pilot is a workflow gem for Rails applications based on the [bpmn](https://www.bpmn.org) standard. It executes business processes and rules defined in a [modeler](https://camunda.com/download/modeler/).

## Usage

Process Pilot executes business processes like [this one](/test/fixtures/files/hello_world.bpmn).

![Example](test/fixtures/files/hello_world.png)

To start a process, initialize Process Pilot with your BPMN source; then call start.

```ruby
execution = ProcessPilot.new(sources: "hello_world.bpmn").start(process: "Hello World", event: "Start", variables: { greet: true, cookie: false })
```

The process begins executing at the Start Event and continues until it reaches a task or the end of the process. It's often useful to print the current state of the Execution.

```
execution.print

HelloWorld running * Flow_016qg9x

{
  "greet": true,
  "cookie": true
}

0 StartEvent Start: completed * out: Flow_016qg9x
1 UserTask IntroduceYourself: waiting * in: Flow_016qg9x
2 BoundaryEvent Timeout: waiting
```

Here the `IntroduceYourself` User Task is `waiting` for completion. Since we can't continue the process until the user completes the task, we can serialize the current state of execution and save it in a Rails model.

```ruby
json = execution.serialize
```

Later, when the task has been completed, execution can be deserialized.

```ruby
execution = ProcessPilot.deserialize(json)
```

Now we can continue execution by signaling the `waiting` step.

```ruby
step = execution.step_by_element_id("IntroduceYourself")
step.signal({ name: "Eric", language: "it", formal: false, cookie: true })
```

When execution reaches an End Event the process is complete.

```ruby
execution.print
```

```
HelloWorld completed *

{
  "greet": true,
  "cookie": true,
  "name": "Eric",
  "language": "it",
  "formal": false,
  "tell_fortune": "This cookie contains 117 calories.",
  "greeting": "Ciao",
  "message": "👋 Ciao Eric 🥠 This cookie contains 117 calories."
}

0 StartEvent Start: completed * out: Flow_016qg9x
1 UserTask IntroduceYourself: completed { "name": "Eric", "language": "it", "formal": false } * in: Flow_016qg9x * out: Flow_0f1v8du
2 BoundaryEvent Timeout: terminated
3 InclusiveGateway Split: completed * in: Flow_0f1v8du * out: Flow_09yhdyi, Flow_00mppvp
4 ServiceTask TellFortune: completed { "tell_fortune": "This cookie contains 117 calories." } * in: Flow_09yhdyi * out: Flow_1t20i0c
5 BoundaryEvent Event_0c6rvx0: terminated
6 BusinessRuleTask ChooseGreeting: completed { "greeting": "Ciao" } * in: Flow_00mppvp * out: Flow_1ezhtuc
7 InclusiveGateway Join: completed * in: Flow_1t20i0c, Flow_1ezhtuc * out: Flow_1xiabfq
8 ScriptTask SayHello: completed { "message": "👋 Ciao Eric 🥠 This cookie contains 117 calories." } * in: Flow_1xiabfq * out: Flow_15lbcry
9 EndEvent End: completed * in: Flow_15lbcry
```

## Documentation

- [Processes](/docs/processes.md)
- [Tasks](/docs/tasks.md)
- [Events](/docs/events.md)
- [Event Definitions](/docs/event_definitions.md)
- [Gateways](/docs/gateways.md)
- [Expressions](/docs/expressions.md)
- [Data Flow](/docs/data_flow.md)
- [Execution](/docs/execution.md)

## Installation

Execute:

```bash
$ bundle add "process_pilot"
```

Or install it directly:

```bash
$ gem install process_pilot
```

## Development

```bash
$ git clone ...
$ bin/setup
$ bin/rake
$ bin/guard
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Developed by [Connected Bits](http://www.connectedbits.com)
