module Processable
  class ProcessInstance
    include ActiveModel::Model
    
    attr_reader :process, :start_event, :variables, :key, :parent, :called_by, :status, :steps

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

    def start
      update_status('started')
      execute_element(start_event)
    end

    def terminate
      update_status('terminated')
    end

    def end
      update_status('ended')
    end

    def step_instance_ended(step_instance)
      variables.merge!(step_instance.variables)
      
      if step_instance.tokens_out.empty?
        all_ended = true
        steps.each { |step| all_ended = false unless step.status == 'ended' }
        update_status('ended') if all_ended
      else
        step_instance.tokens_out.each do |token|
          flow = element_by_id(token)
          execute_element(flow.target, token: token)
        end
      end
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

    private

    def execute_element(element, token: nil)
      step = StepInstance.new(self, element: element, token: token)
      steps.push step
      element.execute(step)    
    end

    def update_status(status)
      @status = status
      event = "process_instance_#{status}".to_sym
      #Config.instance.listeners.each { |l| l[event].call(self) if l[event] }
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
  end
end