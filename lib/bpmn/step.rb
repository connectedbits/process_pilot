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

    # #
    # # The primary execution method for a step.
    # #
    # def execute(step_execution)
    #   # Step 1 Start
    #   step_execution.started_at = Time.zone.now
    #   step_execution.status = "started"

    #   result = start(step_execution)

    #   # Return if waiting
    #   return result if result == :wait

    #   # Step 2 Run: perform the work (user task bypasses this step)
    #   result = run(step_execution)
    #   return result if result == :cancel

    #   # Step 3 Continue: will fire end
    #   continue(step_execution)
    # end

    # def start(step_execution)
    #   return :wait if requires_wait?
    #   :continue
    # end

    # def run(step_execution)
    #   :end
    # end

    # def continue(step_execution)
    #   self.end(step_execution)
    # end

    # def end(step_execution)
    #   :end
    # end

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

  class Activity < Step
    attr_accessor :attachments

    def initialize(moddle)
      super
      @attachments = []
    end
  end
end
