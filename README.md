# Processable
Processable is a BPMN/DMN workflow gem for Rails apps.

## Usage
Processable executes BPMN documents created in the Processable Modeler. Once a process is defined in a BPMN document it can be started using the runtime.

```ruby
process_instance = Processable::Runtime.new(sources: File.read('simple.bpmn')).start_process('SimpleProcess')
process_instance.print
```

The current status of a process instance can be printed.

```bash
SimpleProcess started * Flow_1qhq8g6

0 StartEvent Start: ended * out: Flow_1qhq8g6
1 Task MyTask: waiting * in: Flow_1qhq8g6
```

The Task `MyTask` is `waiting` to be `invoked` after the work has been completed. 

```ruby
process_instance.step_by_id('MyTask').invoke
```

After `invoking` the task the process continues until it reaches the EndEvent.

```bash
SimpleProcess ended * 

0 StartEvent Start: ended * out: Flow_1qhq8g6
1 Task MyTask: ended * in: Flow_1qhq8g6 * out: Flow_1rnbtwj
2 EndEvent End: ended * in: Flow_1rnbtwj
```

## Documentation
The Processable engine supports the following [BPMN Elements](/docs/elements.md)

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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
