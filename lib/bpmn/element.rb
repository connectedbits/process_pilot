module Bpmn
  class Element
    attr_accessor :type, :id, :name

    def initialize(moddle)
      @type = moddle["$type"]
      @id = moddle["id"]
      @name = moddle["name"]
    end

    def self.from_moddle(moddle)
      return nil if moddle["$type"].start_with?("bpmndi")
      begin
        klass = "Bpmn::#{moddle["$type"].split(':').last}".constantize
        return klass.new(moddle)
      rescue # => e
        return Element.new(moddle)
      end
    end
  end
end