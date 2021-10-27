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
  end
end