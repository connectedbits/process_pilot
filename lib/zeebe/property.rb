# frozen_string_literal: true

module Zeebe
  class Property < Bpmn::Extension
    attr_accessor :name, :value

    def initialize(moddle)
      super(moddle)
      @name = moddle["name"]
      @value = moddle["value"]
    end
  end
end
