# frozen_string_literal: true
require "test_helper"

module ProcessableServices
  describe FeelEvaluator do
    let(:service) { FeelEvaluator }

    describe :literal do
      let(:expression) { "'myName'" }
      let(:variables) { {} }
      let(:result) { service.call(expression: expression, variables: variables) }

      it "should return string" do
        _(result).must_equal("myName")
      end
    end

    describe :variable do
      let(:expression) { "name" }
      let(:variables) { { name: "Eric" } }
      let(:result) { service.call(expression: expression, variables: variables) }

      it "should return variable" do
        _(result).must_equal("Eric")
      end
    end

    describe :arithmetic do
      let(:expression) { "a + b + c" }
      let(:variables) { { a: 3, b: -1, c: 10 } }
      let(:result) { service.call(expression: expression, variables: variables) }

      it "should do math" do
        _(result).must_equal(12)
      end
    end

    describe :string_joining do
      let(:expression) { '"a" + "b" + var' }
      let(:variables) { { var: "c" } }
      let(:result) { service.call(expression: expression, variables: variables) }

      it "should join" do
        _(result).must_equal("abc")
      end
    end

    describe :builtin_functions do
      let(:expression) { "upper case(name)" }
      let(:variables) { { name: "aBc123" } }
      let(:result) { service.call(expression: expression, variables: variables) }

      it "should upper case" do
        _(result).must_equal("ABC123")
      end
    end
  end
end
