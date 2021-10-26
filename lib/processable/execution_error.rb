module Processable
  class ExecutionError < StandardError
    attr_reader :execution

    def initialize(msg, process_instance: nil, step_instance: nil)
      @process_instance = process_instance
      @step_instance = step_instance
      super(msg)
    end
  end
end