module Bpmn
  class Event < Step
    attr_accessor :event_definitions

    def initialize(moddle)
      super
      @event_definitions = moddle['eventDefinitions'] ? moddle['eventDefinitions'] : []
    end

    def conditional_event_definition
      event_definitions.find {|ed| ed.is_a?(ConditionalEventDefinition) }
    end

    def escalation_event_definition
      event_definitions.find {|ed| ed.is_a?(EscalationEventDefinition) }
    end

    def error_event_definition
      event_definitions.find {|ed| ed.is_a?(ErrorEventDefinition) }
    end

    def message_event_definitions
      event_definitions.select {|ed| ed.is_a?(MessageEventDefinition) }
    end

    def signal_event_definitions
      event_definitions.select {|ed| ed.is_a?(SignalEventDefinition) }
    end

    def terminate_event_definition
      event_definitions.find {|ed| ed.is_a?(TerminateEventDefinition) }
    end

    def timer_event_definition
      event_definitions.find {|ed| ed.is_a?(TimerEventDefinition) }
    end

    def is_catching?
      false
    end

    def is_throwing?
      false
    end
  end

  class StartEvent < Event

    def is_catching?
      message_event_definitions.present? || signal_event_definitions.present?
    end

    def execute(execution)
      execution.continue
    end
  end

  class IntermediateThrowEvent < Event
  
    def is_throwing?
      message_event_definitions.present? || signal_event_definitions.present?
    end

    def execute(execution)
      # TODO: throw event
      execution.continue
    end
  end

  class IntermediateCatchEvent < Event

    def is_catching?
      message_event_definitions.present? || signal_event_definitions.present?
    end

    def execute(execution)
      # TODO: subscribe to event
      execution.wait
    end
  end

  class BoundaryEvent < Event
    attr_accessor :attached_to_ref, :attached_to, :cancel_activity

    def is_catching?
      message_event_definitions.present?
    end

    def initialize(moddle)
      super
      @attached_to_ref = moddle[:attachedToRef]
      @cancel_activity = true
      @cancel_activity = moddle["cancelActivity"] if moddle["cancelActivity"] != nil
    end
    
    def execute(execution)
      execution.wait
    end
  end

  class EndEvent < Event

    def is_throwing?
      message_event_definitions.present? || signal_event_definitions.present?
    end
    
    def execute(instance)
      instance.end
    end
  end
end