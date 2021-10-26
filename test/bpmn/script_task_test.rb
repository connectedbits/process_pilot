require "test_helper"

module Bpmn
  describe ScriptTask do
    let(:source) { fixture_source('script_task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ScriptTaskTest') }

    describe :definition do
      let(:script_task) { process.element_by_id('ScriptTask') }

      it 'should parse the script task' do
        _(script_task).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:script_task) { process_instance.step_by_id('ScriptTask') }

      before { @process_instance = runtime.start_process('ScriptTaskTest') }

      it 'should start the process' do
        _(process_instance.status).must_equal 'started'
        _(script_task.status).must_equal 'waiting'
      end

      describe :invoke do
        before { script_task.invoke(variables: { outcome: 'complete' }) }

        it 'should end the process' do
          _(process_instance.status).must_equal 'ended'
          _(script_task.status).must_equal 'ended'
        end
      end
    end
  end
end