module Processable
  class Context
    attr_reader :processes, :decisions
    attr_accessor :services, :listeners, :utils

    def initialize(sources: nil, services: {}, listeners: {}, utils: {}, async_services: false)
      @services = services
      @listeners = listeners

      @async_services = async_services

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

    def process_by_id(id)
      processes.find { |p| p.id == id }
    end

    def async_services?
      @async_services
    end
  end
end