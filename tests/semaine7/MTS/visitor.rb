# l'interface visitor
class Visitor
  def visitRoot node
    raise NotImplementedError.new
  end

  def visitUnknown node
    raise NotImplementedError.new
  end

  def visitMethod node
    raise NotImplementedError.new
  end

  def visitBody node
    raise NotImplementedError.new
  end

  def visitAssign node
    raise NotImplementedError.new
  end

  def visitIf node
    raise NotImplementedError.new
  end

  def visitWhile node
    raise NotImplementedError.new
  end

  def visitFor node
    raise NotImplementedError.new
  end

  def visitCase node
    raise NotImplementedError.new
  end

  def visitWhen node
    raise NotImplementedError.new
  end

  def visitMCall node
    raise NotImplementedError.new
  end

  def visitDStr node
    raise NotImplementedError.new
  end

  def visitLVar node
    raise NotImplementedError.new
  end

  def visitIntLit node
    raise NotImplementedError.new
  end

  def visitFloatLit node
    raise NotImplementedError.new
  end

  def visitStrLit node
    raise NotImplementedError.new
  end

  def visitIRange node
    raise NotImplementedError.new
  end

  def visitAry node
    raise NotImplementedError.new
  end

  def visitHsh node
    raise NotImplementedError.new
  end

  def visitRegExp node
    raise NotImplementedError.new
  end

  def visitReturn node
    raise NotImplementedError.new
  end

  def visitConst node
    raise NotImplementedError.new
  end

  def visitSym node
    raise NotImplementedError.new
  end
end

# class BasicVisitor < Visitor
#   attr_accessor :context
#
#   # the inputs and outputs that we want to infer in the given method
#   #def initialize context
#     #@context = context
#   #end
#
#   def visit subject
#     pp subject
#   end
# end
