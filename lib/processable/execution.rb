# frozen_string_literal: true

module Processable
  class Execution
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :id, :status, :started_at, :ended_at, :variables, :tokens_in, :tokens_out, :start_event_id, :timer_expires_at, :message_names
    attr_accessor :activity, :parent, :children, :context

    def self.start(context:, process_id:, variables: {}, start_event_id: nil, parent: nil)
      process = context.process_by_id(process_id)
      raise ExecutionError.new("Process with id #{process_id} not found.") unless process
      Execution.new(context: context, activity: process, variables: variables, start_event_id: start_event_id, parent: parent).tap do |execution|
        context.executions.push execution
        execution.start
      end
    end

    def self.start_with_message(context:, message_name:, variables: {})
      [].tap do |executions|
        context.processes.map do |process|
          process.start_events.map do |start_event|
            start_event.message_event_definitions.map do |message_event_definition|
              if message_name == message_event_definition.message_name
                Execution.start(context: context, process_id: process&.id, variables: variables, start_event: start_event.id).tap { |execution| executions.push execution }
              end
            end
          end
        end
      end
    end

    def initialize(attributes={})
      super.tap do
        @id ||= SecureRandom.uuid
        @status = :activated
        @variables ||= {}.with_indifferent_access
        @tokens_in ||= []
        @tokens_out ||= []
        @message_names ||= []
        @children ||= []
      end
    end

    def ended?
      ended_at.present?
    end

    def bind_variable_scope(scope)
      parent.bind_variable_scope(scope) if parent
      variables.keys.each { |key| scope[key] = variables[key] }
    end

    def execute_activities(activities)
      activities.each { |activity| execute_activity(activity) }
    end

    def execute_activity(activity, sequence_flow = nil)
      child_execution = Execution.new(context: context, activity: activity, parent: self)
      children.push child_execution
      child_execution.tokens_in = [sequence_flow.id] if sequence_flow
      child_execution.start
    end

    def invoke_listeners(type, sequence_flow = nil)
      context.listeners.each { |listener| listener[type].call(self, sequence_flow) if listener[type] }
    end

    def start
      @status = :started
      @started_at = Time.zone.now
      context.notify_listener({ event: :started, execution: self })
      activity.attachments.each { |attachment| execute_activity(attachment) } if activity.respond_to?(:attachments)
      continue
    end

    def wait
      @status = :waiting
      context.notify_listener({ event: :waited, execution: self })
    end

    def continue
      activity.execute(self)
    end

    def throw_message(message_name)
      children.each do |child|
        if !child.ended? && child.message_event_definitions.any? { |message_event_definition| message_event_definition.message_name == message_name }
          child.signal
          break
        end
      end
      context.notify_listener({ event: :thrown, execution: self, message_name: message_name })
    end

    def terminate
      @status = :terminated
      self.end
    end

    def error
    end

    def end(notify_parent = false)
      @status = :completed unless status == :terminated
      parent.variables.merge!(variables) if parent && variables.present?
      @ended_at = Time.zone.now
      context.notify_listener({ event: :ended, execution: self })
      children.each { |child| child.terminate unless child.ended? }
      parent.has_ended(self) if parent && notify_parent
    end

    def take_all(sequence_flows)
      sequence_flows.each { |sequence_flow| take(sequence_flow) }
    end

    def take(sequence_flow)
      to_activity = sequence_flow.target
      tokens_out.push sequence_flow.id
      self.end(false)
      context.notify_listener({ event: :taken, execution: self, sequence_flow: sequence_flow })
      parent.execute_activity(to_activity, sequence_flow)
    end

    def signal(result = nil)
      @variables.merge!(result_to_variables(result)) if result.present?
      raise ExecutionError.new("Cannot signal an activity instance that has ended.") if ended?
      activity.signal(self)
    end

    def evaluate_condition(condition)
      evaluate_expression(condition.body) == true
    end

    def evaluate_expression(expression)
      ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: variables)
    end

    def result_to_variables(result)
      if activity.result_variable
        return { "#{activity.result_variable}": result }
      else
        if result.is_a? Hash
          result
        else
          {}.tap { |h| h[activity.id.underscore] = result }
        end
      end
    end

    def run
      case activity.type
      when "bpmn:ServiceTask"
        context.service_task_runner.call(self, context) if context.service_task_runner.present?
      when "bpmn:ScriptTask"
        context.script_task_runner.call(self, context) if context.script_task_runner.present?
      when "bpmn:BusinessRuleTask"
        context.business_rule_task_runner.call(self, context) if context.business_rule_task_runner.present?
      end
    end

    def call(process_id)
      Execution.start(context: context, process_id: process_id, variables: variables, parent: self)
    end

    #
    # Called by the child activity executors when they have ended
    #
    def has_ended(_child)
      activity.leave(self) if activity.is_a?(Bpmn::SubProcess) || activity.is_a?(Bpmn::CallActivity)
      self.end(true)
    end

    def child_by_activity_id(id)
      children.find { |child| child.activity.id == id }
    end

    def tokens
      [].tap do |active_tokens|
        children.each do |child|
          active_tokens += child.tokens_out
          active_tokens -= child.tokens_in if child.ended?
        end
      end.uniq
    end

    def activity_instance
      {
        id: id,
        activity_id: activity.id,
        activity_type: activity.type,
        status: status,
        started_at: started_at,
        ended_at: ended_at,
        variables: variables,
        tokens_in: tokens_in,
        tokens_out: tokens_out,
        message_name: message_names,
        timer_expires_at: timer_expires_at,
        activities: children.map { |child| child.activity_instance },
      }.compact_blank
    end
  end
end
