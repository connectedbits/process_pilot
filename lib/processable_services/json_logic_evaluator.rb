module ProcessableServices
  class JsonLogicEvaluator < ApplicationService
    attr_reader :expression, :variables

    def initialize(expression:, variables: {})
      super()
      @expression = expression
      @variables = variables
    end

    def call
      JSONLogic.apply(JSON.parse(expression).deep_stringify_keys, variables.deep_stringify_keys)
    end
  end
end
