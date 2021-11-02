# frozen_string_literal: true

require "test_helper"

module Bpmn
  describe ErrorEventDefinition do
    let(:source) { fixture_source("error_event_definition_test.bpmn") }
    let(:services) {
      {
        book_reservation: proc { |step, variables|
          if variables["simulate_error"]
            step.error("Error_Unavailable", "Sold out!")
          else
            step.complete({ "reserved_at": Time.zone.now })
          end
        },
      }
    }
    let(:context) { Processable::Context.new(sources: source, services: services) }
    let(:process) { context.process_by_id("ErrorEventDefinitionTest") }

    describe :definitions do
      let(:start_step) { process.element_by_id("Start") }
      let(:service_task_step) { process.element_by_id("ServiceTask") }
      let(:error_step) { process.element_by_id("Error") }
      let(:end_step) { process.element_by_id("End") }
      let(:end_failed_step) { process.element_by_id("EndFailed") }

      it "should parse the terminate end event" do
        _(error_step.error_event_definition.present?).must_equal true
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_id("Start") }
      let(:service_task_step) { execution.step_by_id("ServiceTask") }
      let(:error_step) { execution.step_by_id("Error") }
      let(:end_step) { execution.step_by_id("End") }
      let(:end_failed_step) { execution.step_by_id("EndFailed") }

      before { @execution = Processable::Execution.start(context: context, process_id: "ErrorEventDefinitionTest", variables: { simulate_error: true }) }

      it "should throw and catch error" do
        _(execution.ended?).must_equal true
        _(service_task_step.terminated?).must_equal true
        _(end_step).must_be_nil
        _(end_failed_step.ended?).must_equal true
      end
    end
  end

  describe MessageEventDefinition do
    let(:source) { fixture_source("message_event_definition_test.bpmn") }
    let(:log) { @log }
    let(:listeners) {
      { message_thrown:  proc { |event| log.push event } }
    }
    let(:context) { Processable::Context.new(sources: source, listeners: listeners) }
    let(:process) { context.process_by_id("MessageEventDefinitionTest") }

    before { @log = [] }

    describe :definitions do
      let(:start_step) { process.element_by_id("Start") }
      let(:catch_step) { process.element_by_id("Catch") }
      let(:boundary_step) { process.element_by_id("Boundary") }
      let(:throw_step) { process.element_by_id("Throw") }
      let(:end_step) { process.element_by_id("End") }

      it "should parse the terminate end event" do
        _(start_step.message_event_definitions.present?).must_equal true
        _(catch_step.message_event_definitions.present?).must_equal true
        _(boundary_step.message_event_definitions.present?).must_equal true
        _(throw_step.message_event_definitions.present?).must_equal true
        _(end_step.message_event_definitions.present?).must_equal true
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_id("Start") }
      let(:catch_step) { execution.step_by_id("Catch") }
      let(:host_step) { execution.step_by_id("HostTask") }
      let(:boundary_step) { execution.step_by_id("Boundary") }
      let(:throw_step) { execution.step_by_id("Throw") }
      let(:end_step) { execution.step_by_id("End") }

      describe :start do
        let(:executions) { @executions }
        let(:execution) { @executions.first }
        let(:message_name) { "Message_Start" }

        before { @executions = Processable::Execution.start_with_message(context: context, message_name: message_name) }

        it "should return an array of matching executions" do
          _(executions.length).must_equal 1
          _(execution.started?).must_equal true
          _(catch_step.waiting?).must_equal true
        end

        describe :catch do
          before { execution.message_received("Message_Catch", variables: { "hello": "world" }) }

          it "should invoke the waiting step" do
            _(catch_step.ended?).must_equal true
            _(execution.variables["hello"]).must_equal "world"
            _(host_step.waiting?).must_equal true
          end

          describe :boundary do
            before { execution.message_received("Message_Boundary", variables: { "foo": "bar" }) }

            it "should terminate the host step" do
              _(boundary_step.ended?).must_equal true
              _(execution.variables["foo"]).must_equal "bar"
              _(host_step.terminated?).must_equal true
              _(end_step.ended?).must_equal true
            end
          end

          describe :throw do
            before { host_step.invoke }

            it "should throw a message" do
              _(execution.ended?).must_equal true
              _(host_step.ended?).must_equal true
              _(boundary_step.terminated?).must_equal true
              _(end_step.ended?).must_equal true
              _(log.length).must_equal 2
              _(log.first[:message_name]).must_equal "Message_Throw"
              _(log.last[:message_name]).must_equal "Message_End"
            end
          end
        end

        describe :no_matches do
          let(:message_name) { "Message_NoMatch" }

          it "should not start any executions" do
            _(executions.present?).must_equal false
          end
        end
      end
    end
  end

  describe TerminateEventDefinition do
    let(:source) { fixture_source("terminate_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("TerminateEventDefinitionTest") }

    describe :definitions do
      let(:end_terminated_step) { process.element_by_id("EndTerminated") }

      it "should parse the terminate end event" do
        _(end_terminated_step.terminate_event_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:start_step) { execution.step_by_id("Start") }
      let(:task_a_step) { execution.step_by_id("TaskA") }
      let(:task_b_step) { execution.step_by_id("TaskB") }
      let(:end_none_step) { execution.step_by_id("EndNone") }
      let(:end_terminated_step) { execution.step_by_id("EndTerminated") }

      before { @execution = Processable::Execution.start(context: context, process_id: "TerminateEventDefinitionTest") }

      it "should wait at two parallel tasks" do
        _(task_a_step.waiting?).must_equal true
        _(task_a_step.waiting?).must_equal true
      end

      describe :end_none do
        before { task_a_step.invoke }

        it "should complete the process normally" do
          _(execution.ended?).must_equal false
          _(task_a_step.ended?).must_equal true
          _(task_b_step.waiting?).must_equal true
          _(end_none_step.ended?).must_equal true
          _(end_terminated_step).must_be_nil
        end
      end

      describe :terminate_path do
        before { task_b_step.invoke }

        it "should complete the process normally" do
          _(execution.ended?).must_equal true
          _(task_a_step.terminated?).must_equal true
          _(task_b_step.ended?).must_equal true
          _(end_none_step).must_be_nil
          _(end_terminated_step.ended?).must_equal true
        end
      end
    end
  end

  describe TimerEventDefinition do
    let(:source) { fixture_source("timer_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("TimerEventDefinitionTest") }

    describe :definitions do
      let(:start_event) { process.element_by_id("Start") }
      let(:catch_event) { process.element_by_id("Catch") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the timers" do
        _(catch_event.timer_event_definition).wont_be_nil
        _(catch_event.timer_event_definition.time_duration).wont_be_nil
      end
    end

    describe :execution do
      let(:execution) { @execution }
      let(:catch_step) { execution.step_by_id("Catch") }

      before { @execution = Processable::Execution.start(context: context, process_id: "TimerEventDefinitionTest") }

      it "should wait at catch event and set the timer" do
        _(catch_step.waiting?).must_equal true
        _(catch_step.expires_at).wont_be_nil
      end

      describe :before_timer_expiration do
        before do
          Timecop.travel(15.seconds)
          execution.check_expired_timers
        end

        it "should still be waiting" do
          _(catch_step.waiting?).must_equal true
        end
      end

      describe :after_timer_expiration do
        before do
          Timecop.travel(35.seconds)
          execution.check_expired_timers
        end

        it "should end the process" do
          _(catch_step.expires_at < Time.now).must_equal true
          _(execution.ended?).must_equal true
          _(catch_step.ended?).must_equal true
        end
      end
    end
  end
end
