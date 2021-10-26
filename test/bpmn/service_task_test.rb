require "test_helper"

module Bpmn
  describe ServiceTask do
    let(:source) { fixture_source('service_task_test.bpmn') }
    let(:services) { { do_it: proc { |variables| "👋 Hello #{variables['name']}, from ServiceTask!" } } }
    let(:runtime) { Processable::Runtime.new(sources: source, services: services) }
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

      before { @process_instance = runtime.start_process('ServiceTaskTest', variables: { name: "Eric" }) }

      it 'should run the script task' do
        _(process_instance.status).must_equal 'ended'
        _(service_task.status).must_equal 'ended'
        _(process_instance.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
        _(service_task.variables["service_task"]).must_equal "👋 Hello Eric, from ServiceTask!"
      end
    end
  end
end