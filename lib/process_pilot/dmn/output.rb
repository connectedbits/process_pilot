# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Output < Element
      attr_reader :label, :name, :type_ref, :value

      def initialize(moddle)
        super(moddle)

        @label = moddle["label"]
        @name = moddle["name"]
        @type_ref = moddle["typeRef"]
        @value = moddle["text"]
      end
    end
  end
end
