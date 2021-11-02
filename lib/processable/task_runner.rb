# frozen_string_literal: true

module Processable
  class TaskRunner
    attr_reader :step, :context

    def self.call(*args, &block)
      new(*args, &block).call
    end

    def initialize(step, context)
      super()
      @step = step
      @context = context
    end

    def call
    end

    def variables
      step.execution.variables
    end
  end

  class ServiceTaskRunner < TaskRunner

    def call
      topic = step.element.topic if step.element.respond_to?(:topic)
      raise ExecutionError.new("Topic required for service task") unless topic
      service = context.services[topic.to_sym]
      raise ExecutionError.new("No service found for topic #{topic}") unless service
      service.call(step, variables)
    end
  end

  class ScriptTaskRunner < TaskRunner

    def call
      script = step.element.script if step.element.respond_to?(:script)
      raise ExecutionError.new("Script required for script task") unless script
      ProcessableServices::ScriptRunner.call(script: script, variables: step.execution.variables, procs: procs)
    end

    private

    def procs
      {
        complete: proc { |variables| step.complete(variables) },
        error: proc { |code, message = nil| },
      }
    end
  end

  class BusinessRuleTaskRunner < TaskRunner

    def call
      expression = step.element.expression
      decision_ref = step.element.decision_ref

      if expression
        result = ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: step.execution.variables)
        step.complete(result)
      elsif decision_ref
        source = context.decisions[decision_ref]
        raise ExecutionError.new("Source not found for decision ref #{decision_ref}") unless source
        result = ProcessableServices::DecisionEvaluator.call(decision_ref, source, step.execution.variables)
        step.complete(result)
      end
    end
  end
end
