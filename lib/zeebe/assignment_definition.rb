# frozen_string_literal: true

module Zeebe
  class AssignmentDefinition < Bpmn::Extension
    attr_accessor :decision_id, :result_variable

    def initialize(moddle)
      super(moddle)
      @decision_id = moddle["decisionId"]
      @result_variable = moddle["resultVariable"]
    end
  end
end
