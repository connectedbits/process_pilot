# frozen_string_literal: true

module Zeebe
  class FormDefinition
    attr_accessor :form_key

    def initialize(moddle)
      @form_key = moddle["formKey"]
    end
  end
end
