# frozen_string_literal: true

module ProcessPilot
  module Services
    class ProcessReader < ApplicationService
      PROCESS_READER_BIN = File.expand_path(File.dirname(__FILE__)) + "/process_reader.js"

      def initialize(source, env: nil)
        super()
        @source = source
        @env = env
      end

      def call
        execute_json_process(PROCESS_READER_BIN, stdin: @source, env: @env)
      end
    end
  end
end
