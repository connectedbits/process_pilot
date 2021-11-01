require "test_helper"

module Bpmn
  describe ConditionalEventDefinition do
    let(:source) { fixture_source("conditional_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("ConditionalEventDefinitionTest") }
  end

  describe EscalationEventDefinition do
    let(:source) { fixture_source("escalation_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("EscalationEventDefinitionTest") }
  end

  describe ErrorEventDefinition do
    let(:source) { fixture_source("error_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("ErrorEventDefinitionTest") }
  end

  describe MessageEventDefinition do
    let(:source) { fixture_source("message_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("MessageEventDefinitionTest") }
  end

  describe SignalEventDefinition do
    let(:source) { fixture_source("signal_event_definition_test.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:process) { context.process_by_id("SignalEventDefinitionTest") }
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
