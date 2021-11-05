# frozen_string_literal: true

require "test_helper"

module Bpmn
  describe StartEvent do
    let(:source) { fixture_source("start_event_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definitions do
      let(:process_definition) { context.process_by_id("StartEventTest") }
      let(:start_definition) { process_definition.element_by_id("Start") }

      it "should parse start events" do
        _(start_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:start_instance) { process_instance.child_by_activity_id("Start") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "StartEventTest") }

      it "should start the process" do
        _(process_instance.ended?).must_equal true
        _(start_instance.ended?).must_equal true
      end
    end
  end

  describe IntermediateCatchEvent do
    let(:source) { fixture_source("intermediate_catch_event_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definitions do
      let(:process_definition) { context.process_by_id("IntermediateCatchEventTest") }
      let(:catch_instance) { process.element_by_id("Catch") }
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:catch_instance) { execution.child_by_activity_id("Catch") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "IntermediateCatchEventTest") }
      it "should wait at the catch event" do
        _(process_instance.ended?).must_equal false
        _(catch_instance.ended?).must_equal false
      end

      describe :signal do
        before { catch_step.signal }

        it "should end the process" do
          _(process_instance.ended?).must_equal true
          _(catch_instance.ended?).must_equal true
        end
      end
    end
  end

  describe IntermediateThrowEvent do
    let(:source) { fixture_source("intermediate_throw_event_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definitions do
      let(:process_definition) { context.process_by_id("IntermediateThrowEventTest") }
      let(:throw_event) { process.element_by_id("Throw") }
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:throw_instance) { process_instance.child_by_activity_id("Throw") }

      before { @execution = Processable::Execution.start(context: context, process_id: "IntermediateThrowEventTest") }

      it "should throw then end the process" do
        _(process_instance.ended?).must_equal true
        _(throw_instance.ended?).must_equal true
      end
    end
  end

  # describe BoundaryEvent do
  #   let(:source) { fixture_source("boundary_event_test.bpmn") }
  #   let(:context) { Processable::Context.new(sources: source) }

  #   describe :definitions do
  #     let(:process_definition) { context.process_by_id("BoundaryEventTest") }
  #     let(:start_definition) { process_definition.element_by_id("Start") }
  #     let(:host_task_definition) { process_definition.element_by_id("HostTask") }
  #     let(:non_interrupting_definition) { process_definition.element_by_id("NonInterrupting") }
  #     let(:interrupting_definition) { process_definition.element_by_id("Interrupting") }
  #     let(:end_definition) { process_definition.element_by_id("End") }
  #     let(:end_interrupted_definition) { process_definition.element_by_id("EndInterrupted") }

  #     it "should attach boundary to host" do
  #       _(host_task_definition.attachments.present?).must_equal true
  #       _(host_task_definition.attachments).must_equal [non_interrupting, interrupting]
  #     end
  #   end

  #   describe :execution do
  #     let(:process_instance) { @process_instance }
  #     let(:start_instance) { process_instance.child_by_activity_id("Start") }
  #     let(:host_task_instance) { process_instance.child_by_activity_id("HostTask") }
  #     let(:non_interrupting_instance) { process_instance.child_by_activity_id("NonInterrupting") }
  #     let(:interrupting_instance) { process_instance.child_by_activity_id("Interrupting") }
  #     let(:end_instance) { process_instance.child_by_activity_id("End") }
  #     let(:end_interrupted_instance) { process_instance.child_by_activity_id("EndInterrupted") }

  #     before { @process_instance = Processable::Execution.start(context: context, process_id: "BoundaryEventTest") }

  #     it "should create boundary events" do
  #       _(process_instance.ended?).must_equal false
  #       _(host_task_instance.ended?).must_equal false
  #       _(non_interrupting_instance).wont_be_nil
  #       _(interrupting_instance).wont_be_nil
  #     end

  #     describe :happy_path do
  #       before { host_task_instance.signal }

  #       it "should complete the process" do
  #         _(process_instance.ended?).must_equal true
  #         _(host_task_instance.ended?).must_equal true
  #         skip "TODO: implement terminated"
  #         _(non_interrupting_instance.terminated?).must_equal true
  #         _(interrupting_instance.terminated?).must_equal true
  #       end
  #     end

  #     describe :non_interrupting do
  #       before { non_interrupting_instance.signal }

  #       it "should not terminate host task" do
  #         _(process_instance.ended?).must_equal false
  #         _(host_task_instance.ended?).must_equal false
  #         _(non_interrupting_instance.ended?).must_equal true
  #         _(interrupting_instance.ended?).must_equal false
  #       end
  #     end

  #     describe :interrupting do
  #       before { interrupting_instance.signal }

  #       it "should terminate host task" do
  #         _(process_instance.ended?).must_equal true
  #         _(host_task_instance.terminated?).must_equal true
  #         _(non_interrupting_instance.terminated?).must_equal true
  #         _(interrupting_instance.ended?).must_equal true
  #       end
  #     end
  #   end
  # end

  describe EndEvent do
    let(:source) { fixture_source("end_event_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definitions do
      let(:process_definition) { context.process_by_id("EndEventTest") }
      let(:end_definition) { process_definition.element_by_id("End") }

      it "should parse start events" do
        _(end_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:end_instance) { process_instance.child_by_activity_id("End") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "EndEventTest") }

      it "should end the process" do
        _(process_instance.ended?).must_equal true
        _(end_instance.ended?).must_equal true
      end
    end
  end
end