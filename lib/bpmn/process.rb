# frozen_string_literal: true

module Bpmn
  class Process < Element
    attr_accessor :is_executable
    attr_accessor :definitions, :elements, :parent
    attr_accessor :sub_processes

    def initialize(moddle)
      super

      @is_executable = moddle["isExecutable"]
      @elements = []
      @sub_processes = []
    end

    def element_by_id(id)
      elements.find { |e| e.id == id }
    end

    def elements_by_type(type)
      elements.select { |e| e.type == type }
    end

    def start_events
      elements_by_type("bpmn:StartEvent")
    end

    def default_start_event
      start_events.find { |se| se.event_definitions.empty? }
    end

    def execute(execution)
      execution.start
    end
  end

  class CallActivity < Activity
    attr_accessor :called_element, :process_ref

    def initialize(moddle)
      super
      @called_element = moddle["calledElement"]
      @process_ref = moddle["processRef"]
    end

    def execute(execution)
      if Bpmn::Expression.valid?(called_element)
        process_id = execution.evaluate_expression(expression)
      else
        process_id = called_element
      end
      execution.start_child(process_id: process_id, variables: execution.variables) if process_id
      execution.wait
    end
  end

  class SubProcess < Activity
    attr_accessor :definitions, :elements, :parent
    attr_accessor :is_executable, :triggered_by_event

    def initialize(moddle)
      super
      @is_executable = false
      @triggered_by_event = moddle["triggeredByEvent"]
    end
  end
end
