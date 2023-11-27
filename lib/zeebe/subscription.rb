# frozen_string_literal: true

module Zeebe
  class Subscription
    attr_accessor :correlation_key

    def initialize(moddle)
      @correlation_key = moddle["correlationKey"]
    end
  end
end
