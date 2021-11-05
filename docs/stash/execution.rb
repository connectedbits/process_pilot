# frozen_string_literal: true

module Processable
  class Execution
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :id, :process_id, :start_event, :status, :started_at, :ended_at, :variables, :parent_id, :called_by_id, :steps
    attr_accessor :context
    attr_writer :process, :start_event

    delegate :element_by_id, to: :process
    delegate :external_services?, to: :context
    delegate :print, to: :printer

    def self.start(context:, process_id:, start_event_id: nil, variables: {}, parent: nil, called_by: nil)
      process = context.process_by_id(process_id)
      raise ExecutionError.new("Process with id #{process_id} not found.") unless process
      start_event = start_event_id ? process.start_events.find { |se| se.id == start_event_id } : process.default_start_event
      raise ExecutionError.new("Start event with id #{start_event_id} not found for process #{process_id}.") unless start_event
      Execution.new(context: context, process_id: process&.id, start_event_id: start_event&.id, variables: variables, parent_id: parent&.id, called_by_id: called_by&.id).tap do |execution|
        context.executions.push execution
        process.execute(execution)
      end
    end

    def self.start_with_message(context:, message_name:, variables: {})
      [].tap do |executions|
        context.processes.map do |process|
          process.start_events.map do |start_event|
            start_event.message_event_definitions.map do |message_event_definition|
              if message_name == message_event_definition.message_name
                Execution.new(context: context, process_id: process&.id, start_event_id: start_event&.id, variables: variables).tap do  |execution|
                  executions.push execution
                  context.executions.push execution
                  process.execute(execution)
                end
              end
            end
          end
        end
      end
    end

    def initialize(attributes={})
      super.tap do
        @id ||= SecureRandom.uuid
        @process_id ||= process&.id
        @start_event_id ||= start_event_id
        @status ||= "initialized"
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
      @parent ||= context.execution_by_id(parent_id)
    end

    def called_by
      @called_by ||= parent.steps.find { |s| s.id == called_by_id } if parent
    end

    def message_received(message_name, variables: {})
      waiting_steps.each do |step|
        if step.element.is_a?(Bpmn::Event) && step.element.is_catching?
          step.element.message_event_definitions.each { |message_event_definition| step.invoke(variables: variables) if message_event_definition.message.name == message_name }
        end
      end
    end

    def error_received(error_name, variables: {})
      waiting_steps.each do |step|
        if step.element.is_a?(Bpmn::Event) && step.element.is_catching? && step.element.error_event_definition
          step.invoke(variables: variables) if step.element.error_event_definition.error_name == error_name
        end
      end
    end

    def check_expired_timers
      steps.each { |step| step.invoke if step.expires_at.present? && Time.zone.now > step.expires_at }
    end

    def start
      @started_at = Time.zone.now
      update_status("started")
      execute_element(start_event)
    end

    def terminate
      @ended_at = Time.zone.now
      update_status("terminated")
    end

    def end
      @ended_at = Time.zone.now
      update_status("ended")
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
      if step.element.is_a?(Bpmn::Event)
        if element.is_a?(Bpmn::BoundaryEvent) && element.cancel_activity
          step.attached_to&.terminate
        elsif element.is_a?(Bpmn::EndEvent) && element.is_terminate?
          steps.each { |s| s.terminate if s.waiting? }
        else
          source = step.sources.first
          if source && source.element.is_a?(Bpmn::EventBasedGateway)
            # Event based gateway event caught, terminate others
            source.targets.each do |target_step_execution|
              target_step_execution.terminate if (target_step_execution.id != step.id) && (target_step_execution.waiting?)
            end
          end
        end

        if element.is_throwing? && element.is_message?
          element.message_event_definitions.each do |message_event_definition|
            message_received(message_event_definition.message_name, variables: step.variables)
          end
        end
      end

      # Copy up variables
      @variables = variables.merge(step.variables).with_indifferent_access

      if step.tokens_out.empty?
        all_ended = true
        steps.each { |s| all_ended = false unless s.status == "ended" || s.status == "terminated" }
        if all_ended
          update_status("ended")
          called_by&.invoke(variables: variables)
        end
      else
        step.tokens_out.each do |token|
          flow = process.element_by_id(token)
          execute_element(flow.target, token: token)
        end
      end
    end

    def started?
      status == "started"
    end

    def ended?
      status == "ended"
    end

    def terminated?
      status == "terminated"
    end

    def tokens
      active_tokens = []
      steps.each do |step|
        active_tokens += step.tokens_out
        active_tokens -= step.tokens_in if step.ended?
      end
      active_tokens.uniq
    end

    def waiting_steps
      steps.filter { |step| step.waiting? }
    end

    def step_by_id(id)
      steps.find { |step| step.id == id }
    end

    def steps_by_element_id(id)
      steps.select { |step| step.element.id == id }
    end

    def step_by_element_id(id, latest: true)
      latest ? steps_by_element_id(id).last : steps_by_element_id(id).first
    end

    def printer
      @printer ||= Printer.new(self)
    end

    def attributes
      { 'id': nil, 'process_id': nil, 'status': nil, 'started_at': nil, 'ended_at': nil, 'variables': nil, 'parent_id': nil, 'called_by_id': nil }
    end

    def as_json(_options = {})
      {
        id:           id,
        process_id:   process_id,
        status:       status,
        started_at:   started_at,
        ended_at:     ended_at,
        variables:    variables,
        parent_id:    parent_id,
        called_by_id: called_by_id,
        steps:        steps.map { |step| step.as_json },
      }.compact
    end

    def serialize
      to_json
    end

    def self.deserialize(json, context:)
      attrs = JSON.parse(json)
      steps_attrs = attrs.delete("steps")
      Execution.new(attrs.merge(context: context)).tap do |e|
        e.steps = steps_attrs.map do |sa|
          StepExecution.new(sa.merge(execution: e))
        end
      end
    end

    private

    def execute_element(element, token: nil, attached_to: nil)
      step = steps.find { |s| s.element.id == element.id && s.waiting? }
      if step
        step.tokens_in.push token
      else
        step = StepExecution.new_for_execution(execution: self, element: element, token: token, attached_to: attached_to)
        attached_to.attachments.push(step) if attached_to
        steps.push step
      end
      element.execute(step)
    end

    def update_status(status)
      @status = status
      event = "process_#{status}".to_sym
      context.notify_listener({ event: event, execution: self })
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
        str = "#{index} #{step.element.type.split(':').last} #{step.element.id}: #{step.status} #{JSON.pretty_generate(variables, {indent: '', object_nl: ' ' }) unless step.variables.empty? }".strip
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
