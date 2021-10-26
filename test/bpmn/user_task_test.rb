require "test_helper"

module Bpmn
  describe Task do
    let(:source) { fixture_source('user_task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('UserTaskTest') }

    describe :definition do
      let(:user_task) { process.element_by_id('UserTask') }

      it 'should parse the user task' do
        _(user_task).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:user_task) { process_instance.step_by_id('UserTask') }

      before { @process_instance = runtime.start_process('UserTaskTest') }

      it 'should start the process' do
        _(process_instance.status).must_equal 'started'
        _(user_task.status).must_equal 'waiting'
      end

      describe :invoke do
        before { user_task.invoke(variables: { outcome: 'complete' }) }

        it 'should end the process' do
          _(process_instance.status).must_equal 'ended'
          _(user_task.status).must_equal 'ended'
        end
      end
    end
  end
end