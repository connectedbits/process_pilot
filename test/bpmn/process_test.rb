require "test_helper"

module Bpmn
  describe Process do
    let(:source) { fixture_source('process_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ProcessTest') }

    describe :definition do
      let(:start_event) { process.element_by_id('Start') }
      let(:end_event) { process.element_by_id('End') }

      it 'should parse the process' do
        _(process).wont_be_nil
        _(process.name).must_equal 'Process Test'
        _(start_event).wont_be_nil
        _(end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:start_event) { process_instance.step_by_id('Start') }
      let(:end_event) { process_instance.step_by_id('End') }

      before { @process_instance = runtime.start_process('ProcessTest', start_event_id: 'Start') }

      it 'should start and end the process' do
        _(process_instance.status).must_equal 'ended'
        _(start_event.status).must_equal 'ended'
        _(end_event.status).must_equal 'ended'
      end
    end
  end
end