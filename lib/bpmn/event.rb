module Bpmn
  class Event < Step
    attr_accessor :event_definitions

    def initialize(moddle)
      super
      @event_definitions = moddle['eventDefinitions'] ? moddle['eventDefinitions'] : []
    end
  end

  class StartEvent < Event

    def execute(instance)
      instance.continue
    end
  end

  class IntermediateThrowEvent < Event
  
    def execute(instance)
      # TODO: throw event
      instance.continue
    end
  end

  class IntermediateCatchEvent < Event

    def execute(instance)
      # TODO: subscribe to event
      instance.wait
    end
  end

  class BoundaryEvent < Event

    def execute(instance)
      instance.wait
    end
  end

  class EndEvent < Event

    def execute(instance)
      instance.end
    end
  end
end