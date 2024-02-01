# frozen_string_literal: true
require "test_helper"

module ProcessPilot
  module Services
    describe ProcessReader do
      let(:service) { ProcessReader }
      let(:source) { fixture_source("kitchen_sink.bpmn") }
      let(:moddle) { service.call(source) }

      it "should parse bpmn moddle" do
        _(moddle).wont_be_nil
        _(moddle.dig("rootElement", "id")).must_equal("Definitions_08enszp")
      end
    end
  end
end
