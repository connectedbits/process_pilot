# frozen_string_literal: true

require "test_helper"

module Bpmn

  describe "IO Mapping" do
    let(:source) { fixture_source("io_mapping.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definition do
      let(:process) { context.process_by_id("IOMapping") }
      let(:start_event) { process.element_by_id("Start") }
      let(:check_inventory_task) { process.element_by_id("CheckInventory") }
      let(:order_product_task) { process.element_by_id("OrderProduct") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the task" do
        _(start_event).wont_be_nil
        _(check_inventory_task).wont_be_nil
        _(order_product_task).wont_be_nil
        _(end_event).wont_be_nil
      end
    end

    describe :execution do

    end
  end
end
