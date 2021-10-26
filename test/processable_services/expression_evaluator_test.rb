require "test_helper"

module ProcessableServices
  describe ExpressionEvaluator do
    let(:service) { ExpressionEvaluator }

    describe :feel do
      let(:expression) { "person.age > 50" }

      it "truthy should be true" do
        result = service.call(expression, variables: { person: { age: 57 } })
        _(result).must_equal true
      end

      it "not truthy should be false" do
        result = service.call(expression, variables: { person: { age: 44 } })
        _(result).must_equal false
      end
    end

    describe :json_logic do
      let(:expression) { '{ ">": [{ "var": "person.age" }, 50] }' }

      it "truthy should be true" do
        result = service.call(expression, variables: { person: { age: 57 } })
        _(result).must_equal true
      end

      it "not truthy should be false" do
        result = service.call(expression, variables: { person: { age: 44 } })
        _(result).must_equal false
      end
    end
  end
end
