require "test_helper"

module Bpmn
  describe StartEvent do
    let(:source) { fixture_source('start_event_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('StartEventTest') }

    describe :definitions do
      let(:start_event) { process.element_by_id("Start") }

      it "should parse start events" do
        _(start_event).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_element_id("Start") }

      before { @execution = Processable::Execution.start(context: context, process_id: 'StartEventTest') }

      it 'should start the process' do
        _(execution.ended?).must_equal true
        _(start_step.ended?).must_equal true
      end
    end
  end

  describe IntermediateCatchEvent do
    let(:source) { fixture_source('intermediate_catch_event_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('IntermediateCatchEventTest') }

    describe :definitions do
      let(:catch_event) { process.element_by_id("Catch") }
    end

    describe :execution do
      let(:execution) { @execution }
      let(:catch_step) { execution.step_by_element_id("Catch") }

      before { @execution = Processable::Execution.start(context: context, process_id: 'IntermediateCatchEventTest') }
      it 'should wait at the catch event' do
        _(execution.started?).must_equal true
        _(catch_step.waiting?).must_equal true
      end

      describe :invoke do
        before { catch_step.invoke }

        it 'should end the process' do
          _(execution.ended?).must_equal true
          _(catch_step.ended?).must_equal true
        end
      end
    end
  end

  describe IntermediateThrowEvent do
    let(:source) { fixture_source('intermediate_throw_event_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('IntermediateThrowEventTest') }

    describe :definitions do
      let(:throw_event) { process.element_by_id("Throw") }
    end

    describe :execution do
      let(:execution) { @execution }
      let(:throw_step) { execution.step_by_element_id("Throw") }

      before { @execution = Processable::Execution.start(context: context, process_id: 'IntermediateThrowEventTest') }
      it 'should throw then end the process' do
        _(execution.ended?).must_equal true
        _(throw_step.ended?).must_equal true
      end
    end
  end

  describe BoundaryEvent do
    let(:source) { fixture_source('boundary_event_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('BoundaryEventTest') }

    describe :definitions do
      let(:start) { process.element_by_id("Start") }
      let(:host_task) { process.element_by_id("HostTask") }
      let(:non_interrupting) { process.element_by_id("NonInterrupting") }
      let(:interrupting) { process.element_by_id("Interrupting") }
      let(:end) { process.element_by_id("End") }
      let(:end_interrupted) { process.element_by_id("EndInterrupted") }

      it 'should attach boundary to host' do
        _(host_task.attachments.present?).must_equal true
        _(host_task.attachments).must_equal [non_interrupting, interrupting]
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_element_id("Start") }
      let(:host_task_step) { execution.step_by_element_id("HostTask") }
      let(:non_interrupting_step) { execution.step_by_element_id("NonInterrupting") }
      let(:interrupting_step) { execution.step_by_element_id("Interrupting") }
      let(:end_step) { execution.step_by_element_id("End") }
      let(:end_interrupted_step) { execution.step_by_element_id("EndInterrupted") }

      before { @execution = Processable::Execution.start(context: context, process_id: 'BoundaryEventTest') }

      it "should create boundary events" do
        _(execution.started?).must_equal true
        _(host_task_step.waiting?).must_equal true
        _(non_interrupting_step).wont_be_nil
        _(interrupting_step).wont_be_nil
      end

      describe :happy_path do
        before { host_task_step.invoke }

        it "should complete the process" do
          _(execution.ended?).must_equal true
          _(host_task_step.ended?).must_equal true
          _(non_interrupting_step.terminated?).must_equal true
          _(interrupting_step.terminated?).must_equal true
        end
      end

      describe :non_interrupting do
        before { non_interrupting_step.invoke }

        it "should not terminate host task" do
          _(execution.started?).must_equal true
          _(host_task_step.waiting?).must_equal true
          _(non_interrupting_step.ended?).must_equal true
          _(interrupting_step.waiting?).must_equal true
        end
      end

      describe :interrupting do
        before { interrupting_step.invoke }

        it "should terminate host task" do
          _(execution.ended?).must_equal true
          _(host_task_step.terminated?).must_equal true
          _(non_interrupting_step.terminated?).must_equal true
          _(interrupting_step.ended?).must_equal true
        end
      end
    end
  end

  describe EndEvent do
    let(:source) { fixture_source('end_event_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('EndEventTest') }

    describe :definitions do
      let(:end_event) { process.element_by_id("End") }

      it "should parse start events" do
        _(end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:end_step) { execution.step_by_element_id("End") }

      before { @execution = Processable::Execution.start(context: context, process_id: 'EndEventTest') }

      it 'should end the process' do
        _(execution.ended?).must_equal true
        _(end_step.ended?).must_equal true
      end
    end
  end
end