# frozen_string_literal: true

module ProcessableServices
  class DecisionEvaluator < ApplicationService
    EVALUATE_BIN = File.expand_path(File.dirname(__FILE__)) + "/decision_evaluator.js"

    def initialize(decision_id, source, context)
      super()
      @decision_id = decision_id
      @source = source
      @context = context
    end

    def call
      command = [EVALUATE_BIN, @decision_id, @source, @context.to_json].shelljoin
      result = `#{command}`
      JSON.parse(result)
    end
  end
end
