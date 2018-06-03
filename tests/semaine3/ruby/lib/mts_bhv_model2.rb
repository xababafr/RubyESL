require_relative "visitor"

module MTS

  class Ast
    def get_type
      return self.class.name
    end
  end
  ## these are the containers

  class Method < Ast
    include Visitable

    attr_accessor :name,:args,:body

    def initialize name,args,body
      @name,@args,@body=name,args,body
    end

    def accept(visitor)
      puts "<> Method #{@name}(#{@args})"
      @body.accept(visitor)
    end
  end

  class Body < Ast
    include Visitable

    attr_accessor :stmts

    def initialize stmts=[]
      @stmts=stmts
    end

    def get_type
      @stmts[0].get_type
    end

    def accept(visitor)
      puts "<> Body"
      @stmts.each do |el|
        el.accept(visitor)
      end
    end
  end

  class Assign < Ast
    include Visitable

    attr_accessor :lhs,:rhs

    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end

    def accept(visitor)
      puts "<> Assign : #{@lhs} = #{@rhs}"
      #@lhs.accept(visitor)
      @rhs.accept(visitor)
      $vars[@lhs] = @rhs.get_type
    end
  end

  class If < Ast
    include Visitable

    attr_accessor :cond,:body,:else_

    def initialize cond,body,else_=nil
      @cond,@body,@else_=cond,body,else_
    end

    def accept(visitor)
      puts "<> If"
      #@cond.accept(visitor)
      @body.accept(visitor)
      @else_.accept(visitor)
    end
  end

  class While < Ast
    include Visitable

    attr_accessor :cond,:body

    def initialize cond,body
      @cond,@body=cond,body
    end

    def accept(visitor)
      puts "<> While"
      #@cond.accept(visitor)
      @body.accept(visitor)
    end
  end

  class For < Ast
    include Visitable

    attr_accessor :idx,:range,:body

    def initialize cond,range,body
      @cond,@range,@body=cond,range,body
    end

    def accept(visitor)
      puts "<> For"
      #@cond.accept(visitor)
      #@range.accept(visitor)
      @body.accept(visitor)
    end
  end

  class Case < Ast
    include Visitable

    attr_accessor :expr,:whens,:else_

    def initialize expr,whens,else_
      @expr,@whens,@else_=expr,whens,else_
    end

    def accept(visitor)
      puts "<> Case"
      #@expr.accept(visitor)
      @whens.accept(visitor)
      @else_.accept(visitor)
    end
  end

  class When < Ast
    include Visitable

    attr_accessor :expr,:body

    def initialize expr,body
      @expr,@body=expr,body
    end

    def accept(visitor)
      puts "<> When"
      #@expr.accept(visitor)
      @body.accept(visitor)
    end
  end

  class MCall < Ast
    include Visitable

    attr_accessor :caller,:method,:args

    def initialize caller,method,args
      @caller,@method,@args=caller,method,args
    end

    def accept(visitor)
      puts "<> Mcall #{@caller} : #{@method}(#{@args})"
      #@method.accept(visitor)
    end

    def get_type
      callerType = @caller.get_type
      argsTypes = []
      @args.each do |arg|
        argsTypes << arg.get_type
      end
      puts "\n\n"
      #pp @args
      #pp ({:caller => callerType, :args => argsTypes})
      # 'caller.methodname' 'argsTypes'
      $methods[callerType+"."+@method.to_s][argsTypes]
    end
  end

  class Dstr < Ast
    include Visitable

    attr_accessor :elements

    def initialize elements=[]
      @elements=elements
    end

    def accept(visitor)
      puts "<> Dstr"
      @elements.each do |el|
        el.accept(visitor)
      end
    end
  end

  # these are the end nodes
  # a lot of them are still missing? (float, etc...)
  #===============================
  class LVar < Ast
    include Visitable

    attr_accessor :name
    def initialize name
      @name=name
    end

    def get_type
      # we get the type that was already inferred for the variable
      $vars[@name]
    end
  end

  class IntLit < Ast
    include Visitable

    def initialize val
      @value=val
    end
  end

  class FloatLit < Ast
    include Visitable

    def initialize val
      @value=val
    end
  end

  class StrLit < Ast
    include Visitable

    def initialize val
      @value=val
    end
  end

  class IRange < Ast
    include Visitable

    def initialize l,r
      @lhs,@rhs=l,r
    end
  end

  class Ary < Ast
    include Visitable

    attr_accessor :elements
    def initialize elements=[]
      @elements=elements
    end
  end

  class Hsh < Ast
    include Visitable

    def initialize
    end
  end

  class RegExp < Ast
    include Visitable

    def initialize
    end
  end

  class Const < Ast
    include Visitable

    def initialize
    end
  end

  class Sym < Ast
    include Visitable

    attr_accessor :value
    def initialize value
      @value = value
    end
  end

end
