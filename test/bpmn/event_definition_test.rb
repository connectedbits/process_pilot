# frozen_string_literal: true

require "test_helper"

module Bpmn
  describe ErrorEventDefinition do
    let(:source) { fixture_source("error_event_definition_test.bpmn") }
    let(:services) {
      {
        book_reservation: proc { |execution, variables|
          if variables["simulate_error"]
            execution.parent.throw_error("Error_Unavailable")
          else
            execution.signal({ "reserved_at": Time.zone.now })
          end
        },
      }
    }
    let(:context) { Processable::Context.new(sources: source, services: services) }
    let(:process) { context.process_by_id("ErrorEventDefinitionTest") }

    describe :definitions do
      let(:start_event) { process.element_by_id("Start") }
      let(:service_task) { process.element_by_id("ServiceTask") }
      let(:error_event) { process.element_by_id("Error") }
      let(:end_event) { process.element_by_id("End") }
      let(:end_failed_event) { process.element_by_id("EndFailed") }

      it "should parse the terminate end event" do
        _(error_event.error_event_definition.present?).must_equal true
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.child_by_step_id("Start") }
      let(:service_task) { process.child_by_step_id("ServiceTask") }
      let(:error_event) { process.child_by_step_id("Error") }
      let(:end_event) { process.child_by_step_id("End") }
      let(:end_failed_event) { process.child_by_step_id("EndFailed") }

      before { @process = Processable::Execution.start(context: context, process_id: "ErrorEventDefinitionTest", variables: { simulate_error: true }) }

      it "should wait at the service task" do
        _(service_task.waiting?).must_equal true
      end

      describe :run_service do
        before { process.run_automated_tasks }

        it "should throw and catch error" do
          _(process.ended?).must_equal true
          _(service_task.terminated?).must_equal true
          _(end_event).must_be_nil
          _(end_failed_event.ended?).must_equal true
        end
      end
    end
  end

  describe MessageEventDefinition do
    let(:source) { fixture_source("message_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("MessageEventDefinitionTest") }

    before { @log = [] }

    describe :definitions do
      let(:start_event) { process.element_by_id("Start") }
      let(:catch_event) { process.element_by_id("Catch") }
      let(:host_task) { process.element_by_id("HostTask") }
      let(:boundary_event) { process.element_by_id("Boundary") }
      let(:throw_event) { process.element_by_id("Throw") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the terminate end event" do
        _(start_event.message_event_definitions.present?).must_equal true
        _(catch_event.message_event_definitions.present?).must_equal true
        _(boundary_event.message_event_definitions.present?).must_equal true
        _(throw_event.message_event_definitions.present?).must_equal true
        _(end_event.message_event_definitions.present?).must_equal true
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.child_by_step_id("Start") }
      let(:catch_event) { process.child_by_step_id("Catch") }
      let(:host_task) { process.child_by_step_id("HostTask") }
      let(:boundary_event) { process.child_by_step_id("Boundary") }
      let(:throw_event) { process.child_by_step_id("Throw") }
      let(:end_event) { process.child_by_step_id("End") }

      describe :start do
        let(:processes) { @processes }
        let(:process) { @processes.first }
        let(:message_name) { "Message_Start" }

        before { @processes = Processable::Execution.start_with_message(context: context, message_name: message_name) }

        it "should return an array of matching executions" do
          _(processes.length).must_equal 1
          _(process.started?).must_equal true
          _(catch_event.waiting?).must_equal true
        end

        describe :catch do
          before { process.throw_message("Message_Catch", variables: { "hello": "world" }) }

          it "should invoke the waiting step" do
            _(catch_event.ended?).must_equal true
            _(process.variables["hello"]).must_equal "world"
            _(host_task.waiting?).must_equal true
          end

          describe :boundary do
            before { process.throw_message("Message_Boundary", variables: { "foo": "bar" }) }

            it "should terminate the host step" do
              _(boundary_event.ended?).must_equal true
              _(process.variables["foo"]).must_equal "bar"
              _(host_task.terminated?).must_equal true
              _(end_event.ended?).must_equal true
            end
          end

          describe :throw do
            before { host_task.signal }

            it "should throw a message" do
              _(process.ended?).must_equal true
              _(host_task.ended?).must_equal true
              _(boundary_event.terminated?).must_equal true
              _(end_event.ended?).must_equal true
            end
          end
        end

        describe :no_matches do
          let(:message_name) { "Message_NoMatch" }

          it "should not start any executions" do
            _(processes.present?).must_equal false
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
      let(:end_terminated_event) { process.element_by_id("EndTerminated") }

      it "should parse the terminate end event" do
        _(end_terminated_event.terminate_event_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.step_by_element_id("Start") }
      let(:task_a) { process.child_by_step_id("TaskA") }
      let(:task_b) { process.child_by_step_id("TaskB") }
      let(:end_none_event) { process.child_by_step_id("EndNone") }
      let(:end_terminated_event) { process.child_by_step_id("EndTerminated") }

      before { @process = Processable::Execution.start(context: context, process_id: "TerminateEventDefinitionTest") }

      it "should wait at two parallel tasks" do
        _(task_a.waiting?).must_equal true
      end

      describe :end_none do
        before { task_a.signal }

        it "should complete the process normally" do
          _(process.completed?).must_equal true
          _(task_a.ended?).must_equal true
          _(task_b.terminated?).must_equal true
          _(end_none_event.completed?).must_equal true
          _(end_terminated_event).must_be_nil
        end
      end

      describe :terminate_path do
        before { task_b.signal }

        it "should complete the process normally" do
          _(process.ended?).must_equal true
          _(task_a.terminated?).must_equal true
          _(task_b.ended?).must_equal true
          _(end_none_event).must_be_nil
          _(end_terminated_event.ended?).must_equal true
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
      let(:process) { @process }
      let(:catch_event) { process.child_by_step_id("Catch") }

      before { @process = Processable::Execution.start(context: context, process_id: "TimerEventDefinitionTest") }

      it "should wait at catch event and set the timer" do
        _(catch_event.waiting?).must_equal true
        _(catch_event.timer_expires_at).wont_be_nil
      end

      describe :before_timer_expiration do
        before do
          travel 15.seconds
          process.check_expired_timers
        end

        it "should still be waiting" do
          _(catch_event.waiting?).must_equal true
        end
      end

      describe :after_timer_expiration do
        before do
          travel 35.seconds
          process.check_expired_timers
        end

        it "should end the process" do
          _(catch_event.timer_expires_at < Time.zone.now).must_equal true
          _(process.ended?).must_equal true
          _(catch_event.ended?).must_equal true
        end
      end
    end
  end
end
