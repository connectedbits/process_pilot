# frozen_string_literal: true

require "process_pilot/bpmn/element"
require "process_pilot/bpmn/step"
require "process_pilot/bpmn/flow"
require "process_pilot/bpmn/association"
require "process_pilot/bpmn/task"
require "process_pilot/bpmn/event"
require "process_pilot/bpmn/extensions"
require "process_pilot/bpmn/extension_elements"
require "process_pilot/bpmn/gateway"
require "process_pilot/bpmn/builder"
require "process_pilot/bpmn/process"
require "process_pilot/bpmn/expression"
require "process_pilot/bpmn/event_definition"
require "process_pilot/bpmn/text_annotation"

require "process_pilot/context"
require "process_pilot/execution"
require "process_pilot/task_runner"

require "process_pilot/services/application_service"
require "process_pilot/services/decision_evaluator"
require "process_pilot/services/decision_reader"
require "process_pilot/services/expression_evaluator"
require "process_pilot/services/feel_evaluator"
require "process_pilot/services/json_logic_evaluator"
require "process_pilot/services/process_reader"
require "process_pilot/services/script_runner"

module ProcessPilot
  #
  # Entry point for starting a process execution.
  #
  # sources: Single or array of BPMN or DMN XML sources
  # services: Hash of procs to be injected into the context
  #
  def self.new(sources, services: {}, listeners: [])
    Context.new(sources: Array.wrap(sources), services: services, listeners: listeners)
  end
end
