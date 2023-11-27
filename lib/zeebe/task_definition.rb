# frozen_string_literal: true

module Zeebe
  class TaskDefinition < Bpmn::Extension
    attr_accessor :type, :retries

    def initialize(moddle)
      super(moddle)
      @type = moddle["type"]
      @retries = moddle["retries"]
    end
  end
end
