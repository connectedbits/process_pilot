require "test_helper"

module Bpmn
  describe ConditionalEventDefinition do
    let(:source) { fixture_source('conditional_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ConditionalEventDefinitionTest') }
  end

  describe EscalationEventDefinition do
    let(:source) { fixture_source('escalation_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('EscalationEventDefinitionTest') }
  end

  describe ErrorEventDefinition do
    let(:source) { fixture_source('error_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('ErrorEventDefinitionTest') }
  end

  describe MessageEventDefinition do
    let(:source) { fixture_source('message_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('MessageEventDefinitionTest') }
  end

  describe SignalEventDefinition do
    let(:source) { fixture_source('signal_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('SignalEventDefinitionTest') }
  end

  describe TerminateEventDefinition do
    let(:source) { fixture_source('terminate_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('TerminateEventDefinitionTest') }
  end

  describe TimerEventDefinition do
    let(:source) { fixture_source('timer_event_definition_test.bpmn') }
    let(:runtime) { Processable::Runtime.new(sources: source) }
    let(:process) { runtime.process_by_id('TimerEventDefinitionTest') }

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
      let(:process_instance) { @process_instance }
      let(:catch_event) { process_instance.step_by_id("Catch") }

      before { @process_instance = runtime.start_process('TimerEventDefinitionTest') }

      it "should wait at catch event and set the timer" do
        _(catch_event.waiting?).must_equal true
        _(catch_event.expires_at).wont_be_nil
      end

      describe :before_timer_expiration do
        before do 
          Timecop.travel(15.seconds)
          process_instance.check_expired_timers
        end

        it "should still be waiting" do
          _(catch_event.waiting?).must_equal true
        end
      end

      describe :after_timer_expiration do
        before do 
          Timecop.travel(35.seconds)
          process_instance.check_expired_timers
        end

        it "should end the process" do
          _(catch_event.expires_at < Time.now).must_equal true
          _(process_instance.ended?).must_equal true
          _(catch_event.ended?).must_equal true
        end
      end
    end
  end
end