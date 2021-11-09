# frozen_string_literal: true

module Bpmn
  class Task < Activity
    attr_accessor :result_variable

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
    attr_accessor :topic

    def initialize(moddle)
      super
      @topic = moddle["topic"]
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
    attr_accessor :script

    def initialize(moddle)
      super
      @script = moddle["script"]
    end
  end

  class BusinessRuleTask < ServiceTask
    attr_accessor :expression, :decision_ref, :binding, :version

    def initialize(moddle)
      super
      @expression = moddle["expression"]
      @decision_ref = moddle["decisionRef"]
      @binding = moddle["binding"]
      @version = moddle["version"]
    end
  end
end
