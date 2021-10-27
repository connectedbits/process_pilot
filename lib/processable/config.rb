require "singleton"

module Processable
  class Config
    include Singleton

    attr_accessor :services, :listeners, :utils, :decisions
    attr_accessor :async_services, :async_scripts, :async_business_rules

    def initialize
      reset_default_values
    end

    def reset_default_values
      @services = {}
      @listeners = []
      @utils = {}
      @decisions = {}
      @async_services = false
      @async_scripts = false
      @async_business_rules = false
    end

    def async_services?
      @async_services
    end

    def async_scripts?
      @async_scripts
    end

    def async_business_rules?
      @async_business_rules
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