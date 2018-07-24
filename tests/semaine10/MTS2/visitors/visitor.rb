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

  def visitSuper node
    raise NotImplementedError.new
  end

  def visitIRange node
    raise NotImplementedError.new
  end

  def visitErange node
    raise NotImplementedError.new
  end

  def visitBlock node
    raise NotImplementedError.new
  end

  def visitArgs node
    raise NotImplementedError.new
  end

  def visitOpAssign node
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

  def visitBlock node
    raise NotImplementedError.new
  end

  def visitArgs node
    raise NotImplementedError.new
  end

  def visitDStr node
    raise NotImplementedError.new
  end

  def visitAnd node
    raise NotImplementedError.new
  end

  def visitOr node
    raise NotImplementedError.new
  end

  def visitTrue node
    raise NotImplementedError.new
  end

  def visitFalse node
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
