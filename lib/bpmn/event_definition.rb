module Bpmn
  class EventDefinition < Element

  end
  
  class MessageEventDefinition < Element
    attr_accessor :message_ref, :message

    def initialize(moddle)
      super
      @message_ref = moddle[:messageRef]
    end
  end
end