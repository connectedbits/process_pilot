module Processable
  class StepInstance
    include ActiveModel::Model
    
    attr_accessor :process_instance, :element, :variables, :tokens_in, :tokens_out, :id, :status, :attached_to, :attachments, :expires_at, :message_names

    delegate :invoke, to: :execution

    def initialize(process_instance, element:, token: nil, attached_to: nil)
      @id = SecureRandom.uuid
      @process_instance = process_instance
      @element = element
      @tokens_in = token ? [token] : []
      @tokens_out = []
      @variables = {}
      @attached_to = attached_to
      @attachments = []
      @expires_at = nil
      @message_names = []
      @status = 'created'
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

    def execution
      @execution ||= StepExecution.new(self)
    end

    def process_execution
      @process_execution ||= ProcessExecution.new(process_instance)
    end

    def sources
      process_instance.steps.select { |si| (si.tokens_out & tokens_in).length > 0 }
    end

    def targets
      process_instance.steps.select { |si| (si.tokens_in & tokens_out).length > 0 }
    end
  end
end