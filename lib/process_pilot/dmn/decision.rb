# frozen_string_literal: true

module ProcessPilot
  module Dmn
    class Decision < Element
      attr_reader :name, :hit_policy, :inputs, :outputs, :rules

      def initialize(moddle)
        super(moddle)

        @name = moddle["name"]

        @hit_policy = moddle["hitPolicy"] || "UNIQUE"

        decision_logic = moddle["decisionLogic"]
        if decision_logic
          @inputs = decision_logic["input"].map { |im| Input.new(im) } if decision_logic["input"]
          @outputs = decision_logic["output"].map { |om| Output.new(om) } if decision_logic["output"]
          @rules = decision_logic["rule"].map { |rm| Rule.new(rm) } if decision_logic["rule"]
        end
      end
    end
  end
end
