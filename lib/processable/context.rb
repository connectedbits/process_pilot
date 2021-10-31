module Processable
  class Context
    attr_reader :processes, :decisions
    attr_accessor :services, :listeners, :utils

    def initialize(sources: nil, services: {}, listeners: {}, utils: {}, external_services: false)
      @services = services
      @listeners = listeners

      @external_services = external_services

      @processes = []
      @decisions = {}
      @instances = []

      Array.wrap(sources).each do |source|
        if source.include?('http://www.omg.org/spec/DMN/20180521/DC/')
          moddle = ProcessableServices::DecisionReader.call(source)
          moddle["drgElement"].each { |d| decisions[d["id"]] = source}
        else
          moddle = ProcessableServices::ProcessReader.call(source)
          builder = Bpmn::Builder.new(moddle)
          @processes = @processes + builder.processes
        end
      end
    end

    def notify_listener(event)
      listeners[event[:event]].call(event) if listeners[event[:event]]
    end

    def process_by_id(id)
      processes.find { |p| p.id == id }
    end

    def external_services?
      @external_services
    end
  end
end