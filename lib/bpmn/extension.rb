# frozen_string_literal: true

module Bpmn
  class Extension
    attr_accessor :type, :moddle

    def initialize(moddle)
      @type = moddle["$type"]
      @moddle = moddle
    end
  end
end
