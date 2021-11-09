# frozen_string_literal: true

module Processable
  class ExecutionPrinter
    attr_accessor :execution

    def initialize(execution)
      @execution = execution
    end

    def print
      puts
      puts "#{execution.step.id} #{execution.status} * #{execution.tokens.join(', ')}"
      print_variables unless execution.variables.empty?
      print_children
      puts
    end

    def print_children
      puts
      execution.children.each_with_index do |child, index|
        print_child(child, index)
      end
    end

    def print_child(child, index)
      str = "#{index} #{child.step.type.split(':').last} #{child.step.id}: #{child.status} #{JSON.pretty_generate(child.variables, { indent: '', object_nl: ' ' }) unless child.variables.empty? }".strip
      str = "#{str} * in: #{child.tokens_in.join(', ')}" if child.tokens_in.present?
      str = "#{str} * out: #{child.tokens_out.join(', ')}" if child.tokens_out.present?
      puts str
    end

    def print_variables
      puts
      puts JSON.pretty_generate(execution.variables)
    end
  end
end
