# frozen_string_literal: true

module Bpmn
  class Task < Activity
    attr_accessor :result_variable, :service_ref, :script

    def initialize(moddle)
      super
      @result_variable = moddle["resultVariable"]
    end

    def is_automated?
      false
    end

    def is_manual?
      true
    end

    def execute(execution)
      execution.wait
    end

    def signal(execution)
      leave(execution)
    end

    def result_to_variables(result)
      if result_variable
        return { "#{result_variable}": result }
      else
        if result.is_a? Hash
          result
        else
          {}.tap { |h| h[id.underscore] = result }
        end
      end
    end
  end

  class UserTask < Task
  end

  class ServiceTask < Task
    attr_accessor :service_ref

    def initialize(moddle)
      super
      extension_by_type("zeebe:TaskDefinition")&.tap do |extension|
        @service_ref = extension.moddle["type"]
        @result_variable = extension.moddle["resultVariable"] if extension.moddle["resultVariable"].present?
      end
    end

    def is_automated?
      true
    end

    def is_manual?
      false
    end

    def execute(execution)
      execution.wait
    end
  end

  class ScriptTask < ServiceTask
    attr_accessor :expression # Scripts are FEEL expressions

    def initialize(moddle)
      super
      extension_by_type("zeebe:Script")&.tap do |extension|
        @expression = extension.moddle["expression"]
        @result_variable = extension.moddle["resultVariable"] if extension.moddle["resultVariable"].present?
      end
    end
  end

  class BusinessRuleTask < ServiceTask
    attr_accessor :decision_ref # Name of a DMN table

    def initialize(moddle)
      super
      extension_by_type("zeebe:CalledDecision")&.tap do |extension|
        @decision_ref = extension.moddle["decisionId"]
        @result_variable = extension.moddle["resultVariable"] if extension.moddle["resultVariable"].present?
      end
    end
  end
end
