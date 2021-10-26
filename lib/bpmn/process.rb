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
      elements_by_type('bpmn:StartEvent')
    end

    def default_start_event
      start_events.find { |se| se.event_definitions.empty? }
    end

    def execute(execution)
      execution.start
    end
  end

  class CallActivity < Element
  end
end