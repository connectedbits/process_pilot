module ProcessableServices
  class JsonLogicEvaluator < ApplicationService
    attr_reader :expression, :data

    def initialize(expression, data: {})
      super()
      @expression = expression
      @data = data
    end

    def call
      JSONLogic.apply(JSON.parse(expression).deep_stringify_keys, data.deep_stringify_keys)
    end
  end
end
