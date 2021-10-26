require "test_helper"

module Bpmn
  describe ServiceTask do
    let(:source) { fixture_source('service_task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ServiceTaskTest') }

    describe :definition do
      let(:service_task) { process.element_by_id('ServiceTask') }

      it 'should parse the service task' do
        _(service_task).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:service_task) { process_instance.step_by_id('ServiceTask') }

      before { @process_instance = runtime.start_process('ServiceTaskTest') }

      it 'should start the process' do
        _(process_instance.status).must_equal 'started'
        _(service_task.status).must_equal 'waiting'
      end

      describe :invoke do
        before { service_task.invoke(variables: { outcome: 'complete' }) }

        it 'should end the process' do
          _(process_instance.status).must_equal 'ended'
          _(service_task.status).must_equal 'ended'
        end
      end
    end
  end
end