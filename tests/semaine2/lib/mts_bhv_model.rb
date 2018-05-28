module MTS
  class Ast
  end

  class Method < Ast
    attr_accessor :name,:args,:body
    def initialize name,args,body
      @name,@args,@body=name,args,body
    end
  end

  class Body < Ast
    attr_accessor :stmts
    def initialize stmts=[]
      @stmts=stmts
    end
  end

  class Assign < Ast
    attr_accessor :lhs,:rhs
    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end
  end

  class If < Ast
    attr_accessor :cond,:body,:else_
    def initialize cond,body,else_=nil
      @cond,@body,@else_=cond,body,else_
    end
  end

  class While < Ast
    attr_accessor :cond,:body
    def initialize cond,body
      @cond,@body=cond,body
    end
  end

  class For < Ast
    attr_accessor :idx,:range,:body
    def initialize cond,range,body
      @cond,@range,@body=cond,range,body
    end
  end

  class Case < Ast
    attr_accessor :expr,:whens,:else_
    def initialize expr,whens,else_
      @expr,@whens,@else_=expr,whens,else_
    end
  end

  class When < Ast
    attr_accessor :expr,:body
    def initialize expr,body
      @expr,@body=expr,body
    end
  end

  class MCall < Ast
    attr_accessor :caller,:method,:args
    def initialize caller,method,args
      @caller,@method,@args=caller,method,args
    end
  end

  #===============================
  class LVar < Ast
    def initialize name
      @name=name
    end
  end

  class IntLit < Ast
    def initialize val
      @value=val
    end
  end

  class StrLit < Ast
    def initialize val
      @value=val
    end
  end

  class IRange < Ast
    def initialize l,r
      @lhs,@rhs=l,r
    end
  end

  class Ary < Ast
    attr_accessor :elements
    def initialize elements=[]
      @elements=elements
    end
  end

  class Hsh < Ast
    def initialize
    end
  end

  class RegExp < Ast
    def initialize
    end
  end

  class Const < Ast
    def initialize
    end
  end

  class Sym < Ast
    attr_accessor :value
    def initialize value
      @value = value
    end
  end

  class Dstr < Ast
    attr_accessor :elements
    def initialize elements=[]
      @elements=elements
    end
  end
end
