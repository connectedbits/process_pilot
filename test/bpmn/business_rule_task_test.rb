require "test_helper"

module Bpmn
  describe ScriptTask do
    let(:bpmn_source) { fixture_source('business_rule_task_test.bpmn') }
    let(:dmn_source) { fixture_source('dish.dmn') }
    let(:runtime) { Processable::Runtime.new(sources: [bpmn_source, dmn_source]) }
    let(:process) { runtime.process_by_id('BusinessRuleTaskTest') }

    describe :expression do
      describe :definition do
        let(:business_rule_task) { process.element_by_id('ExpressionBusinessRule') }
  
        it 'should parse the business rule task' do
          _(business_rule_task).wont_be_nil
        end
      end
  
      describe :execution do
        let(:process_instance) { @process_instance }
        let(:business_rule_task) { process_instance.step_by_id('ExpressionBusinessRule') }
  
        before { @process_instance = runtime.start_process('BusinessRuleTaskTest', start_event_id: 'ExpressionStart', variables: { age: 57 }) }
  
        it 'should run the business rule task' do
          _(process_instance.status).must_equal "ended"
          _(business_rule_task.status).must_equal "ended"
          _(business_rule_task.variables["senior"]).must_equal true
        end
      end
    end

    describe :dmn do
      describe :definition do
        let(:business_rule_task) { process.element_by_id('DmnBusinessRule') }
  
        it 'should parse the business rule task' do
          _(business_rule_task).wont_be_nil
        end
      end

      describe :execution do
        let(:process_instance) { @process_instance }
        let(:business_rule_task) { process_instance.step_by_id('DmnBusinessRule') }
  
        before { @process_instance = runtime.start_process('BusinessRuleTaskTest', start_event_id: 'DMNStart', variables: { season: "Spring", guests: 7 }) }
  
        it 'should run the business rule task' do
          _(process_instance.status).must_equal "ended"
          _(business_rule_task.status).must_equal "ended"
          _(business_rule_task.variables["result"]["dish"]).must_equal "Steak"
        end
      end
    end
  end
end