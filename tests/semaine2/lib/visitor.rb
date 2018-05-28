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
