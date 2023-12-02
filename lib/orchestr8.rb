# frozen_string_literal: true

require "orchestr8/version"

require "active_support"
require "active_support/time"
require "active_support/core_ext/hash"
require "active_support/core_ext/object/json"
require "json_logic"
require "awesome_print"

require "orchestr8/bpmn/element"
require "orchestr8/bpmn/step"
require "orchestr8/bpmn/flow"
require "orchestr8/bpmn/association"
require "orchestr8/bpmn/task"
require "orchestr8/bpmn/event"
require "orchestr8/bpmn/extensions"
require "orchestr8/bpmn/extension_elements"
require "orchestr8/bpmn/gateway"
require "orchestr8/bpmn/builder"
require "orchestr8/bpmn/process"
require "orchestr8/bpmn/expression"
require "orchestr8/bpmn/event_definition"
require "orchestr8/bpmn/text_annotation"

require "orchestr8/context"
require "orchestr8/execution"
require "orchestr8/task_runner"

require "orchestr8/services/application_service"
require "orchestr8/services/decision_evaluator"
require "orchestr8/services/decision_reader"
require "orchestr8/services/expression_evaluator"
require "orchestr8/services/feel_evaluator"
require "orchestr8/services/json_logic_evaluator"
require "orchestr8/services/process_reader"
require "orchestr8/services/script_runner"

module Orchestr8
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
