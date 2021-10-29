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
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_id('Start') }
      let(:end_step) { execution.step_by_id('End') }

      before { @execution = runtime.start_process('ProcessTest', start_event_id: 'Start') }

      it 'should start and end the process' do
        _(execution.ended?).must_equal true
        _(start_step.ended?).must_equal true
        _(end_step.ended?).must_equal true
      end
    end
  end

  describe CallActivity do
  end

  describe SubProcess do
  end
end