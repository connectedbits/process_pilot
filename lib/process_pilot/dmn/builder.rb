# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Builder
      attr_reader :id, :name, :elements, :decisions

      def initialize(moddle)
        @id = moddle["id"]
        @name = moddle["name"]

        @elements = {}
        @decisions = {}

        moddle["drgElement"].each do |element_json|
          element = Element.from_moddle(element_json)
          if element
            @elements[element.id] = element
            @decisions[element.id] = element if element.is_a?(Decision)
          end
        end
      end
    end
  end
end
