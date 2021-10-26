module Processable
  class ProcessInstance
    include ActiveModel::Model
    
    attr_accessor :process, :start_event, :variables, :key, :parent, :called_by, :status, :steps

    delegate :element_by_id, to: :process

    def initialize(process, start_event:, variables: {}, key: nil, parent: nil, called_by: nil)
      @process = process
      @start_event = start_event
      @variables = {}
      @key = key
      @parent = parent
      @called_by = called_by
      @steps = []
      @status = 'created'
    end

    def tokens
      active_tokens = []
      steps.each do |step|
        active_tokens += step.tokens_out
        active_tokens -= step.tokens_in if step.status == 'ended'
      end   
      active_tokens.uniq
    end

    def step_by_id(id)
      steps.find { |si| si.element.id == id }
    end

    def print
      puts
      puts "#{process.id} #{status} * #{tokens.join(', ')}"
      print_variables unless variables.empty?
      print_steps
      puts
    end

    def print_steps
      puts
      steps.each_with_index do |step, index|
        str = "#{index} #{step.element.type.split(':').last} #{step.element.id}: #{step.status} #{step.variables unless step.variables.empty? }".strip
        str = "#{str} * in: #{step.tokens_in.join(', ')}" if step.tokens_in.present?
        str = "#{str} * out: #{step.tokens_out.join(', ')}" if step.tokens_out.present?
        puts str
      end
    end

    def print_variables
      puts
      puts JSON.pretty_generate(variables)
    end

    def execution
      @execution ||= ProcessExecution.new(self)
    end
  end
end