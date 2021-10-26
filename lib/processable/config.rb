require "singleton"

module Processable
  class Config
    include Singleton

    attr_accessor :services, :utils, :listeners, :logs

    def initialize
      @services = {}
      @listeners = []
      @logs = []
    end

    def notify_listeners(event, instance)
    end

    def run_script(script, data: {})
      ScriptRunner.call(script, data: data, context: context, utils: utils)
    end

    def evaluate_expression(expression, data: {})
      ExpressionEvaluator.call(expression, data: { data: data, context: context })
    end

    def evaluate_decision(ref, source, data: {})
      DecsionEvaluator.call(ref, source, data)
    end
  end
end