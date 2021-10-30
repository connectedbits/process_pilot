# Execution

## Context

### Sources

### Services

### Listeners

### Async Services

The Execution will run service tasks synchronously when the step is executed. This behavior can be bypassed causing the automated task to go directly to `waiting`. Note: the execution engine will expect the task to be run manually and invoked with the result when complete.

```ruby
# Initialize the context to `wait` on service tasks, this will require the service task to be manually `invoked` when the work is complete.
context = Processable::Context.new(async_services: true)
```

## Process Execution

## Step Execution

