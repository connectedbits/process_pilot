# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Rule < Element
      attr_reader :input_entries, :output_entries

      def initialize(moddle)
        super(moddle)

        @input_entries = moddle["inputEntry"].map { |iem| iem["text"] } if moddle["inputEntry"]
        @output_entries = moddle["outputEntry"].map { |oem| oem["text"] } if moddle["outputEntry"]
      end
    end
  end
end
