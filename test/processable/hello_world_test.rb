# frozen_string_literal: true

require "test_helper"

module Processable
  describe "Hello World" do
    let(:bpmn_source) { fixture_source("hello_world.bpmn") }
    let(:dmn_source) { fixture_source("choose_greeting.dmn") }
    let(:services) {
      {
        tell_fortune: proc { |execution, variables|
          raise "Fortune not found? Abort, Retry, Ignore." if variables[:error]
          execution.signal([
            "The fortune you seek is in another cookie.",
            "A closed mouth gathers no feet.",
            "A conclusion is simply the place where you got tired of thinking.",
            "A cynic is only a frustrated optimist.",
            "A foolish man listens to his heart. A wise man listens to cookies.",
            "You will die alone and poorly dressed.",
            "A fanatic is one who can't change his mind, and won't change the subject.",
            "If you look back, you’ll soon be going that way.",
            "You will live long enough to open many fortune cookies.",
            "An alien of some sort will be appearing to you shortly.",
            "Do not mistake temptation for opportunity.",
            "Flattery will go far tonight.",
            "He who laughs at himself never runs out of things to laugh at.",
            "He who laughs last is laughing at you.",
            "He who throws dirt is losing ground.",
            "Some men dream of fortunes, others dream of cookies.",
            "The greatest danger could be your stupidity.",
            "We don’t know the future, but here’s a cookie.",
            "The world may be your oyster, but it doesn't mean you'll get its pearl.",
            "You will be hungry again in one hour.",
            "The road to riches is paved with homework.",
            "You can always find happiness at work on Friday.",
            "Actions speak louder than fortune cookies.",
            "Because of your melodic nature, the moonlight never misses an appointment.",
            "Don’t behave with cold manners.",
            "Don’t forget you are always on our minds.",
            "Help! I am being held prisoner in a fortune cookie factory.",
            "It’s about time I got out of that cookie.",
            "Never forget a friend. Especially if he owes you.",
            "Never wear your best pants when you go to fight for freedom.",
            "Only listen to the fortune cookie; disregard all other fortune telling units.",
            "It is a good day to have a good day.",
            "All fortunes are wrong except this one.",
            "Someone will invite you to a Karaoke party.",
            "That wasn’t chicken.",
            "There is no mistake so great as that of being always right.",
            "You love Chinese food.",
            "I am worth a fortune.",
            "No snowflake feels responsible in an avalanche.",
            "You will receive a fortune cookie.",
            "Some fortune cookies contain no fortune.",
            "Don’t let statistics do a number on you.",
            "You are not illiterate.",
            "May you someday be carbon neutral.",
            "You have rice in your teeth.",
            "Avoid taking unnecessary gambles. Lucky numbers: 12, 15, 23, 28, 37",
            "Ask your mom instead of a cookie.",
            "This cookie contains 117 calories.",
            "Hard work pays off in the future. Laziness pays off now.",
            "You think it’s a secret, but they know.",
            "If a turtle doesn’t have a shell, is it naked or homeless?",
            "Change is inevitable, except for vending machines.",
            "Don’t eat the paper.",
          ].sample)
        },
        say_hello: proc { |execution, variables|
          parts = []
          parts.push("👋 #{variables['greeting']}") if variables['greeting']
          parts.push(variables['name']) if variables['name']
          parts.push("🥠 #{variables['tell_fortune']}") if variables['tell_fortune']
          execution.signal({ message: parts.join(' ') })
        }
      }
    }
    let(:context) { Context.new(sources: [bpmn_source, dmn_source], services: services) }

    describe :definition do
      let(:process) { context.process_by_id("HelloWorld") }
      let(:introduce_yourself) { process.element_by_id("IntroduceYourself") }

      it "should parse the process" do
        _(introduce_yourself).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:introduce_yourself) { process.child_by_step_id("IntroduceYourself") }

      before { @process = Execution.start(context: context, process_id: "HelloWorld", variables: { greet: true, cookie: true }) }

      it "should wait at introduce yourself task" do
        _(introduce_yourself.waiting?).must_equal true
      end

      describe :complete_introduce_yourself do
        before { introduce_yourself.signal({ name: "Eric", language: "it", formal: false }) }

        it "should wait at choose greeting and tell fortune tasks" do
          _(introduce_yourself.completed?).must_equal true
          _(process.waiting_automated_tasks.length).must_equal 2
        end

        describe :run_automated_tasks do
          before { process.run_automated_tasks }

          it "should wait at the say hello task" do
            _(process.waiting_tasks.first.step.id).must_equal "SayHello"
          end

          describe :run_say_hello_task do
            before { process.run_automated_tasks }

            it "should complete the process" do
              _(process.completed?).must_equal true
              _(process.variables["message"]).wont_be_nil
            end
          end
        end
      end
    end
  end
end
