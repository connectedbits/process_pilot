# frozen_string_literal: true

module Processable
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
      topic = execution.step.topic if execution.step.respond_to?(:topic)
      raise ExecutionError.new("Topic required for service task") unless topic
      service = context.services[topic.to_sym]
      raise ExecutionError.new("No service found for topic #{topic}") unless service
      service.call(execution, variables)
    end
  end

  class ScriptTaskRunner < TaskRunner

    def call
      script = execution.step.script if execution.step.respond_to?(:script)
      raise ExecutionError.new("Script required for script task") unless script
      ProcessableServices::ScriptRunner.call(script: script, variables: variables, procs: procs)
    end

    private

    def procs
      {
        signal: proc { |variables| execution.signal(variables) },
        error: proc { |code, message = nil| },
      }
    end
  end

  class BusinessRuleTaskRunner < TaskRunner

    def call
      expression = execution.step.expression
      decision_ref = execution.step.decision_ref

      if expression
        result = ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: variables)
        execution.signal(result)
      elsif decision_ref
        source = context.decisions[decision_ref]
        raise ExecutionError.new("Source not found for decision ref #{decision_ref}") unless source
        result = ProcessableServices::DecisionEvaluator.call(decision_ref, source, variables)
        execution.signal(result)
      end
    end
  end
end
