# frozen_string_literal: true

require "test_helper"

module ProcessPilot
  describe :process_pilot do
    let(:process) { @process }

    describe :kiss do
      let(:waiting_task) { process.waiting_tasks.first }

      before { @process = ProcessPilot.new(fixture_source("hello_world.bpmn")).start }

      it "should wait at the task" do
        _(process.completed?).must_equal false
        _(waiting_task).wont_be_nil
      end

      describe :signaling do
        before { waiting_task.signal({ message: "Hello World!" }) }

        it "should complete the process" do
          _(process.completed?).must_equal true
        end
      end
    end

    describe :serialization do
      before { @process = ProcessPilot.new(fixture_source("hello_world.bpmn")).start; @serialized_state = process.serialize }

      it "should wait at the task" do
        _(process.completed?).must_equal false
      end

      describe :serialization do
        let(:serialized_state) { @serialized_state }

        before { @serialized_state = process.serialize }

        it "should serialize the process" do
          #puts serialized_state.inspect
          _(serialized_state).wont_be_nil
        end

        describe :deserialization do
          let (:waiting_step) { process.waiting_tasks.first }
          before { @process = ProcessPilot.new(fixture_source("hello_world.bpmn")).restore(serialized_state); }

          it "should be waiting" do
            _(waiting_step).wont_be_nil
          end

          describe :continue do
            before {  process.waiting_tasks.first.signal({ message: "Hello World!" }) }

            it "should complete the process" do
              _(process.completed?).must_equal true
            end
          end
        end
      end
    end

    describe :with_services do
      let(:services) {
        {
          say_hello: proc { |variables|
            { message: "Hello #{variables[:name]}!" }
          },
        }
      }

      before { @process = ProcessPilot.new(fixture_source("hello_world.bpmn"), services: services).start(variables: { name: "Eric" }) }

      it "should complete the process" do
        skip "TODO: Why isn't this working?"
        _(process.completed?).must_equal true
      end
    end

    describe :kitchen_sink do
      let(:introduce_yourself_step) { process..step_by_element_id("IntroduceYourself") }
      let(:select_greeting_step) { process..step_by_element_id("SelectGreeting") }
      let(:random_fortune_step) { process..step_by_element_id("RandomFortune") }
      let(:generate_message_step) { process..step_by_element_id("GenerateMessage") }

      before { @process = ProcessPilot.new(fixture_source("kitchen_sink.bpmn")).start }
    end
  end
end
