# frozen_string_literal: true

module Zeebe
  class Properties < Bpmn::Extension
    attr_accessor :properties

    def initialize(moddle)
      super(moddle)
      @properties = moddle["properties"].map { |property_moddle| Property.new(property_moddle) }
    end
  end
end
