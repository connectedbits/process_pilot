require "test_helper"

module Bpmn
  describe StartEvent do
    let(:source) { fixture_source('start_event_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('StartEventTest') }

    describe :definitions do
      let(:start_event) { process.element_by_id("Start") }

      it "should parse start events" do
        _(start_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:start_event) { process_instance.step_by_id("Start") }

      before { @process_instance = runtime.start_process('StartEventTest') }

      it 'should start the process' do
        _(process_instance.ended?).must_equal true
        _(start_event.ended?).must_equal true
      end
    end
  end

  describe IntermediateCatchEvent do
    let(:source) { fixture_source('intermediate_catch_event_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('IntermediateCatchEventTest') }

    describe :definitions do
      let(:catch_event) { process.element_by_id("Catch") }
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:catch_event) { process_instance.step_by_id("Catch") }

      before { @process_instance = runtime.start_process('IntermediateCatchEventTest') }
      it 'should wait at the catch event' do
        _(process_instance.started?).must_equal true
        _(catch_event.waiting?).must_equal true
      end

      describe :invoke do
        before { catch_event.invoke }

        it 'should end the process' do
          _(process_instance.ended?).must_equal true
          _(catch_event.ended?).must_equal true
        end
      end
    end
  end

  describe IntermediateThrowEvent do
    let(:source) { fixture_source('intermediate_throw_event_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('IntermediateThrowEventTest') }

    describe :definitions do
      let(:throw_event) { process.element_by_id("Throw") }
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:throw_event) { process_instance.step_by_id("Throw") }

      before { @process_instance = runtime.start_process('IntermediateThrowEventTest') }
      it 'should throw then end the process' do
        _(process_instance.ended?).must_equal true
        _(throw_event.ended?).must_equal true
      end
    end
  end

  describe BoundaryEvent do
    let(:source) { fixture_source('boundary_event_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('BoundaryEventTest') }

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
      let(:process_instance) { @process_instance }
      let(:start) { process_instance.step_by_id("Start") }
      let(:host_task) { process_instance.step_by_id("HostTask") }
      let(:non_interrupting) { process_instance.step_by_id("NonInterrupting") }
      let(:interrupting) { process_instance.step_by_id("Interrupting") }
      let(:end) { process_instance.step_by_id("End") }
      let(:end_interrupted) { process_instance.step_by_id("EndInterrupted") }

      before { @process_instance = runtime.start_process('BoundaryEventTest') }

      it "should create boundary events" do
        _(process_instance.status).must_equal "started"
        _(host_task.status).must_equal "waiting"
        _(non_interrupting).wont_be_nil
        _(interrupting).wont_be_nil
      end

      describe :happy_path do
        before { host_task.invoke }

        it "should complete the process" do
          _(process_instance.status).must_equal "ended"
          _(host_task.status).must_equal "ended"
          _(non_interrupting.status).must_equal "terminated"
          _(interrupting.status).must_equal "terminated"
        end
      end

      describe :non_interrupting do
        before { non_interrupting.invoke }

        it "should not terminate host task" do
          _(process_instance.status).must_equal "started"
          _(host_task.status).must_equal "waiting"
          _(non_interrupting.status).must_equal "ended"
          _(interrupting.status).must_equal "waiting"
        end
      end

      describe :interrupting do
        before { interrupting.invoke }

        it "should terminate host task" do
          _(process_instance.status).must_equal "ended"
          _(host_task.status).must_equal "terminated"
          _(non_interrupting.status).must_equal "terminated"
          _(interrupting.status).must_equal "ended"
        end
      end
    end
  end

  describe EndEvent do
    let(:source) { fixture_source('end_event_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('EndEventTest') }

    describe :definitions do
      let(:end_event) { process.element_by_id("End") }

      it "should parse start events" do
        _(end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:end_event) { process_instance.step_by_id("End") }

      before { @process_instance = runtime.start_process('EndEventTest') }

      it 'should end the process' do
        _(process_instance.status).must_equal 'ended'
        _(end_event.status).must_equal 'ended'
      end
    end
  end
end