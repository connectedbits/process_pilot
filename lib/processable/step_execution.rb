module Processable
  class StepExecution
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :id, :element_id, :status, :started_at, :ended_at, :variables, :tokens_in, :tokens_out, :message_names, :expires_at, :attached_to_id
    attr_accessor :execution, :element, :attached_to

    delegate :context, :element_by_id, :evaluate_condition, :evaluate_expression, :evaluate_decision, :run_script, :call_service, :external_services?, to: :execution

    def self.new_for_execution(execution:, element:, token: nil, attached_to: nil)
      StepExecution.new(execution: execution, element_id: element.id, tokens_in: token ? [token] : [], attached_to_id: attached_to&.id)
    end

    def initialize(attributes={})
      super.tap do
        @id ||= SecureRandom.uuid
        @status ||= 'initialized'
        @variables ||= {}
        @tokens_in ||= []
        @tokens_out ||= []
        @message_names ||= []
      end
    end

    def element
      @element ||= element_by_id(element_id)
    end

    def attached_to
      @attached_to ||= attached_to_id ? execution.steps.find { |step| step.id == attached_to_id } : nil
    end

    def attachments
      execution.steps.select { |step| step.attached_to_id == id }
    end

    def start
      @started_at = Time.now
      update_status('started')
    end

    def wait
      update_status('waiting')
    end

    def invoke(variables: {})
      @variables = variables.merge(variables).with_indifferent_access
      continue
    end

    def terminate
      @ended_at = Time.now
      update_status('terminated')
    end

    def continue
      self.end
    end

    def end
      @ended_at = Time.now
      @tokens_out = element.outgoing_flows(self).map { |flow| flow.id }
      update_status('ended')
    end

    def evaluate_condition(condition)
      evaluate_expression(condition.body) == true
    end

    def evaluate_expression(expression)
      ProcessableServices::ExpressionEvaluator.call(expression: expression, variables: execution.variables)
    end

    def evaluate_decision(decision_ref)
      source = context.decisions[decision_ref]
      raise ExecutionError.new("Decision #{decision_ref} not found.") unless source
      ProcessableServices::DecisionEvaluator.call(decision_ref, source, execution.variables)
    end

    def call_service(topic)
      service = context.services[topic.to_sym]
      raise ExecutionError.new("Service #{topic} not found.") unless service
      service.call(execution.variables)
    end

    def run_script(script)
      raise ExecutionError.new("Script #{script} can't be blank.") unless script.present?
      ProcessableServices::ScriptRunner.call(script: script, variables: execution.variables, utils: context.utils)
    end

    def set_timer(expires_at)
      @expires_at = expires_at
    end

    def catch_message(message_name)
      message_names.push message_name
    end

    def throw_message(message_name)
      execution.message_received(message_name)
    end

    def started?
      status == 'started'
    end

    def waiting?
      status == 'waiting'
    end

    def ended?
      status == 'ended'
    end

    def terminated?
      status == 'terminated'
    end

    def sources
      execution.steps.select { |step| (step.tokens_out & tokens_in).length > 0 }
    end

    def targets
      execution.steps.select { |step| (step.tokens_in & tokens_out).length > 0 }
    end

    def attributes
      { 'id': nil, 'element_id': nil, 'status': nil, 'started_at': nil, 'ended_at': nil, 'variables': nil, 'tokens_in': nil, 'tokens_out': nil, 'message_names': nil, 'expires_at': nil, 'attached_to_id': nil }
    end

    def as_json(options = {})
      {
        id: id,
        element_id: element_id,
        status: status,
        started_at: started_at,
        ended_at: ended_at,
        variables: variables,
        tokens_in: tokens_in,
        tokens_out: tokens_out,
        message_names: message_names,
        expires_at: expires_at,
        attached_to_id: attached_to_id
      }.compact
    end

    private

    def update_status(status)
      @status = status
      event = "step_#{status}".to_sym
      execution.send(event, self) if execution.respond_to?(event)
    end
  end
end