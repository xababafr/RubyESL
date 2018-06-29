require_relative "visitor"
require_relative "mts_behaviours"

module MTS

  class Ast
    attr_accessor :context, :type

    def initialize context
      @context = context
    end

    def accept
      raise NotImplementedError.new
    end
  end
  ## these are the containers

  # for nodes that has not been objectified yet
  class Unknown < Ast
    attr_accessor :sexp

    def initialize sexp
      @sexp = sexp
    end

    def accept visitor
      visitor.visitUnknown self
    end
  end

  # the root of everything (starting point of the visitor)
  class Root < Ast
    attr_accessor :methods

    def initialize methods
      @methods = methods
    end

    def accept visitor
      visitor.visitRoot self
    end
  end

  class Method < Ast
    attr_accessor :name,:args,:body

    def initialize name,args,body
      @name,@args,@body=name,args,body
    end

    def accept visitor
      visitor.visitMethod self
    end
  end

  class Body < Ast
    attr_accessor :stmts, :methodBody

    def initialize stmts=[], methodBody = false
      @stmts=stmts
      @methodBody = methodBody
    end

    def accept visitor
      visitor.visitBody self
    end
  end

  class Assign < Ast
    attr_accessor :lhs,:rhs

    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end

    def accept visitor
      visitor.visitAssign self
    end
  end

  class If < Ast
    attr_accessor :cond,:body,:else_

    def initialize cond,body,else_=nil
      @cond,@body,@else_=cond,body,else_
    end

    def accept visitor
      visitor.visitIf self
    end
  end

  class While < Ast
    attr_accessor :cond,:body

    def initialize cond,body
      @cond,@body=cond,body
    end

    def accept visitor
      visitor.visitWhile self
    end
  end

  class For < Ast
    attr_accessor :idx,:range,:body

    def initialize cond,range,body
      @cond,@range,@body=cond,range,body
    end

    def accept visitor
      visitor.visitFor self
    end
  end

  class Case < Ast
    attr_accessor :expr,:whens,:else_

    def initialize expr,whens,else_
      @expr,@whens,@else_=expr,whens,else_
    end

    def accept visitor
      visitor.visitCase self
    end
  end

  class When < Ast
    attr_accessor :expr,:body

    def initialize expr,body
      @expr,@body=expr,body
    end

    def accept visitor
      visitor.visitWhen self
    end
  end

  class Dstr < Ast
    attr_accessor :elements

    def initialize elements=[]
      @elements=elements
    end

    def accept visitor
      visitor.visitDStr self
    end
  end

  class Return < Ast
    attr_accessor :value
    def initialize value
      @value = value
    end

    def accept visitor
      visitor.visitReturn self
    end
  end

  # these are the end nodes
  # a lot of them are still missing? (float, etc...)
  #===============================
  class MCall < Ast
    attr_accessor :caller,:method,:args

    def initialize caller,method,args
      @caller,@method,@args=caller,method,args
    end

    def accept visitor
      visitor.visitMCall self
    end
  end

  class LVar < Ast
    attr_accessor :name
    def initialize name
      @name=name
    end

    def accept visitor
      visitor.visitLVar self
    end
  end

  class IntLit < Ast
    attr_accessor :value

    def initialize val
      @value=val
    end

    def accept visitor
      visitor.visitIntLit self
    end
  end

  class FloatLit < Ast
    attr_accessor :value

    def initialize val
      @value=val
    end

    def accept visitor
      visitor.visitFloatLit self
    end
  end

  class StrLit < Ast
    attr_accessor :value

    def initialize val
      @value=val
    end

    def accept visitor
      visitor.visitStrLit self
    end
  end

  class IRange < Ast
    attr_accessor :lhs, :rhs

    def initialize l,r
      @lhs,@rhs=l,r
    end

    def accept visitor
      visitor.visitIRange self
    end
  end

  class Ary < Ast
    attr_accessor :elements

    def initialize elements=[]
      @elements=elements
    end

    def accept visitor
      visitor.visitAry self
    end
  end

  class Hsh < Ast
    def initialize
    end

    def accept visitor
      visitor.visitHsh self
    end
  end

  class RegExp < Ast
    def initialize
    end

    def accept visitor
      visitor.visitRegExp self
    end
  end

  class Const < Ast
    def initialize
    end

    def accept visitor
      visitor.visitConst self
    end
  end

  class Sym < Ast
    attr_accessor :value

    def initialize value
      @value = value
    end

    def accept visitor
      visitor.visitSym self
    end
  end

end
