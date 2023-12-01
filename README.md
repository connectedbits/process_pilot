# Process Pilot

Process Pilot is a workflow gem for Rails applications based on the [bpmn](https://www.bpmn.org) standard. It executes business processes and rules defined in a [modeler](https://camunda.com/download/modeler/).

## Usage

Process Pilot executes business processes like [this one](/test/fixtures/files/hello_world.bpmn).

![Example](test/fixtures/files/hello_world.png)

To start a process, initialize Process Pilot with your BPMN source and call `start`.

```ruby
process = ProcessPilot.new(File.read("hello_world.bpmn")).start
```

The 'HelloWorld' process begins at the 'Start' event and _waits_ at the 'SayHello' service task. It's often useful to print the process state to the console.

```ruby
process.print
```

```bash
HelloWorld started * Flow_0zlro9p

0 StartEvent Start: completed * out: Flow_0zlro9p
1 ServiceTask SayHello: waiting * in: Flow_0zlro9p
```

In order to continue the process, you must _signal_ the waiting 'SayHello' task. The signal includes a hash of variables that are merged with the processes variables.

```ruby
waiting_task = process.step_by_element_id("SayHello") // or process.waiting_steps.first
waiting_task.signal({ message: "Hello World!" })
```

The signal completes the task and continues the process. The process ends at the 'End' event.

````bash
HelloWorld completed *

{
  "message": "Hello World!"
}

0 StartEvent Start: completed * out: Flow_0zlro9p
1 ServiceTask SayHello: completed { "message": "Hello World!" } * in: Flow_0zlro9p * out: Flow_1doumjv
2 EndEvent End: completed * in: Flow_1doumjv```
````

### Serialization

It's common to save the state of a process until a task is complete. For example, a User Task might be waiting for a person to complete a form or a Service Task might run in a background job. Process Pilot provides a `serialize` method that returns a hash of the process state that can be saved.

```ruby
serialized_state = process.serialize
```

Later, when the task is complete, deserialize the process state and call `continue`.

```ruby
process = ProcessPilot.new(File.read("hello_world.bpmn")).continue(serialized_state)
process.step_by_element_id("SayHello").signal({ message: "Hello World!" })
```

### Service Handlers

Sometime you want Process Pilot to handle a Service Task automatically. To do this, define a service handler and pass it to Process Pilot.

```ruby
services = {
  say_hello: -> (variables, properties) {
    { message: "Hello #{variables[:name]}!" }
  }
}
process = ProcessPilot.new(File.read("hello_world.bpmn", services: services)).start(variables: { name: "Eric" })
process.print
```

```bash
HelloWorld completed *

{
  "name": "Eric",
  "message": "Hello Eric!"
}

0 StartEvent Start: completed * out: Flow_0zlro9p
1 ServiceTask SayHello: completed { "message": "Hello Eric!" } * in: Flow_0zlro9p * out: Flow_1doumjv
2 EndEvent End: completed * in: Flow_1doumjv
```

### Kitchen Sink

TODO: Add a kitchen sink example.

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
