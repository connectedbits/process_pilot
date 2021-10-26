module Bpmn
  class Flow < Element
    attr_accessor :source_ref, :target_ref
    attr_accessor :source, :target

    def initialize(moddle)
      super
      @source_ref = moddle["sourceRef"]
      @target_ref = moddle["targetRef"]
      @source = nil
      @target = nil
    end
  end

  class SequenceFlow < Flow
    attr_accessor :condition

    def initialize(moddle)
      super
      @condition = Expression.new(moddle["conditionExpression"]) if moddle["conditionExpression"]
    end

    def evaluate(instance)
      return true unless condition&.body
      if condition.language
        Processable::Config.instance.run_script(condition.body, data: instance.process_instance.data) == true
      else
        Processable::Config.instance.evaluate_expression(condition.body, data: instance.process_instance.data) == true
      end
    end
  end
end