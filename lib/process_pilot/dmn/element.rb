# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Element
      attr_accessor :type, :id

      def initialize(moddle)
        @type = moddle["$type"]
        @id = moddle["id"]
      end

      def self.from_moddle(moddle)
        return nil if moddle["$type"].start_with?("bpmndi")
        begin
          if klass = "ProcessPilot::Dmn::#{moddle["$type"].split(':').last}".safe_constantize
            klass.new(moddle)
          else
            ap "Error creating instance of #{moddle["$type"]}"
            Element.new(moddle)
          end
        end
      end
    end
  end
end
