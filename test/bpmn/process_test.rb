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
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_element_id("Start") }
      let(:end_step) { execution.step_by_element_id("End") }

      before { @execution = Processable::Execution.start(context: context, process_id: "ProcessTest", start_event_id: "Start") }

      it "should start and end the process" do
        _(execution.ended?).must_equal true
        _(start_step.ended?).must_equal true
        _(end_step.ended?).must_equal true
      end
    end
  end

  describe CallActivity do
    let(:source) { fixture_source("call_activity_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:caller) { context.process_by_id("CallerProcess") }
    let(:callee) { context.process_by_id("CalleeProcess") }

    describe :definition do
      let(:call_activity_step) { caller.element_by_id("CallActivity") }

      it "should parse the call activity" do
        _(call_activity_step).wont_be_nil
      end
    end

    describe :execution do
      let(:caller_execution) { context.execution_by_process_id("CallerProcess") }
      let(:callee_execution) { context.execution_by_process_id("CalleeProcess") }
      let(:call_step) { caller_execution.step_by_element_id("CallActivity") }
      let(:task_step) { callee_execution.step_by_element_id("Task") }

      before { Processable::Execution.start(context: context, process_id: "CallerProcess") }

      it "should call the process" do
        _(caller_execution.started?).must_equal true
        _(call_step.waiting?).must_equal true
        _(callee_execution).wont_be_nil
        _(task_step.waiting?).must_equal true
        _(callee_execution.parent_id).must_equal caller_execution.id
        _(callee_execution.called_by_id).must_equal call_step.id
        _(context.executions.map { |e| e.id }).must_equal [caller_execution.id, callee_execution.id]
        _(callee_execution.parent).must_equal caller_execution
        _(callee_execution.called_by).must_equal call_step
      end

      describe :complete_called_process do
        before { task_step.complete }

        it "should continue the calling process" do
          _(task_step.ended?).must_equal true
          _(callee_execution.ended?).must_equal true
          _(caller_execution.ended?).must_equal true
        end
      end
    end
  end

  describe SubProcess do
    let(:source) { fixture_source("call_activity_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :embedded do
      let(:parent) { context.process_by_id("EmbeddedSubProcessParent") }
      let(:child) { context.process_by_id("EmbeddedSubProcess") }

      describe :definitions do
        it "should create a parent child relationship" do

        end
      end

      describe :execution do
        it "should call the child process" do

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
