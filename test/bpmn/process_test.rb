# frozen_string_literal: true

require "test_helper"

module Bpmn
  describe Process do
    let(:source) { fixture_source("process_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("ProcessTest") }

    describe :definition do
      let(:start_event) { process.element_by_id("Start") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the process" do
        _(process).wont_be_nil
        _(process.name).must_equal "Process Test"
        _(start_event).wont_be_nil
        _(end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.child_by_step_id("Start") }
      let(:end_event) { process.child_by_step_id("End") }

      before { @process = Processable::Execution.start(context: context, process_id: "ProcessTest", start_event_id: "Start") }

      it "should start and end the process" do
        _(process.completed?).must_equal true
        _(start_event.completed?).must_equal true
        _(end_event.completed?).must_equal true
      end
    end
  end

  describe CallActivity do
    let(:source) { fixture_source("call_activity_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:caller_process) { context.process_by_id("CallerProcess") }
    let(:callee_process) { context.process_by_id("CalleeProcess") }

    describe :definition do
      let(:call_activity) { caller_process.element_by_id("CallActivity") }

      it "should parse the call activity" do
        _(call_activity).wont_be_nil
      end
    end

    describe :execution do
      let(:caller_process) { context.execution_by_step_id("CallerProcess") }
      let(:call_activity) { caller_process.child_by_step_id("CallActivity") }
      let(:callee_process) { call_activity.children.first }
      let(:task) { callee_process.child_by_step_id("Task") }

      before { Processable::Execution.start(context: context, process_id: "CallerProcess") }

      it "should call the process" do
        _(caller_process.started?).must_equal true
        _(call_activity.started?).must_equal true
        _(task.waiting?).must_equal true
        _(callee_process.parent).must_equal call_activity
      end

      describe :complete_called_process do
        before { task.signal }

        it "should continue the calling process" do
          _(task.completed?).must_equal true
          _(callee_process.completed?).must_equal true
          _(caller_process.completed?).must_equal true
        end
      end
    end
  end

  describe SubProcess do
    let(:source) { fixture_source("sub_process_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :embedded do
      let(:parent) { context.process_by_id("EmbeddedSubProcessParent") }
      let(:child) { context.process_by_id("EmbeddedSubProcess") }

      describe :definitions do
        it "should create a parent child relationship" do
          _(parent).wont_be_nil
          _(parent.sub_processes.present?).must_equal true
          _(parent.sub_processes.first.parent).must_equal parent
          _(child).wont_be_nil
          _(child.parent).must_equal parent
        end
      end

      describe :execution do
        let(:parent_process) { @parent_process }
        let(:child_process) { parent_process.child_by_step_id("EmbeddedSubProcess") }
        let(:task) { child_process.child_by_step_id("Task") }

        before { @parent_process = Processable::Execution.start(context: context, process_id: "EmbeddedSubProcessParent") }

        it "should call the child process" do
          _(parent_process.started?).must_equal true
          _(child_process.started?).must_equal true
          _(task.waiting?).must_equal true
        end

        describe :child_process_completes do

        end
      end
    end

    describe :event do

    end

    describe :ad_hoc do

    end
  end
end
