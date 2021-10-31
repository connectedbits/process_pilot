# Execution

## Context

### Sources

### Services

### Listeners

### External Services

By default, Processable will run service tasks locally when the step is executed. This behavior can be bypassed causing the automated task to go directly to `waiting`. Note: the execution engine will expect the task to be run externally and invoked with the result when complete.

```ruby
# Initialize the context to `wait` on service tasks, this will require the service task to be manually `invoked` when the work is complete.
context = Processable::Context.new(external_services: true)
```

