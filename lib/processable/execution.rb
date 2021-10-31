module Processable
  class Execution
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :id, :process_id, :start_event_id, :status, :started_at, :ended_at, :variables, :parent_id, :called_by_id, :steps
    attr_accessor :context, :process, :start_event

    delegate :element_by_id, to: :process
    delegate :external_services?, to: :context
    delegate :print, to: :printer

    def self.start(context:, process_id:, start_event_id: nil, variables: {})
      process = context.process_by_id(process_id)
      raise ExecutionError.new("Process with id #{process_id} not found.") unless process
      start_event = start_event_id ? process.start_events.find { |se| se.id == start_event_id } : process.default_start_event
      raise ExecutionError.new("Start event with id #{start_event_id} not found for process #{process_id}.") unless start_event
      Execution.new(context: context, process_id: process&.id, start_event_id: start_event&.id, variables: variables).tap { |e| process.execute(e) } 
    end

    def initialize(attributes={})
      super.tap do
        @id ||= SecureRandom.uuid
        @process_id ||= process&.id
        @start_event_id ||= start_event_id
        @status ||= 'initialized'
        @variables ||= {}
        @called_by_id ||= called_by_id
        @steps ||= []
      end
    end

    def process
      @process ||= context.process_by_id(process_id)
    end
    
    def start_event
      @start_event ||= process&.element_by_id(start_event_id)
    end

    def parent
      @parent ||= parent_id ? context.execution_by_id(parent_id) : nil
    end

    def called_by
      @called_by ||= called_by_id ? parent&.steps.find { |step| step.id == called_by_id } : nil
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
      @started_at = Time.now
      update_status('started')
      execute_element(start_event)
    end

    def terminate
      @ended_at = Time.now
      update_status('terminated')
    end

    def end
      @ended_at = Time.now
      update_status('ended')
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

    def steps_by_id(id)
      steps.select { |step| step.element.id == id }
    end

    def step_by_id(id, latest: true)
      latest ? steps_by_id(id).last : steps_by_id(id).first
    end

    def printer
      @printer ||= Printer.new(self)
    end

    def attributes
      { 'id': nil, 'process_id': nil, 'status': nil, 'started_at': nil, 'ended_at': nil, 'variables': nil, 'parent_id': nil, 'called_by_id': nil }
    end

    def as_json(options = {})
      {
        id: id,
        process_id: process_id,
        status: status,
        started_at: started_at,
        ended_at: ended_at,
        variables: variables,
        parent_id: parent_id,
        called_by_id: called_by_id,
        steps: steps.map { |step| step.as_json }
      }.compact
    end

    def serialize
      to_json
    end

    def self.deserialize(json, context:)
      attrs = JSON.parse(json)
      steps_attrs = attrs.delete('steps')
      Execution.new(attrs.merge(context: context)).tap do |e|
        e.steps = steps_attrs.map do |sa|
          StepExecution.new(sa.merge(execution: e))
        end
      end
    end

    private

    def execute_element(element, token: nil, attached_to: nil)
      step = steps.find { |step| step.element.id == element.id && step.waiting? }
      if step
        step.tokens_in.push token
      else
        step = StepExecution.new_for_execution(execution: self, element: element, token: token, attached_to: attached_to) 
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

  class Printer
    attr_accessor :execution

    delegate :process_id, :status, :tokens, :variables, :steps, to: :execution

    def initialize(execution)
      @execution = execution
    end

    def print
      puts
      puts "#{process_id} #{status} * #{tokens.join(', ')}"
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
  end
end