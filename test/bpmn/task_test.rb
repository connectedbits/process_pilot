# frozen_string_literal: true

require "test_helper"

module Bpmn

  describe Task do
    let(:source) { fixture_source("task_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definition do
      let(:process_definition) { context.process_by_id("TaskTest") }
      let(:task_definition) { process_definition.element_by_id("Task") }

      it "should parse the task" do
        _(task_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:task_activity) { process_instance.child_by_activity_id("Task") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "TaskTest") }

      it "should start the process" do
        _(process_instance.ended?).must_equal false
        _(task_activity.ended?).must_equal false
      end

      describe :signal do
        before { task_activity.signal }

        it "should end the process" do
          _(process_instance.ended?).must_equal true
          _(task_activity.ended?).must_equal true
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
      let(:process_definition) { context.process_by_id("ServiceTaskTest") }
      let(:service_task_definition) { process_definition.element_by_id("ServiceTask") }

      it "should parse the service task" do
        _(service_task_definition.topic).must_equal "do_it"
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:service_task_instance) { process_instance.child_by_activity_id("ServiceTask") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "ServiceTaskTest", variables: { name: "Eric" }) }

      it "should run the service task" do
        _(process_instance.ended?).must_equal true
        _(service_task_instance.ended?).must_equal true
        _(process_instance.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
        _(service_task_instance.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
      end

      describe :external_services do
        let(:context) { Processable::Context.new(sources: source, services: services, service_task_runner: nil) }

        before { @process_instance = Processable::Execution.start(context: context, process_id: "ServiceTaskTest", variables: { name: "Eric" })  }

        it "should not run the service task" do
          _(process_instance.ended?).must_equal false
          _(service_task_instance.ended?).must_equal false
        end
      end
    end
  end

  describe ScriptTask do
    let(:source) { fixture_source("script_task_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }

    describe :definition do
      let(:process_definition) { context.process_by_id("ScriptTaskTest") }
      let(:script_definition) { process_definition.element_by_id("ScriptTask") }

      it "should parse the script task" do
        _(script_definition).wont_be_nil
        _(script_definition.script).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:script_instance) { process_instance.child_by_activity_id("ScriptTask") }

      before { @process_instance = Processable::Execution.start(context: context, process_id: "ScriptTaskTest", variables: { name: "Eric" }) }

      it "should run the script task" do
        _(process_instance.ended?).must_equal true
        _(script_instance.ended?).must_equal true
        _(process_instance.variables["greeting"]).must_equal "Hello Eric"
        _(script_instance.variables["greeting"]).must_equal "Hello Eric"
      end
    end
  end

  # describe BusinessRuleTask do
  #   let(:bpmn_source) { fixture_source("business_rule_task_test.bpmn") }
  #   let(:dmn_source) { fixture_source("dish.dmn") }
  #   let(:context) { Processable::Context.new(sources: [bpmn_source, dmn_source]) }
  #   let(:process_definition) { context.process_by_id("BusinessRuleTaskTest") }

  #   describe :expression do
  #     describe :definition do
  #       let(:business_rule_definition) { process_definition.element_by_id("ExpressionBusinessRule") }

  #       it "should parse the business rule task" do
  #         _(business_rule_definition.expression).wont_be_nil
  #       end
  #     end

  #     describe :execution do
  #       let(:process_instance) { @process_instance }
  #       let(:business_rule_instance) { process_instance.child_by_activity_id("ExpressionBusinessRule") }

  #       before { @process_instance = Processable::Execution.start(context: context, process_id: "BusinessRuleTaskTest", start_event_id: "ExpressionStart", variables: { age: 57 }) }

  #       it "should run the business rule task" do
  #         _(process_instance.ended?).must_equal true
  #         _(business_rule_instance.ended?).must_equal true
  #         _(business_rule_instance.variables["senior"]).must_equal true
  #       end
  #     end
  #   end

  #   describe :dmn do
  #     describe :definition do
  #       let(:business_rule_definition) { process_definition.element_by_id("DmnBusinessRule") }

  #       it "should parse the business rule task" do
  #         _(business_rule_definition.decision_ref).wont_be_nil
  #       end
  #     end

  #     describe :execution do
  #       let(:process_instance) { @process_instance }
  #       let(:process_instance) { process_instance.child_by_activity_id("DmnBusinessRule") }

  #       before { @process_instance = Processable::Execution.start(context: context, process_id: "BusinessRuleTaskTest", start_event_id: "DMNStart", variables: { season: "Spring", guests: 7 }) }

  #       it "should run the business rule task" do
  #         _(process_instance.ended?).must_equal true
  #         _(process_instance.ended?).must_equal true
  #         _(process_instance.variables["result"]["dish"]).must_equal "Steak"
  #       end
  #     end
  #   end
  # end
end
