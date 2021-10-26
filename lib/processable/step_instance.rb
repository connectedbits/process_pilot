module Processable
  class StepInstance
    include ActiveModel::Model
    
    attr_reader :process_instance, :element, :variables, :tokens_in, :tokens_out, :status

    def initialize(process_instance, element:, token: nil)
      @process_instance = process_instance
      @element = element
      @tokens_in = token ? [token] : []
      @tokens_out = []
      @variables = {}
      @status = 'created'
    end

    def start
      update_status('started')
    end

    def wait
      update_status('waiting')
    end

    def invoke(variables: {})
      @variables = variables
      continue
    end

    def terminate
      update_status('terminated')
    end

    def continue
      self.end
    end

    def end
      @tokens_out = element.outgoing_flows(self).map { |flow| flow.id }
      update_status('ended')
    end

    private

    def update_status(status)
      @status = status
      event = "step_instance_#{status}".to_sym
      #ap event
      #Config.instance.listeners.each { |l| l[event].call(self) if l[event] }
      process_instance.send(event, self) if process_instance.respond_to?(event)
    end
  end
end