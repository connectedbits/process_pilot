require "test_helper"

module Bpmn
  describe Builder do
    let(:source) { fixture_source('boundary_event_test.bpmn') }
    let(:moddle) { ProcessableServices::ProcessReader.call(source) }
    let(:runtime) { Builder.new(moddle) }
    let(:process) { runtime.process_by_id('BoundaryEventTest') }

    it 'should parse the process' do
      #File.write('moddle.json', moddle.to_json)
      _(process).wont_be_nil
    end
  end
end