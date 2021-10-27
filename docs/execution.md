# Execution


## Async Automated (Service, Script, and BusinessRule) Tasks

The Processable runtime will run automated tasks synchronously when the step is executed. This behavior can be bypassed causing the automated task to go directly to `waiting`. Note: the runtime will expect the task to be run manually and invoked with the result when complete.

```ruby
# This flag will make all services asynchronous
runtime.config.async_services = true

# Start the process
process_instance = runtime.start_process('SomeProcess')

# The process will wait at the service task
service_task = process_instance.step_by_id('MyServiceTask')

# Run the service task manually
result = service_task.element.run(service_task.execution)

# Now we invoke the step with the result to continue processing
service_task.invoke(result)
```
