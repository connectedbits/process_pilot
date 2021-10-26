module Bpmn
  class Activity < Step
  end

  class Task < Activity
    attr_accessor :result_variable

    def initialize(moddle)
      super
      @result_variable = moddle["resultVariable"]
    end

    def execute(execution)
      execution.wait
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

  class BusinessRuleTask < Task
    attr_accessor :expression, :decision_ref, :binding, :version

    def initialize(moddle)
      super
      @expression = moddle["expression"]
      @decision_ref = moddle["decisionRef"]
      @binding = moddle["binding"]
      @version = moddle["version"]
    end

    def execute(execution)
      if expression
        result = execution.evaluate_expression(expression)
        execution.invoke(result_to_variables(result))
      elsif decision_ref
        result = execution.evaluate_decision(decision_ref)
        execution.invoke(result_to_variables(result))
      end
    end
  end

  class ScriptTask < Task
    attr_accessor :script

    def initialize(moddle)
      super
      @script = moddle["script"]
    end

    def execute(execution)
      result = execution.run_script(script)
      execution.invoke(result_to_variables(result))
    end
  end

  class ServiceTask < Task
    attr_accessor :topic

    def initialize(moddle)
      super
      @topic = moddle["topic"]
    end

    def execute(execution)
      result = execution.call_service(topic)
      execution.invoke(result_to_variables(result))
    end
  end

  class UserTask < Task
  end
end