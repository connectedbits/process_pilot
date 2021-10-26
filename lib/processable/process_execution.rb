module Processable
  class ProcessExecution
    attr_reader :process_instance

    delegate :element_by_id, to: :process_instance

    def initialize(process_instance)
      @process_instance = process_instance
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
      config.evaluate_condition(condition.body, variables: process_instance.variables)
    end

    def call_service(topic)
      service = config.get_service(topic)
      service.call(process_instance.variables)
    end

    def run_script(script)
      config.run_script(script, variables: process_instance.variables)
    end

    def step_instance_ended(step_instance)
      process_instance.variables = process_instance.variables.merge(step_instance.variables).with_indifferent_access
      
      if step_instance.tokens_out.empty?
        all_ended = true
        process_instance.steps.each { |step| all_ended = false unless step.status == 'ended' }
        update_status('ended') if all_ended
      else
        step_instance.tokens_out.each do |token|
          flow = element_by_id(token)
          execute_element(flow.target, token: token)
        end
      end
    end

    private

    def execute_element(element, token: nil)
      step_instance = StepInstance.new(process_instance, element: element, token: token)
      process_instance.steps.push step_instance
      element.execute(step_instance.execution)    
    end

    def update_status(status)
      process_instance.status = status
      event = "process_instance_#{status}".to_sym
      config.notify_listeners(event, process_instance)
    end

    def config
      Config.instance
    end
  end
end