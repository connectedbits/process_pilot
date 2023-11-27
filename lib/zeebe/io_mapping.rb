# frozen_string_literal: true

module Zeebe
  class IoMapping < Bpmn::Extension
    attr_accessor :source, :target

    def initialize(moddle)
      super(moddle)
      @source = moddle["source"]
      @target = moddle["target"]
    end
  end
end
