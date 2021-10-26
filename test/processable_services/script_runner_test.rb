require "test_helper"

module ProcessableServices
  describe ScriptRunner do
    let(:service) { ScriptRunner }

    describe :simple do
      let(:script) { "2 + 2" }
      let(:result) { service.call(script) }

      it "should eval the script correctly" do
        _(result).must_equal 4
      end
    end

    describe :utils do
      let(:script) { "`Hello ${reverse(data.name)} (${context.env})`" }
      let(:data) { { name: "Eric" } }
      let(:context) { { env: Rails.env } }
      let(:utils) {
        { 'reverse': proc { |input| input.reverse } }
      }
      let(:result) { service.call(script, data: data, context: context, utils: utils) }

      it "should eval the script correctly" do
        _(result).must_equal "Hello cirE (test)"
      end
    end
  end
end
