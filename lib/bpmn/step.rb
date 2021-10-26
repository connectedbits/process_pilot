module Bpmn
  class Step < Element
    attr_accessor :incoming, :outgoing

    def initialize(moddle)
      super
      @incoming = []
      @outgoing = []
    end

    def execute(instance)
    end

    def outgoing_flows(instance)
      flows = []
      outgoing.each { |flow| flows.push flow if flow.evaluate(instance) }
      return flows
    end
  end
end