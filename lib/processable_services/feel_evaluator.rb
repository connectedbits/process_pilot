module ProcessableServices
  class FeelEvaluator < ApplicationService
    FEEL_EVALUATOR_BIN = File.expand_path(File.dirname(__FILE__)) + "/feel_evaluator.js"

    attr_reader :expression, :data

    def initialize(expression, data: {})
      super()
      @expression = expression
      @data = data
    end

    def call
      command = [FEEL_EVALUATOR_BIN, expression, data.to_json].shelljoin
      result = `#{command}`
      JSON.parse(result)
    rescue JSON::ParserError
      result.strip
    end
  end
end
