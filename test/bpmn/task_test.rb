require "test_helper"

module Bpmn

  describe Task do
    let(:source) { fixture_source('task_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('TaskTest') }

    describe :definition do
      let(:task) { process.element_by_id('Task') }

      it 'should parse the task' do
        _(task).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:task_step) { execution.step_by_id('Task') }

      before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'TaskTest') }

      it 'should start the process' do
        _(execution.started?).must_equal true
        _(task_step.waiting?).must_equal true
      end

      describe :invoke do
        before { task_step.invoke }

        it 'should end the process' do
          _(execution.ended?).must_equal true
          _(task_step.ended?).must_equal true
        end
      end
    end
  end

  describe UserTask do
    # Behaves like Task ATM
  end

  describe ServiceTask do
    let(:source) { fixture_source('service_task_test.bpmn') }
    let(:services) { { do_it: proc { |variables| "👋 Hello #{variables['name']}, from ServiceTask!" } } }
    let(:context) { Processable::Context.new(sources: source, services: services) }
    let(:process) { context.process_by_id('ServiceTaskTest') }

    describe :definition do
      let(:service_task) { process.element_by_id('ServiceTask') }

      it 'should parse the service task' do
        _(service_task).wont_be_nil
        _(service_task.topic).must_equal 'do_it'
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:service_step) { execution.step_by_id('ServiceTask') }

      before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'ServiceTaskTest', variables: { name: "Eric" }) } 

      it 'should run the service task' do
        _(execution.ended?).must_equal true
        _(service_step.ended?).must_equal true
        _(execution.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
        _(service_step.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
      end

      describe :async_services do
        let(:context) { Processable::Context.new(sources: source, services: services, async_services: true) }

        before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'ServiceTaskTest', variables: { name: "Eric" })  }

        it 'should not run the service task' do
          _(execution.started?).must_equal true
          _(service_step.waiting?).must_equal true
        end
      end
    end
  end

  describe ScriptTask do
    let(:source) { fixture_source('script_task_test.bpmn') }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id('ScriptTaskTest') }

    describe :definition do
      let(:script_task) { process.element_by_id('ScriptTask') }

      it 'should parse the script task' do
        _(script_task).wont_be_nil
        _(script_task.script).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:script_step) { execution.step_by_id('ScriptTask') }

      before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'ScriptTaskTest', variables: { name: "Eric" }) }

      it 'should run the script task' do
        _(execution.ended?).must_equal true
        _(script_step.ended?).must_equal true
        _(execution.variables["greeting"]).must_equal "Hello Eric"
        _(script_step.variables["greeting"]).must_equal "Hello Eric"
      end
    end
  end

  describe BusinessRuleTask do
    let(:bpmn_source) { fixture_source('business_rule_task_test.bpmn') }
    let(:dmn_source) { fixture_source('dish.dmn') }
    let(:context) { Processable::Context.new(sources: [bpmn_source, dmn_source]) }
    let(:process) { context.process_by_id('BusinessRuleTaskTest') }

    describe :expression do
      describe :definition do
        let(:business_rule_task) { process.element_by_id('ExpressionBusinessRule') }
  
        it 'should parse the business rule task' do
          _(business_rule_task).wont_be_nil
          _(business_rule_task.expression).wont_be_nil
        end
      end
  
      describe :execution do
        let(:execution) { @execution }
        let(:business_rule_step) { execution.step_by_id('ExpressionBusinessRule') }
  
        before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'BusinessRuleTaskTest', start_event_id: 'ExpressionStart', variables: { age: 57 }) }
  
        it 'should run the business rule task' do
          _(execution.ended?).must_equal true
          _(business_rule_step.ended?).must_equal true
          _(business_rule_step.variables["senior"]).must_equal true
        end
      end
    end

    describe :dmn do
      describe :definition do
        let(:business_rule_task) { process.element_by_id('DmnBusinessRule') }
  
        it 'should parse the business rule task' do
          _(business_rule_task).wont_be_nil
          _(business_rule_task.decision_ref).wont_be_nil
        end
      end

      describe :execution do
        let(:execution) { @execution }
        let(:business_rule_step) { execution.step_by_id('DmnBusinessRule') }
  
        before { @execution = Processable::ProcessExecution.start(context: context, process_id: 'BusinessRuleTaskTest', start_event_id: 'DMNStart', variables: { season: "Spring", guests: 7 }) }
  
        it 'should run the business rule task' do
          _(execution.ended?).must_equal true
          _(business_rule_step.ended?).must_equal true
          _(business_rule_step.variables["result"]["dish"]).must_equal "Steak"
        end
      end
    end
  end
end