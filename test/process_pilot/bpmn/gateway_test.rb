# frozen_string_literal: true

require "test_helper"

module Orchestr8
  module Bpmn

    describe ExclusiveGateway do
      let(:source) { fixture_source("exclusive_gateway_test.bpmn") }
      let(:context) { Orchestr8.new(source) }
      let(:process) { context.process_by_id("ExclusiveGatewayTest") }

      describe :definition do
        let(:exclusive_gateway) { process.element_by_id("ExclusiveGateway") }
        let(:flow_ok) { process.element_by_id("FlowOK") }
        let(:flow_not_ok) { process.element_by_id("FlowNotOK") }
        let(:flow_default)  { process.element_by_id("FlowDefault") }

        it "should parse the gateway" do
          _(exclusive_gateway).wont_be_nil
          _(exclusive_gateway.default).wont_be_nil
          _(flow_ok).wont_be_nil
          _(flow_not_ok).wont_be_nil
          _(flow_default).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:exclusive_gateway) { process.child_by_step_id("ExclusiveGateway") }
        let(:end_ok) { process.child_by_step_id("EndOK") }
        let(:end_not_ok) { process.child_by_step_id("EndNotOK") }
        let(:end_default) { process.child_by_step_id("EndDefault") }

        describe :happy_path do
          before { @process = Orchestr8.new(source).start(variables: { action: "ok" }) }

          it "should complete ok" do
            _(process.ended?).must_equal true
            _(end_ok).wont_be_nil
            _(end_not_ok).must_be_nil
            _(end_default).must_be_nil
          end
        end

        describe :default_path do
          before { @process = Orchestr8.new(source).start(variables: { action: "¯\_(ツ)_/¯" }) }

          it "should complete ok" do
            _(process.ended?).must_equal true
            _(end_ok).must_be_nil
            _(end_not_ok).must_be_nil
            _(end_default).wont_be_nil
          end
        end
      end
    end

    describe ParallelGateway do
      let(:source) { fixture_source("parallel_gateway_test.bpmn") }
      let(:context) { Orchestr8.new(source) }
      let(:process) { context.process_by_id("ParallelGatewayTest") }

      describe :definition do
        let(:split) { process.element_by_id("Split") }
        let(:join) { process.element_by_id("Join") }
        let(:task_a) { process.element_by_id("TaskA") }
        let(:task_b) { process.element_by_id("TaskB") }

        it "should parse the gateway" do
          _(split).wont_be_nil
          _(join).wont_be_nil
          _(task_a).wont_be_nil
          _(task_b).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:split) { process.child_by_step_id("Split") }
        let(:join) { process.child_by_step_id("Join") }
        let(:task_a) { process.child_by_step_id("TaskA") }
        let(:task_b) { process.child_by_step_id("TaskB") }

        before { @process = Orchestr8.new(source).start }

        it "should diverge at the first gateway" do
          _(split.ended?).must_equal true
          _(join).must_be_nil
          _(process.children.count).must_equal 4
        end

        describe :converging do
          before { task_a.signal }

          it "should wait when first token arrives" do
            _(task_a.ended?).must_equal true
            _(task_b.ended?).must_equal false
            _(join.ended?).must_equal false
          end

          describe :join do
            before { task_b.signal }

            it "should continue from join gateway" do
              _(process.ended?).must_equal true
              _(task_a.ended?).must_equal true
              _(task_b.ended?).must_equal true
              _(join.ended?).must_equal true
            end
          end
        end
      end
    end

    describe EventBasedGateway do
      let(:source) { fixture_source("event_based_gateway_test.bpmn") }
      let(:context) { Orchestr8.new(source) }
      let(:process) { context.process_by_id("EventBasedGatewayTest") }

      describe :definition do
        let(:gateway) { process.element_by_id("EventBasedGateway") }
        let(:message_event) { process.element_by_id("MessageEvent") }
        let(:timer_event) { process.element_by_id("TimerEvent") }
        let(:end_message) { process.element_by_id("EndMessage") }
        let(:end_timer) { process.element_by_id("EndTimer") }

        it "should parse the gateway" do
          _(gateway).wont_be_nil
          _(message_event).wont_be_nil
          _(timer_event).wont_be_nil
          _(end_message).wont_be_nil
          _(end_timer).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:gateway) { process.child_by_step_id("EventBasedGateway") }
        let(:message_event) { process.child_by_step_id("MessageEvent") }
        let(:timer_event) { process.child_by_step_id("TimerEvent") }
        let(:end_message) { process.child_by_step_id("EndMessage") }
        let(:end_timer) { process.child_by_step_id("EndTimer") }

        before { @process = Orchestr8.new(source).start }

        it "should diverge at the event gateway" do
          _(gateway.ended?).must_equal true
          _(message_event.ended?).must_equal false
          _(timer_event.ended?).must_equal false
        end

        describe :event_occurs do
          before { message_event.signal }

          it "should complete the process" do
            _(process.ended?).must_equal true
            _(message_event.ended?).must_equal true
            # _(timer_event.terminated?).must_equal true
            _(end_message.ended?).must_equal true
            _(end_timer).must_be_nil
          end
        end
      end
    end

    describe InclusiveGateway do
      let(:source) { fixture_source("inclusive_gateway_test.bpmn") }
      let(:context) { Orchestr8.new(source) }
      let(:process) { context.process_by_id("InclusiveGatewayTest") }

      describe :definition do
        let(:split) { process.element_by_id("Split") }
        let(:join) { process.element_by_id("Join") }
        let(:receive_order) { process.element_by_id("ReceiveOrder") }
        let(:check_laptop_parts) { process.element_by_id("CheckLaptopParts") }
        let(:check_prices) { process.element_by_id("CheckPrices") }
        let(:check_printer_parts) { process.element_by_id("CheckPrinterParts") }

        it "should parse the gateway" do
          _(split).wont_be_nil
          _(join).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:split) { process.child_by_step_id("Split") }
        let(:join) { process.child_by_step_id("Join") }
        let(:receive_order) { process.child_by_step_id("ReceiveOrder") }
        let(:check_laptop_parts) { process.child_by_step_id("CheckLaptopParts") }
        let(:check_prices) { process.child_by_step_id("CheckPrices") }
        let(:check_printer_parts) { process.child_by_step_id("CheckPrinterParts") }

        before { @process = Orchestr8.new(source).start }

        it "should wait at receive order task" do
          _(receive_order.ended?).must_equal false
        end

        describe :first_path do
          before { receive_order.signal({ include_laptop_parts: true, include_printer_parts: false }) }

          it "should create correct task" do
            _(check_laptop_parts).wont_be_nil
            _(check_laptop_parts.ended?).must_equal false
            _(check_printer_parts).must_be_nil
            _(check_prices).must_be_nil
          end
        end

        describe :second_path do
          before { receive_order.signal({ include_laptop_parts: false, include_printer_parts: true }) }

          it "should create correct task" do
            _(check_laptop_parts).must_be_nil
            _(check_printer_parts).wont_be_nil
            _(check_prices).must_be_nil
          end
        end

        describe :default_path do
          before { receive_order.signal({ include_laptop_parts: false, include_printer_parts: false }) }

          it "should create the default task" do
            _(check_laptop_parts).must_be_nil
            _(check_printer_parts).must_be_nil
            _(check_prices).wont_be_nil
          end
        end

        describe :multiple_paths do
          before { receive_order.signal({ include_laptop_parts: true, include_printer_parts: true }) }

          it "should create the correct tasks" do
            _(check_laptop_parts).wont_be_nil
            _(check_printer_parts).wont_be_nil
            _(check_prices).must_be_nil
          end

          describe :resume_first do
            before { check_laptop_parts.signal }

            it "should wait at join gateway" do
              _(check_laptop_parts.ended?).must_equal true
              _(check_printer_parts.ended?).must_equal false
            end

            describe :resume_second do
              before { check_printer_parts.signal }

              it "should complete the process" do
                _(process.ended?).must_equal true
                _(check_printer_parts.ended?).must_equal true
              end
            end
          end
        end
      end
    end
  end
end
