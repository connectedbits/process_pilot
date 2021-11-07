# frozen_string_literal: true

require "test_helper"

module Processable
  describe Execution do
    let(:source) { fixture_source("execution_test.bpmn") }
    let(:context) { Context.new(sources: source) }

    describe :definition do
      let(:process) { context.process_by_id("Process") }
      let(:start_event) { process.element_by_id("Start") }
      let(:task) { process.element_by_id("Task") }
      let(:end_event) { process.element_by_id("End") }
      let(:sub_process) { context.process_by_id("SubProcess") }
      let(:sub_start_event) { sub_process.element_by_id("SubStart") }
      let(:sub_task) { sub_process.element_by_id("SubTask") }
      let(:sub_end_event) { sub_process.element_by_id("SubEnd") }

      it "should parse the process" do
        _(process).wont_be_nil
        _(start_event).wont_be_nil
        _(task).wont_be_nil
        _(end_event).wont_be_nil
        _(sub_process).wont_be_nil
        _(sub_start_event).wont_be_nil
        _(sub_task).wont_be_nil
        _(sub_end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.child_by_step_id("Start") }
      let(:task) { process.child_by_step_id("Task") }
      let(:end_event) { process.child_by_step_id("End") }
      let(:sub_process) { process.child_by_step_id("SubProcess") }
      let(:sub_start_event) { sub_process.child_by_step_id("SubStart") }
      let(:sub_task) { sub_process.child_by_step_id("SubTask") }
      let(:sub_end_event) { sub_process.child_by_step_id("SubEnd") }

      before { @process = Execution.start(context: context, process_id: "Process") }

      it "should start the process" do
        _(process.started?).must_equal true
        _(start_event.ended?).must_equal true
      end

      describe :signal do
        before { task.signal }

        it "should start the sub process" do
          _(sub_process.started?).must_equal true
          _(sub_task.waiting?).must_equal true
        end

        describe :signal_sub do
          before { sub_task.signal }

          it "should end the process" do
            _(process.ended?).must_equal true
            _(sub_process.ended?).must_equal true
            _(end_event).wont_be_nil
          end
        end
      end
    end

    # describe :serialization do
    #   let(:json) { @json }
    #   let(:new_execution) { @new_execution }

    #   before do
    #     @json = execution.to_json(include: :steps)
    #     @new_execution = Execution.deserialize(json, context: context)
    #   end

    #   it "should be lossless" do
    #     _(new_execution.serialize).must_equal(json)
    #   end

    #   describe :execution_after_serialization do
    #     let (:user_step) { new_execution.step_by_element_id("IntroduceYourself") }

    #     before { user_step.invoke(variables: { name: "Eric", language: "it", formal: false }) }

    #     it "should end the process" do
    #       _(new_execution.ended?).must_equal true
    #       _(user_step.ended?).must_equal true
    #     end
    #   end
    # end
  end
end
