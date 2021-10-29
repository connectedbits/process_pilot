require "test_helper"

module ProcessableServices
  describe ScriptRunner do
    let(:service) { ScriptRunner }

    describe :simple do
      let(:script) { "2 + 2" }
      let(:result) { service.call(script: script) }

      it "should eval the script correctly" do
        _(result).must_equal 4
      end
    end

    describe :utils do
      let(:script) { "`Hello ${reverse(variables.name)}`" }
      let(:variables) { { name: "Eric" } }
      let(:utils) {
        { 'reverse': proc { |input| input.reverse } }
      }
      let(:result) { service.call(script: script, variables: variables, utils: utils) }

      it "should eval the script correctly" do
        _(result).must_equal "Hello cirE"
      end
    end
  end
end
