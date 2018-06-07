require_relative "visitor"

module MTS

  class Ast
    attr_accessor :context

    def initialize context
      @context = context
    end

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
      pp visitor.context
      $contexts[$currentContext][@lhs] = @rhs.get_type
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

      userDefinedMethod = false
      oldcontext = nil
      newContext = nil
      retType = nil
      $contexts.keys.each do |key|
        # for now, we just check with the name
        # if we are a user defined method :
        if key[1] == @method
          userDefinedMethod = true
          newContext = key
        end
      end
      argsTypes = []
      @args.each do |arg|
        argsTypes << arg.get_type
      end

      puts "ARGSTYPES"
      pp @args
      pp argsTypes

      if !userDefinedMethod

        callerType = @caller.get_type
        # 'caller.methodname' 'argsTypes'
        puts "\n\n"
        puts callerType+"."+@method.to_s

        # return the type corresponding the the signature
        retType = SIGNATURES[callerType+"."+@method.to_s][argsTypes]

      else

        puts "userDefinedMethod"
        oldContext = $currentContext.dup
        $currentContext = newContext
        recursiveVisitor = BasicVisitor.new
        #pp $methods
        $methods.values.each do |met|
          if met.name == @method
            # define the context for the method
            for i in (0...met.args.size)
              $contexts[newContext][met.args[i]] = argsTypes[i]
            end

            puts "newContext"
            pp $contexts

            # then explore it
            met.accept recursiveVisitor
            puts "RETURN TYPES"
            pp $returnTypes

            retType = $returnTypes[$currentContext]
          end
        end

        $currentContext = oldContext
        pp $currentContext

      end

      retType

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
      $contexts[$currentContext][@name]
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

  class Return < Ast
    include Visitable

    def initialize value
      @value = value
    end

    def accept visitor
      @value.accept visitor
      get_type
    end

    def get_type
      typ = @value.get_type
      oldType = $returnTypes[$currentContext]
      if oldType.size > 0
        union = true
        oldType.each do |type|
          if type == typ
            union = false
          end
        end
        if union
          $returnTypes[$currentContext] << typ
        end
      else
        $returnTypes[$currentContext] << typ
      end
      puts "RETURN TYPE REACHED"
      pp $returnTypes

      #oldTyp = $contexts[$currentContext][]
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
