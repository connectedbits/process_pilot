module Bpmn
  class EventDefinition < Element

    def execute(host_element, execution)
    end
  end
  
  class ConditionalEventDefinition < EventDefinition
    attr_accessor :variable_name, :variable_events, :condition

    def initialize(moddle)
      super
      @variable_name = moddle["variableName"] # "var1"
      @variable_events = moddle["variableEvents"] # "create, update"
      @condition = Bpmn::Expression.new(moddle["condition"]) if moddle["condition"] # ${var1 == 1}
    end
  end

  class EscalationEventDefinition < EventDefinition
  end

  class ErrorEventDefinition < EventDefinition
    attr_accessor :error_code_variable, :error_message_variable

    def initialize(moddle)
      super
      @error_code_variable = moddle[:errorCodeVariable]
      @error_message_variable = moddle[:errorMessageVariable]
    end
  end

  class MessageEventDefinition < EventDefinition
    attr_accessor :message_ref, :message

    def initialize(moddle)
      super
      @message_ref = moddle[:messageRef]
    end

    def execute(host_element, execution)
      if host_element.is_catching?
        execution.catch_message(message_name)
      elsif host_element.is_throwing?
        execution.throw_message(message_name)
      end
    end

    def message_id
      message&.id
    end

    def message_name
      message&.name
    end
  end

  class SignalEventDefinition < EventDefinition
    attr_accessor :signal_ref, :signal

    def initialize(moddle)
      super
      @signal_ref = moddle[:signalRef]
    end

    def signal_id
      signal&.id
    end

    def signal_name
      signal&.name
    end
  end

  class TerminateEventDefinition < EventDefinition

    def execute(host_element, execution)
      return unless host_element.is_a?(Bpmn:EndEvent)
      execution.terminate
    end
  end

  class TimerEventDefinition < EventDefinition
    attr_accessor :time_date, :time_duration_type, :time_duration, :time_cycle

    def initialize(moddle)
      super
      if moddle['timeDuration']
        @time_duration_type = moddle['timeDuration']['$type']
        @time_duration = moddle['timeDuration']['body']
      end
    end

    def execute(host_element, execution)
      execution.set_timer(time_due)
    end

    private

    def time_due
      # Return the next time the timer is due
      if time_date
        return Date.parse(time_date)
      elsif time_duration
        return Time.now + ActiveSupport::Duration.parse(time_duration)
      else
        return Time.now # time_cycle not yet implemented
      end
    end
  end
end