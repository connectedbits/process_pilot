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
      let(:start_timer) { process.element_by_id("StartTimer") }
      let(:intermediate_timer) { process.element_by_id("IntermediateTimer") }
      let(:boundary_timer) { process.element_by_id("BoundaryTimer") }
      let(:host_task) { process.element_by_id("HostTask") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the timers" do
        #_(start_timer.timer_event_definition).wont_be_nil
        _(intermediate_timer.timer_event_definition).wont_be_nil
        _(boundary_timer.timer_event_definition).wont_be_nil
      end
    end

    describe :execution do
      let(:process_instance) { @process_instance }
      let(:start_timer) { process_instance.step_by_id("StartTimer") }
      let(:intermediate_timer) { process_instance.step_by_id("IntermediateTimer") }
      let(:boundary_timer) { process_instance.step_by_id("BoundaryTimer") }
      let(:host_task) { process_instance.step_by_id("HostTask") }
      let(:end_event) { process_instance.step_by_id("End") }

      before { @process_instance = runtime.start_process('TimerEventDefinitionTest') }

      it "should wait at intermediate event and set the timer" do
        _(intermediate_timer.waiting?).must_equal true
        _(intermediate_timer.expires_at).wont_be_nil
      end

      describe :intermediate_timer do

        describe :boundary_timer do

        end
      end
    end
  end
end