module Bpmn
  class Task < Activity
    attr_accessor :result_variable

    def initialize(moddle)
      super
      @result_variable = moddle["resultVariable"]
    end

    def execute(step_execution)
      super
      step_execution.wait
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

    def execute(step_execution)
      super
      step_execution.wait
    end
  end

  class ServiceTask < Task
    attr_accessor :topic

    def initialize(moddle)
      super
      @topic = moddle["topic"]
    end

    def execute(step_execution)
      if step_execution.async_services?
        step_execution.wait 
      else
        run(step_execution)
      end
    end

    def run(step_execution)
      result = step_execution.call_service(topic)
      step_execution.invoke(result_to_variables(result))
    end
  end

  class ScriptTask < Task
    attr_accessor :script

    def initialize(moddle)
      super
      @script = moddle["script"]
    end

    def execute(step_execution)
      super
      run(step_execution)
    end

    def run(step_execution)
      result = step_execution.run_script(script)
      step_execution.invoke(result_to_variables(result))
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

    def execute(step_execution)
      super
      run(step_execution)
    end

    def run(step_execution)
      if expression
        result = step_execution.evaluate_expression(expression)
        step_execution.invoke(result_to_variables(result))
      elsif decision_ref
        result = step_execution.evaluate_decision(decision_ref)
        step_execution.invoke(result_to_variables(result))
      end
    end
  end
end