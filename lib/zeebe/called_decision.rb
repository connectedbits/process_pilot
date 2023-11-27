# frozen_string_literal: true

module Zeebe
  class CalledDecision
    attr_accessor :decision_id, :result_variable

    def initialize(moddle)
      @decision_id = moddle["decisionId"]
      @result_variable = moddle["resultVariable"]
    end
  end
end
