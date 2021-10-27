require "test_helper"

module Bpmn

  describe Task do
    let(:source) { fixture_source('task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('TaskTest') }

    describe :definition do
      let(:task) { process.element_by_id('Task') }

      it 'should parse the task' do
        _(task).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:task) { process_instance.step_by_id('Task') }

      before { @process_instance = runtime.start_process('TaskTest') }

      it 'should start the process' do
        _(process_instance.status).must_equal 'started'
        _(task.status).must_equal 'waiting'
      end

      describe :invoke do
        before { task.invoke }

        it 'should end the process' do
          _(process_instance.status).must_equal 'ended'
          _(task.status).must_equal 'ended'
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
    let(:runtime) { Processable::Runtime.new(sources: source, services: services) }
    let(:process) { runtime.process_by_id('ServiceTaskTest') }

    describe :definition do
      let(:service_task) { process.element_by_id('ServiceTask') }

      it 'should parse the service task' do
        _(service_task).wont_be_nil
        _(service_task.topic).must_equal 'do_it'
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:service_task) { process_instance.step_by_id('ServiceTask') }

      before do 
        runtime.config.async_services = false
        @process_instance = runtime.start_process('ServiceTaskTest', variables: { name: "Eric" })
      end

      it 'should run the service task' do
        _(process_instance.status).must_equal 'ended'
        _(service_task.status).must_equal 'ended'
        _(process_instance.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
        _(service_task.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
      end

      describe :async_services do
        before do
          runtime.config.async_services = true
          @process_instance = runtime.start_process('ServiceTaskTest', variables: { name: "Eric" }) 
        end

        it 'should not run the service task' do
          _(process_instance.status).must_equal 'started'
          _(service_task.status).must_equal 'waiting'
        end
      end
    end
  end

  describe ScriptTask do
    let(:source) { fixture_source('script_task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ScriptTaskTest') }

    describe :definition do
      let(:script_task) { process.element_by_id('ScriptTask') }

      it 'should parse the script task' do
        _(script_task).wont_be_nil
        _(script_task.script).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:script_task) { process_instance.step_by_id('ScriptTask') }

      before do 
        runtime.config.async_scripts = false
        @process_instance = runtime.start_process('ScriptTaskTest', variables: { name: "Eric" })
      end

      it 'should run the script task' do
        _(process_instance.status).must_equal 'ended'
        _(script_task.status).must_equal 'ended'
        _(process_instance.variables["greeting"]).must_equal "Hello Eric"
        _(script_task.variables["greeting"]).must_equal "Hello Eric"
      end

      describe :async_scripts do
        before do
          runtime.config.async_scripts = true
          @process_instance = runtime.start_process('ScriptTaskTest', variables: { name: "Eric" }) 
        end

        it 'should not run the script task' do
          _(process_instance.status).must_equal 'started'
          _(script_task.status).must_equal 'waiting'
        end
      end
    end
  end

  describe BusinessRuleTask do
    let(:bpmn_source) { fixture_source('business_rule_task_test.bpmn') }
    let(:dmn_source) { fixture_source('dish.dmn') }
    let(:runtime) { Processable::Runtime.new(sources: [bpmn_source, dmn_source]) }
    let(:process) { runtime.process_by_id('BusinessRuleTaskTest') }

    describe :expression do
      describe :definition do
        let(:business_rule_task) { process.element_by_id('ExpressionBusinessRule') }
  
        it 'should parse the business rule task' do
          _(business_rule_task).wont_be_nil
          _(business_rule_task.expression).wont_be_nil
        end
      end
  
      describe :execution do
        let(:process_instance) { @process_instance }
        let(:business_rule_task) { process_instance.step_by_id('ExpressionBusinessRule') }
  
        before do
          runtime.config.async_business_rules = false
          @process_instance = runtime.start_process('BusinessRuleTaskTest', start_event_id: 'ExpressionStart', variables: { age: 57 })
        end
  
        it 'should run the business rule task' do
          _(process_instance.status).must_equal "ended"
          _(business_rule_task.status).must_equal "ended"
          _(business_rule_task.variables["senior"]).must_equal true
        end

        describe :async_business_rules do
          before do
            runtime.config.async_business_rules = true
            @process_instance = runtime.start_process('BusinessRuleTaskTest', start_event_id: 'ExpressionStart', variables: { age: 57 })
          end
  
          it 'should not run the business rule task' do
            _(process_instance.status).must_equal "started"
            _(business_rule_task.status).must_equal "waiting"
          end
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
        let(:process_instance) { @process_instance }
        let(:business_rule_task) { process_instance.step_by_id('DmnBusinessRule') }
  
        before do 
          runtime.config.async_business_rules = false
          @process_instance = runtime.start_process('BusinessRuleTaskTest', start_event_id: 'DMNStart', variables: { season: "Spring", guests: 7 })
        end
  
        it 'should run the business rule task' do
          _(process_instance.status).must_equal "ended"
          _(business_rule_task.status).must_equal "ended"
          _(business_rule_task.variables["result"]["dish"]).must_equal "Steak"
        end
      end
    end
  end
end