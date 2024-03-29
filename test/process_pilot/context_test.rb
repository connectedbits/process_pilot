# frozen_string_literal: true

require "test_helper"

module ProcessPilot
  describe Context do
    describe :listeners do
      let(:source) { fixture_source("execution_test.bpmn") }
      let(:listeners) {
        {
          started:  proc { |event| log.push event },
          waited:   proc { |event| log.push event },
          ended:    proc { |event| log.push event },
          taken:    proc { |event| log.push event },
          thrown:   proc { |event| log.push event },
        }
      }
      let(:context) { Context.new(sources: source, listeners: listeners) }
      let(:log) { @log }
      let(:last)

      before do
        @log = []
        @process = ProcessPilot.new(fixture_source("execution_test.bpmn"), listeners: listeners).start
      end

      it "should call the listener" do
        _(log.last[:event]).must_equal :waited
      end
    end
  end
end
