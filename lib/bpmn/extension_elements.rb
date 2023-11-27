# frozen_string_literal: true

module Bpmn
  class ExtensionElements
    VALID_EXTENSIONS = %w[assignment_definition called_decision form_definition io_mapping properties script task_definition task_schedule].freeze

    attr_accessor :assignment_definition, :called_decision, :form_definition, :io_mapping, :properties, :script, :task_definition, :task_schedule

    def initialize(moddle)
      @extensions = {}
      @extensions = moddle["values"].map do |moddle_extension|
        attr_name = moddle_extension["$type"].split(":").last.underscore
        if VALID_EXTENSIONS.include?(attr_name)
          extension_class = extension_class(moddle_extension["$type"])
          self.send("#{attr_name}=", extension_class.new(moddle_extension))
        end
      end
    end

    private

    def extension_class(type)
      "Zeebe::#{type.split(':').last}".constantize
    end
  end
end
