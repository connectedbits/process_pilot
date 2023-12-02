# frozen_string_literal: true
require_relative "./process_executor"

module Orchestr8
  module Services
    class ApplicationService
      include ProcessExecutor

      def self.call(*args, **options, &block)
        new(*args, **options, &block).call
      end
    end
  end
end
