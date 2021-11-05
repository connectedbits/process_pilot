# frozen_string_literal: true

module Bpmn
  class Event < Step
    attr_accessor :event_definitions, :event_definition_ids

    def initialize(moddle)
      super
      @event_definitions = []
      @event_definition_ids = []
      @event_definition_ids = moddle["eventDefinitions"].map do |edm|
        edm["id"]
      end if moddle["eventDefinitions"]
    end

    def is_catching?
      false
    end

    def is_throwing?
      false
    end

    def is_none?
      event_definitions.empty?
    end

    def is_conditional?
      conditional_event_definition.present?
    end

    def is_escalation?
      escalation_event_definition.present?
    end

    def is_error?
      error_event_definition.present?
    end

    def is_message?
      !message_event_definitions.empty?
    end

    def is_signal?
      !signal_event_definitions.empty?
    end

    def is_terminate?
      terminate_event_definition.present?
    end

    def is_timer?
      timer_event_definition.present?
    end

    def conditional_event_definition
      event_definitions.find { |ed| ed.is_a?(Bpmn::ConditionalEventDefinition) }
    end

    def escalation_event_definition
      event_definitions.find { |ed| ed.is_a?(Bpmn::EscalationEventDefinition) }
    end

    def error_event_definition
      event_definitions.find { |ed| ed.is_a?(Bpmn::ErrorEventDefinition) }
    end

    def message_event_definitions
      event_definitions.select { |ed| ed.is_a?(Bpmn::MessageEventDefinition) }
    end

    def signal_event_definitions
      event_definitions.select { |ed| ed.is_a?(Bpmn::SignalEventDefinition) }
    end

    def terminate_event_definition
      event_definitions.find { |ed| ed.is_a?(Bpmn::TerminateEventDefinition) }
    end

    def timer_event_definition
      event_definitions.find { |ed| ed.is_a?(Bpmn::TimerEventDefinition) }
    end

    def execute(step_execution)
      super
      event_definitions.each { |ed| ed.execute(self, step_execution) }
    end
  end

  class StartEvent < Event

    def is_catching?
      true
    end

    # def execute(step_execution)
    #   super
    #   step_execution.continue
    # end

    def execute(execution)
      leave(execution)
    end
  end

  class IntermediateThrowEvent < Event

    def is_throwing?
      true
    end

    # def execute(step_execution)
    #   super
    #   step_execution.continue
    # end
  end

  class IntermediateCatchEvent < Event

    def is_catching?
      true
    end

    # def execute(step_execution)
    #   super
    #   step_execution.wait
    # end
  end

  class BoundaryEvent < Event
    attr_accessor :attached_to_ref, :attached_to, :cancel_activity

    def initialize(moddle)
      super
      @attached_to_ref = moddle[:attachedToRef]
      @cancel_activity = true
      @cancel_activity = moddle["cancelActivity"] if moddle["cancelActivity"] != nil
    end

    def is_catching?
      true
    end

    # def execute(step_execution)
    #   super
    #   step_execution.wait
    # end
  end

  class EndEvent < Event

    def is_throwing?
      true
    end

    # def execute(step_execution)
    #   super
    #   step_execution.end
    # end

    def execute(execution)
      execution.end(true)
    end
  end
end
