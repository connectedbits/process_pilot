require "test_helper"

module Bpmn
  describe Builder do
    let(:source) { fixture_source('process_test.bpmn') }
    let(:moddle) { ProcessableServices::ProcessReader.call(source) }
    let(:runtime) { Builder.new(moddle) }
    let(:process) { runtime.process_by_id('ProcessTest') }

    it 'should parse the process' do
      _(process).wont_be_nil
    end
  end
end