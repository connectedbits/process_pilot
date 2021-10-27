module Bpmn
  class EventDefinition < Element
  end
  
  class ConditionalEventDefinition < Element
  end

  class EscalationEventDefinition < Element
  end

  class ErrorEventDefinition < Element
  end

  class MessageEventDefinition < Element
    attr_accessor :message_ref, :message

    def initialize(moddle)
      super
      @message_ref = moddle[:messageRef]
    end
  end

  class SignalEventDefinition < Element
    attr_accessor :signal_ref, :signal

    def initialize(moddle)
      super
      @signal_ref = moddle[:signalRef]
    end
  end

  class TerminateEventDefinition < Element
  end

  class TimerEventDefinition < Element
  end
end