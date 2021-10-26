require "test_helper"

module Bpmn
  describe ScriptTask do
    let(:bpmn_source) { fixture_source('business_rule_task_test.bpmn') }
    let(:dmn_source) { fixture_source('dish.dmn') }
    let(:runtime) { Processable::Runtime.new(sources: [bpmn_source, dmn_source]) }
    let(:process) { runtime.process_by_id('BusinessRuleTaskTest') }

    describe :definition do
      let(:business_rule_task) { process.element_by_id('BusinessRuleTask') }

      it 'should parse the business rule task' do
        _(business_rule_task).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:business_rule_task) { process_instance.step_by_id('BusinessRuleTask') }

      before { @process_instance = runtime.start_process('BusinessRuleTaskTest') }

      it 'should start the process' do
        _(process_instance.status).must_equal 'started'
        _(business_rule_task.status).must_equal 'waiting'
      end

      describe :invoke do
        before { business_rule_task.invoke(variables: { outcome: 'complete' }) }

        it 'should end the process' do
          _(process_instance.status).must_equal 'ended'
          _(business_rule_task.status).must_equal 'ended'
        end
      end
    end
  end
end