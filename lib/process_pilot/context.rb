# frozen_string_literal: true

module ProcessPilot
  class Context
    attr_reader :processes, :decisions, :executions
    attr_accessor :services, :listeners, :utils

    def initialize(sources: nil, moddles: nil, services: {}, listeners: [])
      @services = services
      @listeners = Array.wrap(listeners)

      @processes = []
      @decisions = {}
      @executions = []

      Array.wrap(sources).each do |source|
        if source.include?("http://www.omg.org/spec/DMN/20180521/DC/")
          moddle = ProcessPilot::Services::DecisionReader.call(source)
          moddle["drgElement"].each { |d| decisions[d["id"]] = source }
        else
          moddle = ProcessPilot::Services::ProcessReader.call(source)
          builder = Bpmn::Builder.new(moddle)
          @processes = @processes + builder.processes
        end
      end

      Array.wrap(moddles).each do |moddle|
        if moddle["drgElement"]
          moddle["drgElement"].each { |d| decisions[d["id"]] = source }
        else
          builder = Bpmn::Builder.new(moddle)
          @processes = @processes + builder.processes
        end
      end
    end

    def start(process_id: nil, start_event_id: nil, variables: {})
      process = process_id ? process_by_id(process_id) : default_process
      raise ExecutionError.new(process_id ? "Process #{process_id} not found." : "No default process found.") if process.blank?
      execution = Execution.start(context: self, process: process, start_event_id: start_event_id, variables: variables)
      executions << execution
      execution
    end

    def start_with_message(message_name:, variables: {})
      [].tap do |executions|
        processes.map do |process|
          process.start_events.map do |start_event|
            start_event.message_event_definitions.map do |message_event_definition|
              if message_name == message_event_definition.message_name
                Execution.start(context: context, process_id: process&.id, variables: variables, start_event_id: start_event.id).tap { |execution| executions.push execution }
              end
            end
          end
        end
      end
    end

    def restore(execution_state)
      Execution.deserialize(execution_state, context: self).tap do |execution|
        executions << execution
      end
    end

    def notify_listener(event)
      listeners.each do |listener|
        listener[event[:event]].call(event) if listener[event[:event]]
      end if listeners.present?
    end

    def default_process
      processes.first
    end

    def process_by_id(id)
      processes.each do |process|
        return process if process.id == id
        process.sub_processes.each do |sub_process|
          return sub_process if sub_process.id == id
        end
      end
      nil
    end

    def element_by_id(id)
      processes.each do |process|
        element = process.element_by_id(id)
        return element if element
      end
      nil
    end

    def execution_by_id(id)
      executions.find { |e| e.id == id }
    end

    def execution_by_step_id(step_id)
      executions.find { |e| e.step.id == step_id }
    end
  end
end
