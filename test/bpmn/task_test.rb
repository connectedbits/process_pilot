require "test_helper"

module Bpmn
  describe Task do
    let(:source) { fixture_source('task_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('TaskTest') }

    describe :definition do
      let(:task) { process.element_by_id('Task') }

      it 'should parse the process' do
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
          process_instance.print
          _(process_instance.status).must_equal 'ended'
          _(task.status).must_equal 'ended'
        end
      end
    end
  end
end