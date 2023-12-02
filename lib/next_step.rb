# frozen_string_literal: true

require "next_step/version"

require "active_support"
require "active_support/time"
require "active_support/core_ext/hash"
require "active_support/core_ext/object/json"
require "json_logic"
require "awesome_print"

require "next_step/bpmn/element"
require "next_step/bpmn/step"
require "next_step/bpmn/flow"
require "next_step/bpmn/association"
require "next_step/bpmn/task"
require "next_step/bpmn/event"
require "next_step/bpmn/extensions"
require "next_step/bpmn/extension_elements"
require "next_step/bpmn/gateway"
require "next_step/bpmn/builder"
require "next_step/bpmn/process"
require "next_step/bpmn/expression"
require "next_step/bpmn/event_definition"
require "next_step/bpmn/text_annotation"

require "next_step/context"
require "next_step/execution"
require "next_step/task_runner"

require "next_step/services/application_service"
require "next_step/services/decision_evaluator"
require "next_step/services/decision_reader"
require "next_step/services/expression_evaluator"
require "next_step/services/feel_evaluator"
require "next_step/services/json_logic_evaluator"
require "next_step/services/process_reader"
require "next_step/services/script_runner"

module NextStep
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
