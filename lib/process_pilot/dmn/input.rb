# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Input < Element
      attr_reader :label, :type_ref, :expression

      def initialize(moddle)
        super(moddle)

        @label = moddle["label"]
        input_expression = moddle["inputExpression"]
        if input_expression
          @type_ref = input_expression["typeRef"]
          @expression = input_expression["text"]
        end
      end
    end
  end
end
