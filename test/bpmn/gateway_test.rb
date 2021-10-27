require "test_helper"

module Bpmn

  describe ExclusiveGateway do
    let(:source) { fixture_source('exclusive_gateway_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ExclusiveGatewayTest') }

    describe :definition do
      let(:exclusive_gateway) { process.element_by_id('ExclusiveGateway') }

      it 'should parse the gateway' do
        _(exclusive_gateway).wont_be_nil
        _(exclusive_gateway.default).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:exclusive_gateway) { process_instance.step_by_id('ExclusiveGateway') }
      let(:end_ok) { process_instance.step_by_id('EndOK') }
      let(:end_not_ok) { process_instance.step_by_id('EndNotOK') }
      let(:end_default) { process_instance.step_by_id('EndDefault') }

      describe :happy_path do
        before { @process_instance = runtime.start_process('ExclusiveGatewayTest', variables: { action: "ok" }) }

        it "should complete ok" do
          _(process_instance.status).must_equal "ended"
          _(end_ok).wont_be_nil
          _(end_not_ok).must_be_nil
          _(end_default).must_be_nil
        end
      end

      describe :default_path do
        before { @process_instance = runtime.start_process('ExclusiveGatewayTest', variables: { action: '¯\_(ツ)_/¯' }) }

        it "should complete ok" do
          _(process_instance.status).must_equal "ended"
          _(end_ok).must_be_nil
          _(end_not_ok).must_be_nil
          _(end_default).wont_be_nil
        end
      end
    end
  end

  describe ParallelGateway do
    let(:source) { fixture_source('parallel_gateway_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ParallelGatewayTest') }

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
      let(:process_instance) { @process_instance }
      let(:split) { process_instance.step_by_id('Split') }
      let(:join) { process_instance.step_by_id('Join') }
      let(:task_a) { process_instance.step_by_id('TaskA') }
      let(:task_b) { process_instance.step_by_id('TaskB') }

      before { @process_instance = runtime.start_process('ParallelGatewayTest') }

      it "should diverge at the first gateway" do
        _(split.status).must_equal "ended"
        _(join).must_be_nil
        _(process_instance.steps.count).must_equal 4
      end

      describe :converging do
        before { task_a.invoke }

        it "should wait when first token arrives" do
          _(task_a.status).must_equal "ended"
          _(task_b.status).must_equal "waiting"
          _(join.status).must_equal "waiting"
        end

        describe :join do
          before { task_b.invoke }

          it "should continue from join gateway" do
            _(process_instance.status).must_equal "ended"
            _(task_a.status).must_equal "ended"
            _(task_b.status).must_equal "ended"
            _(join.status).must_equal "ended"
          end
        end
      end
    end

    describe InclusiveGateway do
      let(:source) { fixture_source('inclusive_gateway_test.bpmn') }
      let(:runtime) { Processable::Runtime.new(sources: source) }
      let(:process) { runtime.process_by_id('InclusiveGatewayTest') }
  
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
        let(:process_instance) { @process_instance }
        let(:split) { process_instance.step_by_id('Split') }
        let(:join) { process_instance.step_by_id('Join') }
        let(:receive_order) { process_instance.step_by_id('ReceiveOrder') }
        let(:check_laptop_parts) { process_instance.step_by_id('CheckLaptopParts') }
        let(:check_prices) { process_instance.step_by_id('CheckPrices') }
        let(:check_printer_parts) { process_instance.step_by_id('CheckPrinterParts') }
    
        before { @process_instance = runtime.start_process('InclusiveGatewayTest') }

        it "should wait at receive order task" do
          _(receive_order.status).must_equal "waiting"
        end

        describe :first_path do
          before { receive_order.invoke({ include_laptop_parts: true, include_printer_parts: false }) }

          it "should create correct task" do
            _(check_laptop_parts).wont_be_nil
            _(check_laptop_parts.status).must_equal 'waiting'
            _(check_printer_parts).must_be_nil
            _(check_prices).must_be_nil
          end
        end

        describe :second_path do
          before { receive_order.invoke({ include_laptop_parts: false, include_printer_parts: true }) }

          it "should create correct task" do
            _(check_laptop_parts).must_be_nil
            _(check_printer_parts).wont_be_nil
            _(check_prices).must_be_nil
          end
        end

        describe :default_path do
          before { receive_order.invoke({ include_laptop_parts: false, include_printer_parts: false }) }

          it "should create the default task" do
            _(check_laptop_parts).must_be_nil
            _(check_printer_parts).must_be_nil
            _(check_prices).wont_be_nil
          end
        end

        describe :multiple_paths do
          before { receive_order.invoke({ include_laptop_parts: true, include_printer_parts: true }) }

          it "should create the correct tasks" do
            _(check_laptop_parts).wont_be_nil
            _(check_printer_parts).wont_be_nil
            _(check_prices).must_be_nil
          end

          describe :resume_first do
            before { check_laptop_parts.invoke }

            it "should wait at join gateway" do
              _(check_laptop_parts.status).must_equal "ended"
              _(check_printer_parts.status).must_equal "waiting"
            end

            describe :resume_second do
              before { check_printer_parts.invoke }

              it "should complete the process" do
                _(process_instance.status).must_equal "ended"
                _(check_printer_parts.status).must_equal "ended"
              end
            end
          end
        end
      end
    end

    describe EventBasedGateway do
      let(:source) { fixture_source('event_based_gateway_test.bpmn') }
      let(:runtime) { Processable::Runtime.new(sources: source) }
      let(:process) { runtime.process_by_id('EventBasedGatewayTest') }
  
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
        let(:process_instance) { @process_instance }
        let(:gateway) { process_instance.step_by_id('EventBasedGateway') }
        let(:message_event) { process_instance.step_by_id('MessageEvent') }
        let(:timer_event) { process_instance.step_by_id('TimerEvent') }
        let(:end_message) { process_instance.step_by_id('EndMessage') }
        let(:end_timer) { process_instance.step_by_id('EndTimer') }
        
        before { @process_instance = runtime.start_process('EventBasedGatewayTest') }

        it "should diverge at the event gateway" do
          _(gateway.status).must_equal "ended"
          _(message_event.status).must_equal "waiting"
          _(timer_event.status).must_equal "waiting"
        end

        describe :event_occurs do
          before { message_event.invoke }

          it "should complete the process" do
            _(process_instance.status).must_equal "ended"
            _(message_event.status).must_equal "ended"
            _(timer_event.status).must_equal "terminated"
            _(end_message.status).must_equal "ended"
            _(end_timer).must_be_nil
          end
        end
      end
    end

  end
end