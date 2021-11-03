# frozen_string_literal: true

module Processable
  class Context
    attr_reader :processes, :decisions, :executions
    attr_accessor :services, :listeners, :utils
    attr_accessor :service_task_runner, :script_task_runner, :business_rule_task_runner

    def initialize(sources: nil, services: {}, listeners: {}, utils: {}, service_task_runner: ServiceTaskRunner, script_task_runner: ScriptTaskRunner, business_rule_task_runner: BusinessRuleTaskRunner)    
      @services = services
      @listeners = listeners
      @utils = utils
      @service_task_runner = service_task_runner
      @script_task_runner = script_task_runner
      @business_rule_task_runner = business_rule_task_runner

      @processes = []
      @decisions = {}
      @executions = []

      Array.wrap(sources).each do |source|
        if source.include?("http://www.omg.org/spec/DMN/20180521/DC/")
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
      processes.each do |process| 
        return process if process.id == id
        process.sub_processes.each do |sub_process|
          return sub_process if sub_process.id == id
        end
      end
    end

    def execution_by_id(id)
      executions.find { |e| e.id == id }
    end

    def execution_by_process_id(process_id)
      executions.find { |e| e.process.id == process_id }
    end
  end
end
