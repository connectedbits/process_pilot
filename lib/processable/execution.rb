module Processable
  class Execution
    attr_reader :runtime, :process, :start_event, :variables, :parent, :called_by
    attr_reader :id, :status, :steps

    delegate :async_services?, to: :runtime

    def initialize(runtime:, process:, start_event: nil, variables: {}, parent: nil, called_by: nil)
      @runtime = runtime
      @id = SecureRandom.uuid
      @process = process
      @start_event = start_event
      @variables = variables
      @parent = parent
      @called_by = called_by

      @status = 'created'
      @steps = []
    end

    def message_received(message_name, variables: {})
      steps.each do |step|
        if step.waiting? && step.element.is_a?(Bpmn::Event) && step.element.is_catching?
          step.element.message_event_definitions.each { |med| step.invoke if med.message.name == message_name }
        end
      end
    end

    def check_expired_timers
      steps.each { |step| step.invoke if step.expires_at.present? && Time.now > step.expires_at } 
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

    def evaluate_condition(condition)
      evaluate_expression(condition.body) == true
    end

    def evaluate_expression(expression)
      ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: variables)
    end

    def evaluate_decision(decision_ref)
      source = runtime.decisions[decision_ref]
      raise ExecutionError.new("Decision #{decision_ref} not found.") unless source
      ProcessableServices::DecisionEvaluator.call(decision_ref, source, variables)
    end

    def call_service(topic)
      service = runtime.services[topic.to_sym]
      raise ExecutionError.new("Service #{topic} not found.") unless service
      service.call(variables)
    end

    def run_script(script)
      raise ExecutionError.new("Script #{script} can't be blank.") unless script.present?
      ProcessableServices::ScriptRunner.call(script: script, variables: variables, utils: runtime.utils)
    end

    def step_waiting(step)
      start_attachments(step)
    end

    def step_terminated(step)
      terminate_attachments(step)    
    end

    def step_ended(step)      
      terminate_attachments(step)

      # Cancel event based gateway events?
      element = step.element
      if element.is_a?(Bpmn::Event) &&
        if element.is_a?(Bpmn::BoundaryEvent) && element.cancel_activity
          step.attached_to&.terminate
        else
          source = step.sources.first
          if source && source.element.is_a?(Bpmn::EventBasedGateway)
            # Event based gateway event caught, terminate others
            source.targets.each do |target_step_execution|
              target_step_execution.terminate if (target_step_execution.id != step.id) && (target_step_execution.waiting?)
            end
          end
        end
      end

      # Copy up variables
      @variables = variables.merge(step.variables).with_indifferent_access

      if step.tokens_out.empty?
        all_ended = true
        steps.each { |step| all_ended = false unless step.status == 'ended' || step.status == 'terminated' }
        update_status('ended') if all_ended
      else
        step.tokens_out.each do |token|
          flow = process.element_by_id(token)
          execute_element(flow.target, token: token)
        end
      end
    end

    def started?
      status == 'started'
    end

    def ended?
      status == 'ended'
    end

    def terminated?
      status == 'terminated'
    end

    def tokens
      active_tokens = []
      steps.each do |step|
        active_tokens += step.tokens_out
        active_tokens -= step.tokens_in if step.ended?
      end   
      active_tokens.uniq
    end

    def step_by_id(id)
      steps.find { |step| step.element.id == id }
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

    private

    def execute_element(element, token: nil, attached_to: nil)
      step = steps.find { |step| step.element.id == element.id && step.waiting? }
      if step
        step.tokens_in.push token
      else
        step = StepExecution.new(execution: self, element: element, token: token, attached_to: attached_to) 
        attached_to&.attachments.push step if attached_to
        steps.push step
      end
      element.execute(step)    
    end

    def update_status(status)
      @status = status
      event = "process_#{status}".to_sym
    end

    def start_attachments(step)
      step.element.attachments.each { |attachment| execute_element(attachment, attached_to: step) } if step.element.respond_to?(:attachments)
    end

    def terminate_attachments(step)
      step.attachments.each { |attached| attached.terminate if attached.waiting? }
    end
  end
end