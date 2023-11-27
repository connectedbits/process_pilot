# frozen_string_literal: true

require "test_helper"

module Zeebe
  describe "Zeebe Extensions" do
    let(:bpmn_source) { fixture_source("zeebe_extensions_test.bpmn") }
    let(:dmn_source) { fixture_source("choose_greeting.dmn") }
    let(:services) {
      {
        tell_fortune: proc { |execution, variables|
          execution.signal({ greeting: [
            "Hard work pays off in the future. Laziness pays off now.",
            "You think it’s a secret, but they know.",
            "Don’t eat the paper.",
          ].sample })
        },
      }
    }
    let(:context) { Processable::Context.new(sources: [bpmn_source, dmn_source], services: services) }

    describe :definition do
      let(:process) { context.process_by_id("ZeebeExtensionsTest") }
      let(:start_event) { process.element_by_id("Start") }
      let(:user_task) { process.element_by_id("UserTask") }
      let(:business_rule_task) { process.element_by_id("BusinessRuleTask") }
      let(:service_task) { process.element_by_id("ServiceTask") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the process" do
        _(user_task).wont_be_nil
        _(business_rule_task).wont_be_nil
        _(service_task).wont_be_nil
      end
    end

    # describe :execution do
    #   let(:process) { @process }
    #   let(:introduce_yourself) { process.child_by_step_id("IntroduceYourself") }
    #   let(:times_up) { process.child_by_step_id("TimesUp") }

    #   before { @process = Execution.start(context: context, process_id: "HelloWorld", variables: { greet: true, cookie: true }) }

    #   it "should wait at introduce yourself task" do
    #     _(introduce_yourself.waiting?).must_equal true
    #     _(times_up.waiting?).must_equal true
    #   end

    #   describe :complete_introduce_yourself do
    #     before { introduce_yourself.signal({ name: "Eric", language: "it", formal: false, cookie: true }) }

    #     it "should wait at choose greeting and tell fortune tasks" do
    #       _(introduce_yourself.completed?).must_equal true
    #       _(process.waiting_automated_tasks.length).must_equal 2
    #     end

    #     describe :run_automated_tasks do
    #       before { process.run_automated_tasks }

    #       it "should complete the process" do
    #         # BUG?: We have to run this a second time because the automated task spawed another
    #         # automated task.
    #         # process.run_automated_tasks
    #         # _(process.completed?).must_equal true
    #         # _(process.variables["message"]).wont_be_nil
    #       end
    #     end
    #   end
    # end
  end
end
