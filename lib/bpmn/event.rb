module Bpmn
  class Event < Step
    attr_accessor :event_definitions

    def initialize(moddle)
      super
      @event_definitions = []
      @event_definitions = moddle['eventDefinitions'].map do |edm|
        Element.from_moddle(edm)
      end if moddle['eventDefinitions']
    end

    def is_catching?
      false
    end

    def is_throwing?
      false
    end

    def execute(execution)
      event_definitions.each { |ed| ed.execute(self, execution) }
    end
  end

  class StartEvent < Event

    def is_catching?
      true
    end

    def execute(execution)
      super
      execution.continue
    end
  end

  class IntermediateThrowEvent < Event
  
    def is_throwing?
      true
    end

    def execute(execution)
      super
      execution.continue
    end
  end

  class IntermediateCatchEvent < Event

    def is_catching?
      true
    end

    def execute(execution)
      super
      execution.wait
    end
  end

  class BoundaryEvent < Event
    attr_accessor :attached_to_ref, :attached_to, :cancel_activity

    def is_catching?
      true
    end

    def initialize(moddle)
      super
      @attached_to_ref = moddle[:attachedToRef]
      @cancel_activity = true
      @cancel_activity = moddle["cancelActivity"] if moddle["cancelActivity"] != nil
    end
    
    def execute(execution)
      super
      execution.wait
    end
  end

  class EndEvent < Event

    def is_throwing?
      true
    end
    
    def execute(execution)
      super
      execution.end
    end
  end
end