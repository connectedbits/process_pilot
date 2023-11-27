# frozen_string_literal: true

module Zeebe
  class Script < Bpmn::Extension
    attr_accessor :expression, :result_variable

    def initialize(moddle)
      super(moddle)
      @expression = moddle["expression"]
      @result_variable = moddle["resultVariable"]
    end
  end
end
