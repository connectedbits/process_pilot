# frozen_string_literal: true

module ProcessPilot
  class Evaluation
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def evaluate(decision_id, with: {})
      decision = context.decision_by_id(decision_id)
      raise "Decision not found: #{decision_id}" unless decision

      decision.rules.each do |rule|
        # Create an expression to evaluate the rule's input entries
        expression = rule.input_entries.map.with_index do |input_entry, index|
          get_expression(decision.inputs[index], input_entry)
        end.join(' and ')

        if Feel.evaluate(expression, with:)
          return {}.tap do |result|
            rule.output_entries.each_with_index do |output_entry, index|
              output = decision.outputs[index]
              value = output.type_ref == 'string' ? output_entry.delete_prefix('"').delete_suffix('"') : output_entry
              result[output.name] = to_value(output, value)
            end
          end
        end
      end
      nil # Return nil if no rule matches
    end

    private

    def get_expression(input, input_entry)
      if input_entry.nil? || input_entry.strip.empty?
        '(true)'
      else
        case input_entry
        when /^[<>]=? \d+$/ # Matches <=, >=, <, > with a number
          "((#{input.expression}) #{input_entry})"
        when /^\[\d+\.\.\d+\]$/ # Matches [num..num] range
          "((#{input.expression}) in #{input_entry})"
        when /^"\d+"(?:, "\d+")*$/ # Matches quoted numbers with comma separation
          "((#{input.expression}) in [#{input_entry}])"
        when /^".+"(?:, ".+")+$/ # Matches quoted strings with comma separation
          values = input_entry.split(',').map(&:strip).join(', ')
          "((#{input.expression}) in [#{values}])"
        else
          "((#{input.expression}) = #{input_entry})"
        end
      end
    end

    def to_value(output, output_entry)
      case output.type_ref
      when "number"
        return output_entry.to_f if output_entry.include?('.') || output_entry.include?(',')
        output_entry.to_i
      when "boolean"
        return output_entry.to_s.casecmp("true").zero?
      else
        output_entry
      end
    end
  end
end
