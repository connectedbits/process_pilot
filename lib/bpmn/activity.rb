module Bpmn
  class Activity < Step
    attr_accessor :attachments

    def initialize(moddle)
      super
      @attachments = []
    end
  end

  class CallActivity < Activity
  end

  class SubProcess < Activity
    attr_accessor :definitions, :elements, :parent
    attr_accessor :is_executable, :triggered_by_event

    def initialize(moddle)
      super
      @is_executable = false
      @triggered_by_event = moddle["triggeredByEvent"]
    end
  end
end