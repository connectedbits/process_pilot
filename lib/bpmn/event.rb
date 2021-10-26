module Bpmn
  class Event < Step
    attr_accessor :event_definitions

    def initialize(moddle)
      super
      @event_definitions = moddle['eventDefinitions'] ? moddle['eventDefinitions'] : []
    end
  end

  class StartEvent < Event

    def execute(execution)
      execution.continue
    end
  end

  class IntermediateThrowEvent < Event
  
    def execute(execution)
      # TODO: throw event
      execution.continue
    end
  end

  class IntermediateCatchEvent < Event

    def execute(execution)
      # TODO: subscribe to event
      execution.wait
    end
  end

  class BoundaryEvent < Event

    def execute(execution)
      execution.wait
    end
  end

  class EndEvent < Event

    def execute(instance)
      instance.end
    end
  end
end