# frozen_string_literal: true

module Bpmn
  class ExtensionElements
    VALID_EXTENSIONS = %w[zeebe:AssignmentDefinition zeebe:CalledDecision zeebe:FormDefinition zeebe:IoMapping zeebe:Properties zeebe:Script zeebe:Subscription zeebe:TaskDefinition zeebe:TaskSchedule].freeze

    attr_accessor :assignment_definition, :called_decision, :form_definition, :io_mapping, :properties, :script, :subscription, :task_definition, :task_schedule

    def initialize(moddle)
      moddle["values"].each do |moddle_value|
        extension_type = moddle_value["$type"]
        if extension_type == "zeebe:Properties"
          @properties = {}
          moddle_value["properties"].each { |property_moddle| @properties[property_moddle["name"]] = property_moddle["value"] } 
        elsif VALID_EXTENSIONS.include?(extension_type)
          extension_parts = extension_type.split(":")
          klass = "#{extension_parts.first.capitalize}::#{extension_parts.last}".constantize
          self.send("#{extension_parts.last.underscore}=", klass.new(moddle_value))
        else
          raise "Unknown extension type: #{extension_type}"
        end
      end
    end
  end
end
