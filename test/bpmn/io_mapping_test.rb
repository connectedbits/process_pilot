# frozen_string_literal: true

require "test_helper"

module Processable

  describe "IO Mapping" do
    let(:source) { fixture_source("io_mapping.bpmn") }
    let(:context) { Processable::Context.new(sources: source) }
    let(:services) {
      {
        greeti: proc { |_execution, variables|
          { response: { body: { greeting: "👋 Hello #{variables[:name]}!" } } }
        },
      }
    }

    describe :definition do
      let(:process) { context.process_by_id("IOMapping") }
      let(:start_event) { process.element_by_id("Start") }
      let(:enter_name_task) { process.element_by_id("EnterName") }
      let(:author_greeting_task) { process.element_by_id("AuthorGreeting") }
      let(:end_event) { process.element_by_id("End") }

      it "should parse the task" do
        _(start_event).wont_be_nil
        _(enter_name_task).wont_be_nil
        _(author_greeting_task).wont_be_nil
        _(end_event).wont_be_nil
      end
    end

    describe :execution do
      let(:process) { @process }
      let(:start_event) { process.child_by_step_id("Start") }
      let(:enter_name_task) { process.child_by_step_id("EnterName") }
      let(:author_greeting_task) { process.child_by_step_id("AuthorGreeting") }
      let(:end_event) { process.child_by_step_id("End") }

      before { @process = Execution.start(context: context, process_id: "IOMapping"); }

      describe :mapping do
        before { enter_name_task.signal({ first_name: "John", last_name: "Doe" }) }

        describe :inputs do
          it "should map the input" do
            skip "TODO: implement io mapping in execution"
            print_execution(process)
            #_(enter_name_task.output[:name]).must_equal "John Doe"
          end

          # describe :outputs do
          #   before { author_greeting_task.signal({}) }

          #   it "should map the output" do
          #     #_(author_greeting_task.output[:greeting]).must_equal "👋 Hello John Doe!"
          #   end
          # end
        end
      end
    end
  end
end
