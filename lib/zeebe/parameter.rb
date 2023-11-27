# frozen_string_literal: true

module Zeebe
  class Parameter
    attr_accessor :source, :target

    def initialize(moddle)
      @source = moddle["source"]
      @target = moddle["target"]
    end
  end
end
