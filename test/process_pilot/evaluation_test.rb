# frozen_string_literal: true

require "test_helper"

module ProcessPilot

  describe Evaluation do
    describe :introduce_yourself do
      let(:source) { fixture_source("choose_greeting.dmn") }
      let(:context) { Context.new(sources: source) }
      let(:decision) { context.decision_by_id("ChooseGreeting") }

      describe :definition do
        it "should parse the decision" do
          _(decision).wont_be_nil
        end
      end

      describe :evaluate do
        let(:evaluation) { Evaluation.new(context) }
        let(:output) { evaluation.evaluate("ChooseGreeting", with:) }

        describe :scenario_1 do
          let(:with) { { language: "it", formal: false } }

          it "should make the correct decision" do
            _(output).must_equal({ "greeting" => "Ciao" })
          end
        end

        describe :scenario_2 do
          let(:with) { { language: "ja", formal: true } }

          it "should make the correct decision" do
            _(output).must_equal({ "greeting" => "Konnichiwa" })
          end
        end

        describe :scenario_3 do
          let(:with) { { language: "xx", formal: false } }

          it "should make the correct decision" do
            _(output).must_be_nil
          end
        end
      end
    end

    describe :dish do
      let(:source) { fixture_source("dish.dmn") }
      let(:context) { Context.new(sources: source) }
      let(:decision) { context.decision_by_id("Dish") }

      describe :definition do
        it "should parse the decision" do
          _(decision).wont_be_nil
        end
      end

      describe :evaluate do
        let(:evaluation) { Evaluation.new(context) }
        let(:output) { evaluation.evaluate("Dish", with:) }

        describe :scenario_1 do
          let(:with) { { season: "Winter", guests: 7 } }

          it "should make the correct decision" do
            _(output).must_equal({ "dish" => "Roastbeef" })
          end
        end
      end
    end

    describe :fine do
      let(:source) { fixture_source("fine.dmn") }
      let(:context) { Context.new(sources: source) }
      let(:decision) { context.decision_by_id("Fine") }

      describe :definition do
        it "should parse the decision" do
          _(decision).wont_be_nil
        end
      end

      describe :evaluate do
        let(:evaluation) { Evaluation.new(context) }
        let(:output) { evaluation.evaluate("Fine", with:) }

        describe :scenario_1 do
          let(:with) { { violation: { type: "speed", speed_limit: 60, actual_speed: 100 } } }

          it "should make the correct decision" do
            _(output["points"]).must_equal 7
            _(output["amount"]).must_equal 1000
          end
        end
      end
    end
  end
end
