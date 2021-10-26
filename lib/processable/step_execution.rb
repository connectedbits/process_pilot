module Processable
  class StepExecution
    attr_reader :step_instance

    def initialize(step_instance)
      @step_instance = step_instance
    end

    def start
      update_status('started')
    end

    def wait
      update_status('waiting')
    end

    def invoke(variables = {})
      step_instance.variables = variables
      continue
    end

    def terminate
      update_status('terminated')
    end

    def continue
      self.end
    end

    def end
      step_instance.tokens_out = step_instance.element.outgoing_flows(step_instance).map { |flow| flow.id }
      update_status('ended')
    end

    private

    def update_status(status)
      step_instance.status = status
      event = "step_instance_#{status}".to_sym
      config.notify_listeners(event, step_instance)
      step_instance.process_execution.send(event, step_instance) if step_instance.process_execution.respond_to?(event)
    end

    def config
      Config.instance
    end
  end
end