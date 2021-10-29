# Processable

Processable is a workflow gem for Rails applications based on the [bpmn](https://www.bpmn.org) standard. It executes business processes and rules defined in a [modeler](https://camunda.com/download/modeler/).

## Usage

Processable executes BPMN documents like [this one](/test/fixtures/hello_world.bpmn). 

![Example](test/fixtures/files/hello_world.png)

Before executing a [Process](lib/bpmn/process.rb) the [Runtime](lib/processable/runtime.rb) must be initialized with sources and other configuration information.

```ruby
services = {
  tell_fortune: proc { |variables|
    raise "Fortune not found? Abort, Retry, Ignore." if variables[:error]
    [
      "The fortune you seek is in another cookie.",
      "A cynic is only a frustrated optimist.",
      "A foolish man listens to his heart. A wise man listens to cookies.",
      "Avoid taking unnecessary gambles. Lucky numbers: 12, 15, 23, 28, 37",
      "Ask your mom instead of a cookie.",
      "Hard work pays off in the future. Laziness pays off now.",
      "Don’t eat the paper.",
    ].sample
  }
}
runtime = Processable::Runtime.new(sources: [File.read('hello_world.bpmn'), File.read('choose_greeting.dmn')], services: services)
```

With the runtime initialized a process can be started by calling `start_process` and passing the process id and start event id.

```ruby
execution = runtime.start_process(process_id: 'HelloWorld', start_event_id: 'Start', variables: { greet: true, cookie: false })
```

The runtime with return an [Execution](lib/processable/execution.rb) instance. It is often useful to `print` the execution's current state.

```ruby
execution.print
```

```
HelloWorld started * Flow_016qg9x

{
  "greet": true,
  "cookie": false
}

0 StartEvent Start: ended * out: Flow_016qg9x
1 UserTask IntroduceYourself: waiting * in: Flow_016qg9x
2 BoundaryEvent Timeout: waiting * in: 
```

The output shows the process id, it's current state, and active tokens. Below it shows the processes' variables followed by a list of [StepExecution](/lib/processable/step_execution.rb). Each step execution displays the element type, id, status, and tokens in and out.

In this case the process execution has stopped since the UserTask IntroduceYourself is waiting. Notice a BoundaryEvent Timeout has been started since it's attached to the UserTask.

Execution is continued after the work is complete by `invoking` the step.

```ruby
execution.step_by_id('IntroduceYourself').invoke({ name: "Eric", language: "es", formal: true })
```

After `invoking` the task the process continues executing until it reaches an EndEvent.

```
HelloWorld ended * 

{
  "greet": true,
  "cookie": true,
  "message": "👋 Hola Eric 🥠 Avoid taking unnecessary gambles. Lucky numbers: 12, 15, 23, 28, 37",
}

0 StartEvent Start: ended * out: Flow_016qg9x
1 UserTask IntroduceYourself: ended * in: Flow_016qg9x * out: Flow_0f1v8du
2 BoundaryEvent Timeout: terminated * in: 
3 InclusiveGateway Split: ended * in: Flow_0f1v8du * out: Flow_00mppvp
4 BusinessRuleTask ChooseGreeting: ended * in: Flow_00mppvp * out: Flow_1ezhtuc
5 InclusiveGateway Join: ended * in: Flow_1ezhtuc * out: Flow_1xiabfq
6 ScriptTask SayHello: ended {"message"=>"Hola Eric"} * in: Flow_1xiabfq * out: Flow_15lbcry
7 EndEvent End: ended * in: Flow_15lbcry
```
## Documentation

* [Processes](/docs/processes.md)
* [Tasks](/docs/tasks.md)
* [Events](/docs/events.md)
* [Event Definitions](/docs/event_definitions.md)
* [Gateways](/docs/gateways)
* [Expressions](/docs/expressions)
* [Runtime](/docs/runtime)
## Installation
Add this line to your application's Gemfile:

```ruby
gem 'processable'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install processable
```
## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Developed by [Connected Bits](http://www.connectedbits.com)