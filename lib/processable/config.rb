require "singleton"

module Processable
  class Config
    include Singleton

    attr_accessor :services, :listeners, :utils, :decisions

    def initialize
      @services = {}
      @listeners = []
      @utils = {}
      @decisions = {}
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