# frozen_string_literal: true

module ProcessPilot
  class TaskRunner
    attr_reader :execution, :context

    def self.call(*args, &block)
      new(*args, &block).call
    end

    def initialize(execution, context)
      super()
      @execution = execution
      @context = context
    end

    def call
    end

    def variables
      execution.parent.variables.with_indifferent_access
    end
  end

  class ServiceTaskRunner < TaskRunner

    def call
      service_key = execution.step.service_key
      raise ExecutionError.new("A service key is required for a Service Task") unless service_key
      service = context.services[service_key.to_sym]
      if service.present?
        result = service.call(execution, variables)
        execution.signal(result)
      end
    end
  end

  class ScriptTaskRunner < ServiceTaskRunner

    def call
      script = execution.step.script
      raise ExecutionError.new("A script is required for a Script Task") unless script
      result = ProcessPilot::Services::ExpressionEvaluator.call(expression: script, variables: variables)
      execution.signal(result)
    end
  end

  class BusinessRuleTaskRunner < TaskRunner

    def call
      decision_id = execution.step.decision_id
      raise ExecutionError.new("A decision id is required for a Business Rule Task") unless decision_id

      puts "Calling #{decision_id} with #{variables}}"

      result = Evaluation.new(context).evaluate(decision_id, with: variables)
      execution.signal(result)
    end
  end
end
