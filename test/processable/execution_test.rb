# frozen_string_literal: true

require "test_helper"

module Processable
  describe Execution do
    let(:source) { fixture_source("execution_test.bpmn") }
    let(:context) { Context.new(sources: source)  }

    describe :definition do
      let(:process_definition) { context.process_by_id("Process") }
      let(:start_definition) { process_definition.element_by_id("Start") }
      let(:task_definition) { process_definition.element_by_id("Task") }
      let(:end_definition) { process_definition.element_by_id("End") }
      let(:sub_process_definition) { context.process_by_id("SubProcess") }
      let(:sub_start_definition) { sub_process_definition.element_by_id("SubStart") }
      let(:sub_task_definition) { sub_process_definition.element_by_id("SubTask") }
      let(:sub_end_definition) { sub_process_definition.element_by_id("SubEnd") }

      it "should parse the process" do
        _(process_definition).wont_be_nil
        _(start_definition).wont_be_nil
        _(task_definition).wont_be_nil
        _(end_definition).wont_be_nil
        _(sub_process_definition).wont_be_nil
        _(sub_start_definition).wont_be_nil
        _(sub_task_definition).wont_be_nil
        _(sub_end_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:start_instance) { process_instance.child_by_activity_id("Start") }
      let(:task_instance) { process_instance.child_by_activity_id("Task") }
      let(:end_instance) { process_instance.child_by_activity_id("End") }
      let(:sub_process_instance) { process_instance.child_by_activity_id("SubProcess") }
      let(:sub_start_instance) { sub_process_instance.child_by_activity_id("SubStart") }
      let(:sub_task_instance) { sub_process_instance.child_by_activity_id("SubTask") }
      let(:sub_end_instance) { sub_process_instance.child_by_activity_id("SubEnd") }

      before { @process_instance = Execution.start(context: context, process_id: "Process") }

      it "should start the process" do
        _(process_instance.ended?).must_equal false
        _(start_instance.ended?).must_equal true
        _(task_instance.ended?).must_equal false
      end

      describe :signal do
        before { task_instance.signal }

        it "should start the sub process" do
          _(process_instance.ended?).must_equal false
          _(sub_process_instance).wont_be_nil
          _(sub_task_instance.ended?).must_equal false
        end

        describe :signal_sub do
          before { sub_task_instance.signal }

          it "should end the process" do
            _(process_instance.ended?).must_equal true
            _(sub_process_instance.ended?).must_equal true
          end
        end
      end

      describe :serialization do

      end
    end
  end
end
