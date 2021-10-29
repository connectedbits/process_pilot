module Processable
  class StepExecution
    attr_reader :id, :status, :execution, :element, :tokens_in, :tokens_out, :variables, :attached_to, :attachments, :message_names, :expires_at

    delegate :evaluate_condition, :evaluate_expression, :evaluate_decision, :run_script, :call_service, :async_services?, to: :execution

    def initialize(execution:, element:, token: nil, attached_to: nil)
      @id = SecureRandom.uuid
      @status = 'created'
      @execution = execution
      @element = element
      @tokens_in = token ? [token] : []
      @tokens_out = []
      @variables = {}
      @attached_to = attached_to
      @attachments = []
      @message_names = []
      @expires_at = nil
    end

    def start
      update_status('started')
    end

    def wait
      update_status('waiting')
    end

    def invoke(variables = {})
      @variables = variables.merge(variables).with_indifferent_access
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

    def set_timer(expires_at)
      @expires_at = expires_at
    end

    def catch_message(message_name)
      message_names.push message_name
    end

    def throw_message(message_name)
      execution.message_received(message_name)
    end

    def started?
      status == 'started'
    end

    def waiting?
      status == 'waiting'
    end

    def ended?
      status == 'ended'
    end

    def terminated?
      status == 'terminated'
    end

    def sources
      execution.steps.select { |step| (step.tokens_out & tokens_in).length > 0 }
    end

    def targets
      execution.steps.select { |step| (step.tokens_in & tokens_out).length > 0 }
    end

        #
    # Serialization
    #

    def to_json
      StepInstance.new(
        id: id,
        process_id: process.id,
        status: status, 
        started_at: started_at, 
        ended_at: ended_at, 
        variables: variables, 
        tokens_in: tokens_in, 
        tokens_out: tokens_out,
        message_names: message_names,
        expires_at: expires_at,
        attached_to_id: attached_to&.id,
        attachment_ids: attachments.map { |attachment| attachment.id }
      )
    end

    private

    def update_status(status)
      @status = status
      event = "step_#{status}".to_sym
      execution.send(event, self) if execution.respond_to?(event)
    end
  end

  class StepInstance
    include ActiveModel::Serializers::JSON
  
    attr_accessor :id, :element_id, :status, :started_at, :ended_at, :variables, :tokens_in, :tokens_out, :message_names, :expires_at, :attached_to_id, :attachment_ids

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end
   
    def attributes
      {
        'id' => nil,
        'element_id' => nil,
        'status' => nil,
        'started_at' => nil,
        'ended_at' => nil,
        'variables' => nil,
        'tokens_in' => nil,
        'tokens_out' => nil,
        'message_names' => nil,
        'expires_at' => nil,
        'attached_to_id' => nil,
        'attachment_ids' => nil,
      }
    end
  end
end