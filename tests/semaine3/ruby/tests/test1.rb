require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./struct1.rb"
analyzer.parse
pp analyzer.behaviors

class BasicVisitor < Visitor
  # the inputs and outputs that we want to infer in the given method
  def initialize
  end

  def visit subject
    pp subject
  end
end

analyzer.behaviors[0][:method].accept BasicVisitor.new
