# frozen_string_literal: true

module ProcessableServices
  class FeelEvaluator
    FEEL_EVALUATOR_BIN = File.expand_path(File.dirname(__FILE__)) + "/feel_evaluator.js"

    attr_reader :expression, :variables, :functions

    def self.call(expression:, variables:, functions: [])
      new(expression: expression, variables: variables, functions: functions).call
    end

    def initialize(expression:, variables: {}, functions: [])
      super()
      @expression = expression
      @variables = variables
      @functions = functions
    end

    def call
      command = [FEEL_EVALUATOR_BIN, expression, variables.to_json, *functions].shelljoin
      result = `#{command}`
      JSON.parse(result)
    rescue JSON::ParserError
      result.strip
    end
  end
end
