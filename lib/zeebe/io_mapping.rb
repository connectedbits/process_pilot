# frozen_string_literal: true

module Zeebe
  class IoMapping
    attr_accessor :inputs, :outputs

    def initialize(moddle)
      @inputs = moddle["inputParameters"]&.map { |parameter_moddle| Parameter.new(parameter_moddle) }
      @outputs = moddle["outputParameters"]&.map { |parameter_moddle| Parameter.new(parameter_moddle) }
    end
  end
end
