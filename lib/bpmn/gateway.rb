module Bpmn
  class Gateway < Step
    attr_accessor :default

    def initialize(moddle)
      super
      @default = moddle["default"]
    end

    def execute(execution)
      if converging?
        return execution.continue if is_enabled?(execution)
        return execution.wait
      else
        return execution.continue
      end
    end

    #
    # Algorithm from https://researcher.watson.ibm.com/researcher/files/zurich-hvo/bpm2010-1.pdf
    #
    def is_enabled?(instance)
      filled = []
      empty = []

      incoming.each { |flow| instance.tokens_in.include?(flow.id) ? filled.push(flow) : empty.push(flow) }

      # Filled slots don't need to be searched for tokens
      index = 0
      while (index < filled.length)
        current_flow = filled[index]
        current_flow.source.incoming.each do |incoming_flow|
          filled.push(incoming_flow) unless filled.include?(incoming_flow) || incoming_flow.target == self
        end
        index = index + 1
      end

      # Empty slots need to be searched for tokens
      index = 0
      while (index < empty.length)
        current_flow = empty[index]
        current_flow.source.incoming.each do |incoming_flow|
          empty.push(incoming_flow) unless filled.include?(incoming_flow) || empty.include?(incoming_flow) || incoming_flow.target == self
        end
        index = index + 1
      end

      empty_ids = empty.map { |g| g.id }

      # If there are empty slots with tokens we need to wait
      return false if (empty_ids & instance.process_instance.tokens).length > 0
      return true
    end
  end

  class ExclusiveGateway < Gateway

    # RULE: Only one flow is taken
    def outgoing_flows(instance)
      flows = super
      return [default] if flows.empty? && default
      return [flows.first]
    end
  end

  class ParallelGateway < Gateway
    
    # RULE: All flows are taken, conditions are ignored.
  end

  class InclusiveGateway < Gateway
    
    # RULE: The default flow will only fire if no other flows are valid.
    def outgoing_flows(instance)
      flows = super
      return [default] if flows.empty? && default
      return flows
    end
  end

  class EventBasedGateway < Gateway

    # RULE: All flows are taken

    #
    # RULE: when an event created from an event gateway is caught,
    # all other waiting events must be canceled.
    #
    def cancel_waiting_events(instance)
      instance.targets.each do |target_instance|
        target_instance.cancel if target_instance.status == :waiting
      end
    end
  end
end