# frozen_string_literal: true

module Bpmn
  class Step < Element
    attr_accessor :incoming, :outgoing, :default

    def initialize(moddle)
      super
      @incoming = []
      @outgoing = []
      @default = moddle["default"]
    end

    def execute(step_execution)
      step_execution.start
    end

    def diverging?
      outgoing.length > 1
    end

    def converging?
      incoming.length > 1
    end

    def outgoing_flows(step_execution)
      flows = []
      outgoing.each do |flow|
        result = flow.evaluate(step_execution) unless default&.id == flow.id
        flows.push flow if result
      end
      flows = [default] if flows.empty? && default
      return flows
    end
  end
end
