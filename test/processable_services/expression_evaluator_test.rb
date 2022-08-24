# frozen_string_literal: true
require "test_helper"

module ProcessableServices
  describe ExpressionEvaluator do
    let(:service) { ExpressionEvaluator }

    describe :feel do
      describe :val do
        let(:expression) { "person.name" }

        it "should evaluate expression" do
          result = service.call(expression: expression, variables: { person: { name: "Eric" } })
          _(result).must_equal "Eric"
        end
      end

      describe :test do
        it "should evaluate expression" do
          result = service.call(expression: "${ action = 'ok' }", variables: { action: "ok" })
          _(result).must_equal true
        end
      end

      describe :truthy do
        let(:expression) { "person.age > 50" }

        it "truthy should be true" do
          result = service.call(expression: expression, variables: { person: { age: 57 } })
          _(result).must_equal true
        end

        it "not truthy should be false" do
          result = service.call(expression: expression, variables: { person: { age: 44 } })
          _(result).must_equal false
        end
      end
    end

    describe :json_logic do
      let(:expression) { '{ ">": [{ "var": "person.age" }, 50] }' }

      it "truthy should be true" do
        result = service.call(expression: expression, variables: { person: { age: 57 } })
        _(result).must_equal true
      end

      it "not truthy should be false" do
        result = service.call(expression: expression, variables: { person: { age: 44 } })
        _(result).must_equal false
      end
    end
  end
end
