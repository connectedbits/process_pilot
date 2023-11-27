# frozen_string_literal: true

module Zeebe
  class Script
    attr_accessor :expression, :result_variable

    def initialize(moddle)
      @expression = moddle["expression"]
      @result_variable = moddle["resultVariable"]
    end
  end
end
