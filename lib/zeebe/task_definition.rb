# frozen_string_literal: true

module Zeebe
  class TaskDefinition
    attr_accessor :type, :retries

    def initialize(moddle)
      @type = moddle["type"]
      @retries = moddle["retries"]
    end
  end
end
