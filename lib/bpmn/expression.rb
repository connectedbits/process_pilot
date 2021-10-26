module Bpmn
  class Expression < Element
    attr_accessor :body, :language

    def initialize(moddle)
      super
      @body = moddle["body"]
      @language = moddle["language"]
    end

    def valid?
      feel? || json_logic?
    end

    def feel?
      Expression.feel?(body)
    end

    def json_logic?
      Expression.json_logic?(body)
    end

    def evaluate(instance)
      raise "Expression body is required" unless body
      if language
        Processable::Config.instance.run_script(body, data: data)
      else
        Processable::Config.instance.evaluate_expression(body, data: data)
      end
    end

    def truthy?(data)
      evaluate(data) == true
    end

    def self.feel?(str)
      str&.start_with?("${") && str&.end_with?("}")
    end

    def self.json_logic?(str)
      str&.start_with?("{") && str&.end_with?("}")
    end

    def self.valid?(str)
      Expression.feel?(str) || Expression.json_logic?(str)
    end

    def self.evaluate(str, data)
      Processable::Config.instance.evaluate_expression(str, data: data)
    end

    def self.truthy?(str, data)
      Processable::Config.instance.evaluate_expression(str, data: data) == true
    end
  end

  class ConditionExpression < Expression
    
  end
end