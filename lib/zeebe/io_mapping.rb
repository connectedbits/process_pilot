# frozen_string_literal: true

module Zeebe
  class IoMapping
    def initialize(moddle)
      @inputs = moddle["inputParameters"] || []
      @outputs = moddle["outputParameters"] || []
    end

    def inputs
      @inputs.map { |parameter_moddle| Parameter.new(parameter_moddle) }
    end

    def outputs
      @outputs.map { |parameter_moddle| Parameter.new(parameter_moddle) }
    end
  end
end
