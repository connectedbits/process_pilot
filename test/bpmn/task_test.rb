# frozen_string_literal: true

require "test_helper"

module Bpmn

  describe Task do
    let(:source) { fixture_source("task_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definition do
      let(:process) { context.process_by_id("TaskTest") }
      let(:task) { process.element_by_id("Task") }

      it "should parse the task" do
        _(task).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:task) { process.child_by_step_id("Task") }

      before { @process = Processable::Execution.start(context: context, process_id: "TaskTest") }

      it "should start the process" do
        _(process.running?).must_equal true
        _(task.waiting?).must_equal true
      end

      describe :signal do
        before { task.signal }

        it "should end the process" do
          _(process.completed?).must_equal true
          _(task.completed?).must_equal true
        end
      end
    end
  end

  describe UserTask do
    # Behaves like Task
  end

  describe ServiceTask do
    let(:source) { fixture_source("service_task_test.bpmn") }
    let(:services) { { do_it: proc { |execution, variables| execution.signal("👋 Hello #{variables['name']}, from ServiceTask!") } } }
    let(:context) { Processable::Context.new(sources: source, services: services) }

    describe :definition do
      let(:process) { context.process_by_id("ServiceTaskTest") }
      let(:service_task) { process.element_by_id("ServiceTask") }

      it "should parse the service task" do
        _(service_task.topic).must_equal "do_it"
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:service_task) { process.child_by_step_id("ServiceTask") }

      before { @process = Processable::Execution.start(context: context, process_id: "ServiceTaskTest", variables: { name: "Eric" }) }

      it "should run the service task" do
        _(process.completed?).must_equal true
        _(service_task.completed?).must_equal true
        _(process.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
        _(service_task.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
      end

      describe :external_services do
        let(:context) { Processable::Context.new(sources: source, services: services, service_task_runner: nil) }

        before { @process = Processable::Execution.start(context: context, process_id: "ServiceTaskTest", variables: { name: "Eric" })  }

        it "should not run the service task" do
          _(process.running?).must_equal true
          _(service_task.waiting?).must_equal true
        end
      end
    end
  end

  describe ScriptTask do
    let(:source) { fixture_source("script_task_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definition do
      let(:process) { context.process_by_id("ScriptTaskTest") }
      let(:script_task) { process.element_by_id("ScriptTask") }

      it "should parse the script task" do
        _(script_task.script).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:script_task) { process.child_by_step_id("ScriptTask") }

      before { @process = Processable::Execution.start(context: context, process_id: "ScriptTaskTest", variables: { name: "Eric" }) }

      it "should run the script task" do
        _(process.completed?).must_equal true
        _(script_task.completed?).must_equal true
        _(process.variables["greeting"]).must_equal "Hello Eric"
        _(script_task.variables["greeting"]).must_equal "Hello Eric"
      end
    end
  end

  describe BusinessRuleTask do
    let(:bpmn_source) { fixture_source("business_rule_task_test.bpmn") }
    let(:dmn_source) { fixture_source("dish.dmn") }
    let(:context) { Processable::Context.new(sources: [bpmn_source, dmn_source]) }
    let(:process) { context.process_by_id("BusinessRuleTaskTest") }

    describe :expression do
      describe :definition do
        let(:business_rule_task) { process.element_by_id("ExpressionBusinessRule") }

        it "should parse the business rule task" do
          _(business_rule_task.expression).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:business_rule_task) { process.child_by_step_id("ExpressionBusinessRule") }

        before { @process = Processable::Execution.start(context: context, process_id: "BusinessRuleTaskTest", start_event_id: "ExpressionStart", variables: { age: 57 }) }

        it "should run the business rule task" do
          _(process.completed?).must_equal true
          _(business_rule_task.completed?).must_equal true
          _(business_rule_task.variables["senior"]).must_equal true
        end
      end
    end

    describe :dmn do
      describe :definition do
        let(:business_rule_task) { process.element_by_id("DmnBusinessRule") }

        it "should parse the business rule task" do
          _(business_rule_task.decision_ref).wont_be_nil
        end
      end

      describe :execution do
        let(:process) { @process }
        let(:business_rule_task) { process.child_by_step_id("DmnBusinessRule") }

        before { @process = Processable::Execution.start(context: context, process_id: "BusinessRuleTaskTest", start_event_id: "DMNStart", variables: { season: "Spring", guests: 7 }) }

        it "should run the business rule task" do
          _(process.completed?).must_equal true
          _(business_rule_task.completed?).must_equal true
          _(business_rule_task.variables["result"]["dish"]).must_equal "Steak"
        end
      end
    end
  end
end
