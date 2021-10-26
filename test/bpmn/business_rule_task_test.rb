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


# # frozen_string_literal: true
# require "test_helper"

# module Bpmn
#   module Activities
#     describe BusinessRuleTask do
#       include ActiveJob::TestHelper

#       before do
#         create_deployment(["business_rule_task.bpmn", "dish.dmn"])
#       end

#       let(:process_definition) { process_definition_with_key("BusinessRuleTaskTest") }
#       let(:decision_definition) { decision_definition_with_key("Dish") }

#       describe :expression_rule do
#         let(:element) { process_definition.element_with_id("ExpressionBusinessRule") }

#         describe :definition do
#           it "should parse business rule task" do
#             _(element).wont_be_nil
#             _(element.expression).wont_be_nil
#             _(element.result_variable).wont_be_nil
#           end
#         end

#         describe :execution do
#           let(:process_instance) { @process_instance }

#           before do
#             perform_enqueued_jobs { @process_instance = process_definition.start(data: { expression: true, dmn: false, age: 57 }) }
#             process_instance.reload
#           end

#           let(:task) { node_with_id "ExpressionBusinessRule" }

#           it "should run business rule" do
#             _(process_instance.status).must_equal "completed"
#             _(task.status).must_equal "completed"
#             _(task.data["senior"]).must_equal true
#           end
#         end
#       end

#       describe :dmn_rule do
#         let(:element) { process_definition.definitions.element_with_id("DmnBusinessRule") }

#         describe :definition do
#           it "should parse business rule task" do
#             _(element).wont_be_nil
#             _(element.decision_ref).wont_be_nil
#           end
#         end

#         describe :execution do
#           let(:process_instance) { @process_instance }
#           let(:decision_definition) { decision_definition_with_key("dish") }

#           before do
#             perform_enqueued_jobs {  @process_instance = process_definition.start(data: { expression: false, dmn: true, season: "Spring", guests: 7 }) }
#             process_instance.reload
#           end

#           let(:item) { node_with_id "DmnBusinessRule" }

#           it "should run business rule" do
#             _(process_instance.status).must_equal "completed"
#             _(item.status).must_equal "completed"
#             _(item.data["result"]["dish"]).must_equal "Steak"
#           end
#         end
#       end
#     end
#   end
# end