class Visitor
  def accept visitor
    raise NotImpelementedError.new
  end
end

module Visitable
  def accept visitor
    visitor.visit self
  end
end

class BasicVisitor < Visitor
  attr_accessor :context

  # the inputs and outputs that we want to infer in the given method
  #def initialize context
    #@context = context
  #end

  def visit subject
    pp subject
  end
end
