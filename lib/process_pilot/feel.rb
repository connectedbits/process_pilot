# frozen_string_literal: true

module Feel
  class Error < StandardError; end

  Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'feel/grammar.treetop')))

  def self.parse(expression)
    GrammarParser.new.parse(expression)
  end

  def self.evaluate(expression, with: {})
    GrammarParser.new.parse(expression).eval(with)
  end
end
