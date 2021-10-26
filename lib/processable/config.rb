require "singleton"

module Processable
  class Config
    include Singleton

    attr_accessor :services, :context, :utils, :listeners, :logs

    def initialize
      @services = {}
      @listeners = []
      @utils = {}
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

    def evaluate_decision(ref, source, data: {})
      ProcessableServices::DecsionEvaluator.call(ref, source, data)
    end
  end
end