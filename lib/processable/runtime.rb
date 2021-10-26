module Processable
  class Runtime
    attr_reader :processes

    def initialize(sources: nil, services: nil)
      @processes = []
      config.services = services if services

      Array.wrap(sources).each do |source|
        if source.include?('http://www.omg.org/spec/DMN/20180521/DC/')
          moddle = ProcessableServices::DecisionReader.call(source)
          moddle["drgElement"].each { |d| config.decisions[d["id"]] = source}
        else
          moddle = ProcessableServices::ProcessReader.call(source)
          builder = Bpmn::Builder.new(moddle)
          @processes = @processes + builder.processes
        end
      end
    end

    def process_by_id(id)
      processes.find { |p| p.id == id }
    end

    def start_process(process_id, start_event_id: nil, variables: {}, key: nil)
      process = process_by_id(process_id)
      raise ExecutionError.new("Process with id #{process_id} not found.") unless process
      start_event = start_event_id ? process.start_events.find { |se| se.id == start_event_id } : process.default_start_event
      raise ExecutionError.new("Start event with id #{start_event_id} not found for process #{process_id}.") unless start_event
      ProcessInstance.new(process, start_event: start_event, variables: variables, key: key).tap { |pi| process.execute(pi.execution) } 
    end

    def config
      Config.instance
    end
  end
end