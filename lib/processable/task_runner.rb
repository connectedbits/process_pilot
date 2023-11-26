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
      service_ref = execution.step.service_ref
      raise ExecutionError.new("A service ref required for Service Task") unless service_ref
      service = context.services[service_ref.to_sym]
      raise ExecutionError.new("No service found with service reference #{service_ref}") unless service

      begin
        result = service.call(execution, variables)
      rescue => error
        #execution.step.throw_error(error.message, variables: {})
      else
        execution.signal(result)
      end
    end
  end

  class ScriptTaskRunner < ServiceTaskRunner

    def call
      expression = execution.step.expression
      raise ExecutionError.new("An expression is required for a Script Task") unless expression

      begin
        result = ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: variables)
      rescue error
        #execution.step.throw_error(error.name, variables: {})
      else
        execution.signal(result)
      end
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
      decision_ref = execution.step.decision_ref
      raise ExecutionError.new("A decision ref is required for a Business Rule Task") unless decision_ref

      source = context.decisions[decision_ref]
      raise ExecutionError.new("Source not found for decision ref #{decision_ref}") unless source

      begin
        result = ProcessableServices::DecisionEvaluator.call(decision_ref, source, variables)
      rescue error
        #execution.step.throw_error(error.name, variables: {})
      else
        execution.signal(result)
      end
    end
  end
end
