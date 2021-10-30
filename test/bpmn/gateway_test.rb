require "test_helper"

module Bpmn

  describe ExclusiveGateway do
    let(:source) { fixture_source('exclusive_gateway_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('ExclusiveGatewayTest') }

    describe :definition do
      let(:exclusive_gateway) { process.element_by_id('ExclusiveGateway') }

      it 'should parse the gateway' do
        _(exclusive_gateway).wont_be_nil
        _(exclusive_gateway.default).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:exclusive_gateway_step) { execution.step_by_id('ExclusiveGateway') }
      let(:end_ok_step) { execution.step_by_id('EndOK') }
      let(:end_not_ok_step) { execution.step_by_id('EndNotOK') }
      let(:end_default_step) { execution.step_by_id('EndDefault') }

      describe :happy_path do
        before { @execution = Processable::Execution.start(context: context, process_id: 'ExclusiveGatewayTest', variables: { action: "ok" }) }

        it "should complete ok" do
          _(execution.ended?).must_equal true
          _(end_ok_step).wont_be_nil
          _(end_not_ok_step).must_be_nil
          _(end_default_step).must_be_nil
        end
      end

      describe :default_path do
        before { @execution = Processable::Execution.start(context: context, process_id: 'ExclusiveGatewayTest', variables: { action: '¯\_(ツ)_/¯' }) }

        it "should complete ok" do
          _(execution.ended?).must_equal true
          _(end_ok_step).must_be_nil
          _(end_not_ok_step).must_be_nil
          _(end_default_step).wont_be_nil
        end
      end
    end
  end

  describe ParallelGateway do
    let(:source) { fixture_source('parallel_gateway_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('ParallelGatewayTest') }

    describe :definition do
      let(:split) { process.element_by_id('Split') }
      let(:join) { process.element_by_id('Join') }
      let(:task_a) { process.element_by_id('TaskA') }
      let(:task_b) { process.element_by_id('TaskB') }

      it 'should parse the gateway' do
        _(split).wont_be_nil
        _(join).wont_be_nil
        _(task_a).wont_be_nil
        _(task_b).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:split_step) { execution.step_by_id('Split') }
      let(:join_step) { execution.step_by_id('Join') }
      let(:task_a_step) { execution.step_by_id('TaskA') }
      let(:task_b_step) { execution.step_by_id('TaskB') }

      before { @execution = Processable::Execution.start(context: context, process_id: 'ParallelGatewayTest') }

      it "should diverge at the first gateway" do
        _(split_step.ended?).must_equal true
        _(join_step).must_be_nil
        _(execution.steps.count).must_equal 4
      end

      describe :converging do
        before { task_a_step.invoke }

        it "should wait when first token arrives" do
          _(task_a_step.ended?).must_equal true
          _(task_b_step.waiting?).must_equal true
          _(join_step.waiting?).must_equal true
        end

        describe :join do
          before { task_b_step.invoke }

          it "should continue from join gateway" do
            _(execution.ended?).must_equal true
            _(task_a_step.ended?).must_equal true
            _(task_b_step.ended?).must_equal true
            _(join_step.ended?).must_equal true
          end
        end
      end
    end

    describe InclusiveGateway do
      let(:source) { fixture_source('inclusive_gateway_test.bpmn') }
      let(:context) { Processable::Context.new(sources: source) }
      let(:process) { context.process_by_id('InclusiveGatewayTest') }
  
      describe :definition do
        let(:split) { process.element_by_id('Split') }
        let(:join) { process.element_by_id('Join') }
        let(:receive_order) { process.element_by_id('ReceiveOrder') }
        let(:check_laptop_parts) { process.element_by_id('CheckLaptopParts') }
        let(:check_prices) { process.element_by_id('CheckPrices') }
        let(:check_printer_parts) { process.element_by_id('CheckPrinterParts') }
  
        it 'should parse the gateway' do
          _(split).wont_be_nil
          _(join).wont_be_nil
        end
      end
  
      describe :execution do
        let(:execution) { @execution }
        let(:split_step) { execution.step_by_id('Split') }
        let(:join_step) { execution.step_by_id('Join') }
        let(:receive_order_step) { execution.step_by_id('ReceiveOrder') }
        let(:check_laptop_parts_step) { execution.step_by_id('CheckLaptopParts') }
        let(:check_prices_step) { execution.step_by_id('CheckPrices') }
        let(:check_printer_parts_step) { execution.step_by_id('CheckPrinterParts') }
    
        before { @execution = Processable::Execution.start(context: context, process_id: 'InclusiveGatewayTest') }

        it "should wait at receive order task" do
          _(receive_order_step.waiting?).must_equal true
        end

        describe :first_path do
          before { receive_order_step.invoke(variables: { include_laptop_parts: true, include_printer_parts: false }) }

          it "should create correct task" do
            _(check_laptop_parts_step).wont_be_nil
            _(check_laptop_parts_step.waiting?).must_equal true
            _(check_printer_parts_step).must_be_nil
            _(check_prices_step).must_be_nil
          end
        end

        describe :second_path do
          before { receive_order_step.invoke(variables: { include_laptop_parts: false, include_printer_parts: true }) }

          it "should create correct task" do
            _(check_laptop_parts_step).must_be_nil
            _(check_printer_parts_step).wont_be_nil
            _(check_prices_step).must_be_nil
          end
        end

        describe :default_path do
          before { receive_order_step.invoke(variables: { include_laptop_parts: false, include_printer_parts: false }) }

          it "should create the default task" do
            _(check_laptop_parts_step).must_be_nil
            _(check_printer_parts_step).must_be_nil
            _(check_prices_step).wont_be_nil
          end
        end

        describe :multiple_paths do
          before { receive_order_step.invoke(variables: { include_laptop_parts: true, include_printer_parts: true }) }

          it "should create the correct tasks" do
            _(check_laptop_parts_step).wont_be_nil
            _(check_printer_parts_step).wont_be_nil
            _(check_prices_step).must_be_nil
          end

          describe :resume_first do
            before { check_laptop_parts_step.invoke }

            it "should wait at join gateway" do
              _(check_laptop_parts_step.ended?).must_equal true
              _(check_printer_parts_step.waiting?).must_equal true
            end

            describe :resume_second do
              before { check_printer_parts_step.invoke }

              it "should complete the process" do
                _(execution.ended?).must_equal true
                _(check_printer_parts_step.ended?).must_equal true
              end
            end
          end
        end
      end
    end

    describe EventBasedGateway do
      let(:source) { fixture_source('event_based_gateway_test.bpmn') }
      let(:context) { Processable::Context.new(sources: source) }
      let(:process) { context.process_by_id('EventBasedGatewayTest') }
  
      describe :definition do
        let(:gateway) { process.element_by_id('EventBasedGateway') }
        let(:message_event) { process.element_by_id('MessageEvent') }
        let(:timer_event) { process.element_by_id('TimerEvent') }
        let(:end_message) { process.element_by_id('EndMessage') }
        let(:end_timer) { process.element_by_id('EndTimer') }
  
        it 'should parse the gateway' do
          _(gateway).wont_be_nil
          _(message_event).wont_be_nil
          _(timer_event).wont_be_nil
          _(end_message).wont_be_nil
          _(end_timer).wont_be_nil
        end
      end

      describe :execution do
        let(:execution) { @execution }
        let(:gateway_step) { execution.step_by_id('EventBasedGateway') }
        let(:message_event_step) { execution.step_by_id('MessageEvent') }
        let(:timer_event_step) { execution.step_by_id('TimerEvent') }
        let(:end_message_step) { execution.step_by_id('EndMessage') }
        let(:end_timer_step) { execution.step_by_id('EndTimer') }
        
        before { @execution = Processable::Execution.start(context: context, process_id: 'EventBasedGatewayTest') }

        it "should diverge at the event gateway" do
          _(gateway_step.ended?).must_equal true
          _(message_event_step.waiting?).must_equal true
          _(timer_event_step.waiting?).must_equal true
        end

        describe :event_occurs do
          before { message_event_step.invoke }

          it "should complete the process" do
            _(execution.ended?).must_equal true
            _(message_event_step.ended?).must_equal true
            _(timer_event_step.terminated?).must_equal true
            _(end_message_step.ended?).must_equal true
            _(end_timer_step).must_be_nil
          end
        end
      end
    end
  end
end