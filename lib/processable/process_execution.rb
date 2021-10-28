module Processable
  class ProcessExecution
    attr_reader :process_instance

    delegate :element_by_id, to: :process_instance

    def initialize(process_instance)
      @process_instance = process_instance
    end

    def message_received(message_name, variables: {})
      process_instance.steps.each do |step|
        if step.status == 'waiting' && step.element.is_a?(Bpmn::Event) && step.element.is_catching?
          step.element.message_event_definitions.each { |med| ap med; step.invoke if med.message.name == message_name }
        end
      end
    end

    def check_expired_timers
      process_instance.steps.each { |step_instance| step_instance.invoke if step_instance.expires_at.present? && Time.now > step_instance.expires_at } 
    end

    def start
      update_status('started')
      execute_element(process_instance.start_event)
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
      ProcessableServices::ExpressionEvaluator.call(expression, variables: process_instance.variables)
    end

    def evaluate_decision(decision_ref)
      source = config.decisions[decision_ref]
      raise ExecutionError.new("Decision #{decision_ref} not found.") unless source
      config.evaluate_decision(decision_ref, source, variables: process_instance.variables)
    end

    def call_service(topic)
      service = config.get_service(topic)
      raise ExecutionError.new("Service #{topic} not found.") unless service
      service.call(process_instance.variables)
    end

    def run_script(script)
      raise ExecutionError.new("Script #{script} can't be blank.") unless script.present?
      config.run_script(script, variables: process_instance.variables)
    end

    def step_instance_waiting(step_instance)
      # Start attachments
      step_instance.element.attachments&.each { |attachment| execute_element(attachment, attached_to: step_instance) } if step_instance.element.respond_to?(:attachments)
    end

    def step_instance_terminated(step_instance)
      terminate_attachments(step_instance)    
    end

    def step_instance_ended(step_instance)      
      terminate_attachments(step_instance)

      # Cancel event based gateway events?
      element = step_instance.element
      if element.is_a?(Bpmn::Event) &&
        if element.is_a?(Bpmn::BoundaryEvent) && element.cancel_activity
          StepExecution.new(step_instance.attached_to).terminate
        else
          source = step_instance.sources.first
          if source && source.element.is_a?(Bpmn::EventBasedGateway)
            # Event based gateway event caught, terminate others
            source.targets.each do |ti|
              StepExecution.new(ti).terminate if (ti.id != step_instance.id) && (ti.waiting?)
            end
          end
        end
      end

      # Copy up variables
      process_instance.variables = process_instance.variables.merge(step_instance.variables).with_indifferent_access

      if step_instance.tokens_out.empty?
        all_ended = true
        process_instance.steps.each { |step| all_ended = false unless step.status == 'ended' || step.status == 'terminated' }
        update_status('ended') if all_ended
      else
        step_instance.tokens_out.each do |token|
          flow = element_by_id(token)
          execute_element(flow.target, token: token)
        end
      end
    end

    private

    def execute_element(element, token: nil, attached_to: nil)
      step_instance = process_instance.steps.find { |si| si.element.id == element.id && si.status == 'waiting' }
      if step_instance
        step_instance.tokens_in.push token
      else
        step_instance = StepInstance.new(process_instance, element: element, token: token, attached_to: attached_to) 
        attached_to&.attachments.push step_instance if attached_to
        process_instance.steps.push step_instance
      end
      element.execute(step_instance.execution)    
    end

    def update_status(status)
      process_instance.status = status
      event = "process_instance_#{status}".to_sym
      config.notify_listeners(event, process_instance)
    end

    def terminate_attachments(step_instance)
      return unless step_instance.respond_to?(:attachments) && step_instance.attachments.present?
      step_instance.attachments.each { |attached_instance| StepExecution.new(attached_instance).terminate if attached_instance.waiting? }
    end

    def config
      Config.instance
    end
  end
end