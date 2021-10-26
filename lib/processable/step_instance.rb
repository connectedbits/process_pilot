module Processable
  class StepInstance
    include ActiveModel::Model
    
    attr_accessor :process_instance, :element, :variables, :tokens_in, :tokens_out, :status

    delegate :invoke, to: :execution

    def initialize(process_instance, element:, token: nil)
      @process_instance = process_instance
      @element = element
      @tokens_in = token ? [token] : []
      @tokens_out = []
      @variables = {}
      @status = 'created'
    end

    def execution
      @execution ||= StepExecution.new(self)
    end

    def process_execution
      @process_execution ||= ProcessExecution.new(process_instance)
    end
  end
end