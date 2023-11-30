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

```ruby
execution.print
```

```
HelloWorld started * Flow_0e3d1ag

{
  "greet": true,
  "cookie": true
}

0 StartEvent Start: completed * out: Flow_0e3d1ag
1 UserTask IntroduceYourself: waiting * in: Flow_0e3d1ag
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
  "cookie": true,
  "result": {
    "greeting": "Ciao"
  },
  "fortune": "Help! I am being held prisoner in a fortune cookie factory.",
  "message": "Ciao Eric, 🥠 Help! I am being held prisoner in a fortune cookie factory."
}
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
