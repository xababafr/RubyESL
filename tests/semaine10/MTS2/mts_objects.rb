# this code contains all the objects necessary to create an AST

require_relative "./visitors/systemc"

module NMTS

  class Ast
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
      #puts "UNKNOWN"
      #pp sexp
    end

    def accept visitor
      visitor.visitUnknown self
    end

    def to_s
      @sexp.to_s
    end
  end

  # the root of everything (starting point of the visitor)
  class Root < Ast
    attr_accessor :inouts,
                  :threads,
                  :astHash,
                  :channels,
                  :initParams,
                  :localVars,
                  :sourceCode,
                  :rootIterate,
                  :instanceVars

    def initialize ast, initParams, threads
      @inouts = DATA.inouts
      @threads = threads
      @astHash = ast
      @channels = DATA.channels
      @initParams = initParams
      @localVars = DATA.local_vars
      @instanceVars = DATA.instance_vars

      createIterativeObject()
      puts "ROOT OBJ INITIALIZED"
    end

    def createIterativeObject
      # the goal here is to create a unique object that containers
      # everything the systemC ROOT visitor needs to print its code.
      # we create this object by gathering and reorganizing
      # the data registered in the initialize() method

      # {
      #   module_name => {
      #     :inouts => [ inout1, inout2, ... ],
      #     :methods => [{
      #       :name => ... ,
      #       :type => ... ,
      #       :args => ... ,
      #       :ast  => ...
      #     }]
      #   },
      #   ...
      # }

      @rootIterate = {}
      @astHash.each do |methArr, methAst|
        modul, method = methArr[0], methArr[1]
        @rootIterate[modul] ||= {}
        @rootIterate[modul][:methods] ||= []

        methHash = {
          :name => method,
          :type => nil ,#TypeFactory.create(nil, nil), # void
          :args => [],
          :ast  => methAst
        }
        @rootIterate[modul][:methods] << methHash

        @rootIterate[modul][:inouts] = []
        @inouts[modul].each do |name, inoutObj|
          @rootIterate[modul][:inouts] << inoutObj
        end
      end

      puts "ROOT ITERATE OBJ : \n"
      pp @rootIterate
    end

    def accept visitor
      visitor.visitRoot self
      @sourceCode = visitor.code.source

      puts "SOURCE CODE : \n\n"
      puts @sourceCode
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
    attr_accessor :stmts, :wrapperBody

    def initialize stmts=[], wrapperBody = false
      @stmts=stmts
      @wrapperBody = wrapperBody
    end

    def accept visitor
      visitor.visitBody self
    end
  end

  class Assign < Ast
    attr_accessor :lhs, :rhs, :type

    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end

    def accept visitor
      visitor.visitAssign self
    end
  end

  class OpAssign < Ast
    attr_accessor :lhs, :mid, :rhs

    def initialize lhs,mid,rhs
        @lhs,@mid,@rhs=lhs,mid,rhs
    end

    def accept visitor
      visitor.visitOpAssign self
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

  class And < Ast
    attr_accessor :lhs, :rhs

    def initialize lhs, rhs
      @lhs, @rhs = lhs, rhs
    end

    def accept visitor
      visitor.visitAnd self
    end
  end

  class Or < Ast
    attr_accessor :lhs, :rhs

    def initialize lhs, rhs
      @lhs, @rhs = lhs, rhs
    end

    def accept visitor
      visitor.visitOr self
    end
  end

  class TrueLit < Ast
    def initialize

    end

    def accept visitor
      visitor.visitTrue self
    end
  end

  class FalseLit < Ast
    def initialize

    end

    def accept visitor
      visitor.visitFalse self
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
    attr_accessor :caller,:method,:args, :name

    def initialize caller,method,args
      @caller,@method,@args=caller,method,args
      @name = @caller.name unless @caller.nil?
    end

    def accept visitor
      visitor.visitMCall self
    end
  end

  class Block < Ast
    attr_accessor :caller,:args,:body

    def initialize caller,args,body
      @caller,@args,@body=caller,args,body
    end

    def accept visitor
      visitor.visitBlock self
    end
  end

  class Args < Ast
    attr_accessor :args

    def initialize args
      @args = []
      args.each do |arg|
        @args << arg.children[0]
      end
    end

    def accept visitor
      visitor.visitArgs self
    end
  end

  class LVar < Ast
    attr_accessor :name, :type
    def initialize name
      @name=name
    end

    def accept visitor
      visitor.visitLVar self
    end
  end

  class Super < Ast
    attr_accessor :args

    def initialize args
      @args = args
    end

    def accept visitor
      visitor.visitSuper self
    end
  end

  class IntLit < Ast
    attr_accessor :value, :name

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

  class ERange < Ast
    attr_accessor :lhs, :rhs

    def initialize l,r
      @lhs,@rhs=l,r
    end

    def accept visitor
      visitor.visitERange self
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
    attr_accessor :children, :name

    def initialize children
      @children = children
      @name = @children[1]
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
