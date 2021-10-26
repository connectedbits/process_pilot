module Bpmn
  class Activity < Step
  end

  class Task < Activity

    def execute(instance)
      instance.wait
    end
  end

  class BusinessRuleTask < Task
  end

  class ScriptTask < Task
  end

  class ServiceTask < Task
  end

  class UserTask < Task
  end
end