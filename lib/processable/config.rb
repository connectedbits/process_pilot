require "singleton"

module Processable
  class Config
    include Singleton

    attr_accessor :services, :listeners, :utils, :decisions
    attr_accessor :run_scripts, :call_services, :evaluate_decisions

    def initialize
      @services = {}
      @listeners = []
      @utils = {}
      @decisions = {}
      @run_scripts = true
      @call_services = true
      @evaluate_decisions = true
    end

    def run_scripts?
      run_scripts
    end

    def call_services?
      call_services
    end

    def evaluate_decisions?
      evaluate_decisions
    end

    def notify_listeners(event, instance)
    end

    def run_script(script, variables: {})
      ProcessableServices::ScriptRunner.call(script, variables: variables, utils: utils)
    end

    def get_service(topic)
      services[topic.to_sym]
    end

    def evaluate_expression(expression, variables: {})
      ProcessableServices::ExpressionEvaluator.call(expression, variables: variables)
    end

    def evaluate_decision(ref, source, variables: {})
      ProcessableServices::DecisionEvaluator.call(ref, source, variables)
    end
  end
end