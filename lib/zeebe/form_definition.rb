# frozen_string_literal: true

module Zeebe
  class FormDefinition < Bpmn::Extension
    attr_accessor :form_key

    def initialize(moddle)
      super(moddle)
      @form_key = moddle["formKey"]
    end
  end
end
