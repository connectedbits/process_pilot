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

    def diverging?
      outgoing.length > 1
    end

    def converging?
      incoming.length > 1
    end

    def leave(execution)
      execution.end(false)
      execution.take_all(outgoing_flows(execution))
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

  class Activity < Step
    attr_accessor :attachments

    def initialize(moddle)
      super
      @attachments = []
    end
  end
end
