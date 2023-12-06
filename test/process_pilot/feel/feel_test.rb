# frozen_string_literal: true

require "test_helper"

module Feel
  describe :grammar_test do
    let(:feel) { Feel }

    describe :evaluate do
      it "should evaluate expressions" do
        _(Feel.evaluate('if 20 > 0 then "YES" else "NO"')).must_equal "YES"
        _(Feel.evaluate("37 + (1 + 2)")).must_equal 40
      end
    end

    describe :parsing do
      it "should return nil when no match is found" do
        _(feel.parse('2 cool 4 school')).must_be_nil
      end

      it "should not match inside valid strings" do
        _(feel.parse('" Hi now() "').eval).must_equal " Hi now() "
      end

      it "should evaluate context variables" do
        _(feel.parse("name").eval({ name: "Tom Brady" })).must_equal "Tom Brady"
      end
    end

    describe :values do
      it "should parse numbers" do
        _(feel.parse('47').eval).must_equal 47
        _(feel.parse('-9.123').eval).must_equal(-9.123)
        # TODO: _(feel.parse('1.2*10**3').eval).must_equal 1200
      end

      it "should parse strings" do
        _(feel.parse('"Hello World!"').eval).must_equal "Hello World!"
      end

      it "should parse dates" do
        _(feel.parse('date( "2017-06-23" )').eval).must_equal Date.new(2017, 6, 23)
        _(feel.parse('date( "2017-06-23" )').eval.year).must_equal 2017
        _(feel.parse('date( "2017-06-23" )').eval.month).must_equal 6
        _(feel.parse('date( "2017-06-23" )').eval.day).must_equal 23
      end

      it "should parse times" do
        _(feel.parse('time( "04:25:12" )').eval.hour).must_equal 4
        _(feel.parse('time( "04:25:12" )').eval.min).must_equal 25
        _(feel.parse('time( "04:25:12" )').eval.sec).must_equal 12
        _(feel.parse('time( "14:10:00+02:00" )').eval.class).must_equal Time
        _(feel.parse('time( "22:35:40.345-05:00" )').eval.class).must_equal Time
        _(feel.parse('time( "15:00:30z" )').eval.class).must_equal Time
        _(feel.parse('time( "09:30:00@Europe/Rome" )').eval.class).must_equal Time
      end

      it "should parse date and times" do
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.class).must_equal DateTime
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.year).must_equal 2017
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.month).must_equal 6
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.day).must_equal 23
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.hour).must_equal 4
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.min).must_equal 25
        _(feel.parse('date and time( "2017-06-23T04:25:12" )').eval.sec).must_equal 12
      end

      it "should parse day and time durations" do
        _(feel.parse('duration( "PT6H" )').eval.in_hours).must_equal 6
      end

      it "should parse functions" do
        # TODO: _(feel.parse('function(a, b) a + b').eval).wont_be_nil
      end

      it "should parse contexts (hashes)" do
        _(feel.parse('{ "a": 1, "b": 2 }').eval).must_equal({ "a" => 1, "b" => 2 })
      end

      it "should parse lists (arrays)" do
        _(feel.parse('[ 2, 3, 4, 5 ]').eval).must_equal [2, 3, 4, 5]
      end

      it "should parse ranges" do
        # TODO: _(feel.parse('( 2 .. 5 )').eval).must_equal(2..5)
      end
    end

    describe :expressions do
      it "should parse path expressions" do
        _(feel.parse("address.city").eval({ address: { city: "Boston" } })).must_equal "Boston"
      end

      describe :arithmetic do
        it "should parse addition" do
          _(feel.parse("1 + 1").eval).must_equal 2
          _(feel.parse("a + b").eval({ a: 30, b: 29 })).must_equal 59
        end

        it "should parse subtraction" do
          _(feel.parse("34 - 3").eval).must_equal 31
          _(feel.parse("a - b").eval({ a: 60, b: 1 })).must_equal 59
        end

        it "should parse multiplication" do
          _(feel.parse("6 * 10").eval).must_equal 60
          _(feel.parse("a * b").eval({ a: 4, b: 5 })).must_equal 20
        end

        it "should parse division" do
          _(feel.parse("10 / 2").eval).must_equal 5
          _(feel.parse("a / b").eval({ a: 16, b: 4 })).must_equal 4
        end
      end

      describe :comparison do
        it "should parse equality" do
          _(feel.parse("null = null").eval).must_equal true
          _(feel.parse("null = true").eval).must_equal false
          _(feel.parse("true = true").eval).must_equal true
          _(feel.parse("false = false").eval).must_equal true
          _(feel.parse("true = false").eval).must_equal false
          _(feel.parse('"hello" = "hello"').eval).must_equal true
          _(feel.parse('"hello" = greeting').eval({ greeting: "hello" })).must_equal true
        end

        it "should parse inequality" do
          _(feel.parse("null != null").eval).must_equal false
          _(feel.parse("null != true").eval).must_equal true
          _(feel.parse("true != true").eval).must_equal false
          _(feel.parse("false != false").eval).must_equal false
          _(feel.parse("true != false").eval).must_equal true
          _(feel.parse('"hello" != "hello"').eval).must_equal false
          _(feel.parse('"hello" != greeting').eval({ greeting: "hello" })).must_equal false
        end

        it "should parse negation" do
          _(feel.parse("not(true)").eval({ valid: true })).must_equal false
        end
      end

      describe :unary do
        it "should parse greater than" do 
          _(feel.parse("1 > 2").eval).must_equal false
          _(feel.parse("2 > 1").eval).must_equal true
        end

        it "should parse greater or equal to than" do
          _(feel.parse("1 >= 2").eval).must_equal false
          _(feel.parse("2 >= 1").eval).must_equal true
          _(feel.parse("2 >= 2").eval).must_equal true
        end

        it "should parse less than" do
          _(feel.parse("1 < 2").eval).must_equal true
          _(feel.parse("2 < 1").eval).must_equal false
        end

        it "should parse less than or equal to" do
          _(feel.parse("1 <= 2").eval).must_equal true
          _(feel.parse("2 <= 1").eval).must_equal false
          _(feel.parse("2 <= 2").eval).must_equal true
        end
      end

      describe :conjuction do
        it "should parse conjunctions" do
          _(feel.parse("true and true").eval).must_equal true
          _(feel.parse("false and false").eval).must_equal false
          _(feel.parse("true and false").eval).must_equal false
        end

        it "should parse disjunctions" do
          _(feel.parse("true or true").eval).must_equal true
          _(feel.parse("false or false").eval).must_equal false
          _(feel.parse("true or false").eval).must_equal true
        end
      end

      describe :string_concatenation do
        it "should parse string concatenation" do
          _(feel.parse('"Hello " + "World" + "!"').eval).must_equal "Hello World!"
        end
      end

      describe :flow_control do
        describe :if do
          it "should parse if then else" do
            _(feel.parse('if a > b then "YES" else "NO"').eval({ 'a': 20, 'b': 0 })).must_equal "YES"
            _(feel.parse('if a > b then "YES" else "NO"').eval({ 'a': 0, 'b': 20 })).must_equal "NO"
          end

          it "should return else when evaluating null" do
            # NOTE: If the condition c doesn't evaluate to a boolean value (e.g. null), it executes the expression b
            _(feel.parse('if null then "low" else "high"').eval).must_equal "high"
          end
        end

        describe :for do
          it "should parse for" do
            # TODO: _(feel.parse('for x in [1, 2, 3] return x * x').eval).must_equal [1, 4, 9]
          end
        end
      end

      describe :quantified do
        describe :some do

        end

        describe :every do

        end
      end

      describe :misc do
        # instance_of / in
      end
    end
  end

  describe :functions do
    let(:feel) { Feel }

    # https://kiegroup.github.io/dmn-feel-handbook/#string-functions
    describe :string do
      # it "should return the length of a string" do
      #   _(feel.parse('string length( "hello" )').eval).must_equal 5
      # end

      # it "should return a substring of a string" do
      #   _(feel.parse('substring( "hello", 1, 3 )').eval).must_equal "ell"
      # end

      # it "should return a string with leading and trailing whitespace removed" do
      #   _(feel.parse('trim( " hello " )').eval).must_equal "hello"
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('lowercase( "Hello" )').eval).must_equal "hello"
      # end

      # it "should return a string with all characters converted to uppercase" do
      #   _(feel.parse('uppercase( "Hello" )').eval).must_equal "HELLO"
      # end

      # it "should return a string with the first character converted to uppercase" do
      #   _(feel.parse('capitalize( "hello" )').eval).must_equal "Hello"
      # end

      # it "should return a string with the first character of each word converted to uppercase" do
      #   _(feel.parse('capitalize words( "hello world" )').eval).must_equal "Hello World"
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('substring before( "hello world", " " )').eval).must_equal "hello"
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('substring after( "hello world", " " )').eval).must_equal "world"
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('replace( "hello world", "hello", "goodbye" )').eval).must_equal "goodbye world"
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('contains( "hello world", "hello" )').eval).must_equal true
      # end

      # it "should return a string with all characters converted to lowercase" do
      #   _(feel.parse('starts with( "hello world", "hello" )').eval).must
      # end
    end

    # https://kiegroup.github.io/dmn-feel-handbook/#list-functions
    describe :list do

    end

    # https://kiegroup.github.io/dmn-feel-handbook/#numeric-functions
    describe :numeric do

    end

    # https://kiegroup.github.io/dmn-feel-handbook/#boolean-functions
    describe :boolean do

    end

    # https://kiegroup.github.io/dmn-feel-handbook/#date-and-time-functions
    # https://kiegroup.github.io/dmn-feel-handbook/#temporal-functions
    describe :temporal do
      it "should return the current time" do
        _(feel.parse('now()').eval.class).must_equal ActiveSupport::TimeWithZone
      end

      it "should return the current date" do
        _(feel.parse('today()').eval.class).must_equal Date
      end
    end

    # https://kiegroup.github.io/dmn-feel-handbook/#range-functions
    describe :range do

    end

    # https://kiegroup.github.io/dmn-feel-handbook/#sort-functions
    describe :sort do

    end

    # https://kiegroup.github.io/dmn-feel-handbook/#conversion-functions
    describe :conversion do

    end

    describe :extensions do

    end
  end
end
