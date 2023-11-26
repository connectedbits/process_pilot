# frozen_string_literal: true

module Bpmn
  class Element
    attr_accessor :type, :id, :name, :extensions

    def initialize(moddle)
      @type = moddle["$type"]
      @id = moddle["id"]
      @name = moddle["name"]
      @extensions = moddle["extensionElements"]["values"].map { |v| Bpmn::Extension.new(v) } if moddle["extensionElements"].present?
    end

    def extension_by_type(type)
      return nil unless extensions.present?
      extensions.find { |extension| extension.type == type }
    end

    def self.from_moddle(moddle)
      return nil if moddle["$type"].start_with?("bpmndi")
      begin
        klass = "Bpmn::#{moddle["$type"].split(':').last}".constantize
        return klass.new(moddle)
      rescue # => e
        ap "Create class for #{moddle["$type"]}"
        return Element.new(moddle)
      end
    end
  end

  class Message < Element
  end

  class Signal < Element
  end

  class Error < Element
  end

  class Collaboration < Element
  end

  class LaneSet < Element
  end

  class Participant < Element
    attr_accessor :process_ref, :process

    def initialize(moddle)
      super
      @process_ref = moddle["processRef"]
    end
  end
end
