module Bpmn
  class Step < Element
    attr_accessor :incoming, :outgoing, :default

    def initialize(moddle)
      super
      @incoming = []
      @outgoing = []
      @default = moddle["default"]
    end

    def execute(execution)
    end

    def diverging?
      outgoing.length > 1
    end

    def converging?
      incoming.length > 1
    end

    def outgoing_flows(execution)
      flows = []
      outgoing.each { |flow| flows.push flow if flow.evaluate(execution) }
      return flows
    end

    def outgoing_flows(execution)
      flows = []
      outgoing.each do |flow|
        result = flow.evaluate(execution) unless default&.id == flow.id
        flows.push flow if result
      end
      flows = [default] if flows.empty? && default
      return flows
    end
  end
end