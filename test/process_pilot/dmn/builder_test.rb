# frozen_string_literal: true

require "test_helper"

module ProcessPilot
  module Dmn
    describe Builder do
      let(:source) { fixture_source("dish.dmn") }
      let(:moddle) { ProcessPilot::Services::DecisionReader.call(source) }
      let(:builder) { Builder.new(moddle) }
      let(:decision) { builder.decision_by_id("Dish") }

      it "should parse the decision" do
                File.write('moddle.json', moddle.to_json)
        _(decision).wont_be_nil
        _(decision).must_be_kind_of(ProcessPilot::Dmn::Decision)
        _(decision.id).must_equal("Dish")
        _(decision.name).must_equal("Dish")
        _(decision.inputs.size).must_equal(2)
        _(decision.outputs.size).must_equal(1)
        _(decision.rules.size).must_equal(6)
      end
    end
  end
end
