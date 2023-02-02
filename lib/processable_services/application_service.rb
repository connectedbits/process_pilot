# frozen_string_literal: true

module ProcessableServices
  class ApplicationService

    def self.call(*args, **options, &block)
      new(*args, **options, &block).call
    end
  end
end
