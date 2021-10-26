module ProcessableServices
  class ExpressionEvaluator < ApplicationService

    attr_reader :expression, :data

    def initialize(expression, data: {})
      super()
      @expression = expression.strip
      @data = data
    end

    def call
      json_logic? ? call_json_logic : call_feel
    end

    def call_feel
      FeelEvaluator.call(expression.delete_prefix("${").delete_suffix("}").strip, data: data)
    end

    def call_json_logic
      JsonLogicEvaluator.call(expression, data: data)
    end

    def feel?
      expression.start_with?("${") && expression.end_with?("}")
    end

    def json_logic?
      expression.start_with?("{") && expression.end_with?("}")
    end
  end
end
