require_relative "./visitor"
require_relative "./code"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  class PrettyPrinter < Visitor
    attr_accessor :code

    def initialize
      @code = Code.new
    end

    def visitRoot node
      puts "root"
      node.methods.each do |mname, method|
        puts "=================#{mname.to_s}=================="
        #if mname[1] == :behavior
        DATA.currentContext = mname
        method.accept self # unless method.nil?
        #end
      end
    end

    def visitUnknown node
        puts "unknown"
    end

    def visitMethod node
      puts "method"
      @code << "def #{node.name}(#{node.args.join(', ')})"
      @code.wrap
      node.body.accept self unless node.body.nil?
      @code.unwrap
      @code << "end"
      @code.newline 2
    end

    def visitBody node
      puts "body"
      @code << "("
      if node.methodBody
        @code.newline
      end
      node.stmts.each do |el|
        el.accept self unless el.nil?
      end
      if node.methodBody
        @code.newline
      end
      @code << ")"
    end

    def visitAssign node
      puts "assign"
      @code.newline
      @code << node.lhs.to_s + " = "
      node.rhs.accept self unless node.rhs.nil?
      @code.newline
    end

    def visitIf node
      puts "if"
      @code.newline
      @code << "if ("
      node.cond.accept self
      @code << ")"
      @code.wrap
      node.body.accept self unless node.body.nil?
      @code.unwrap
      @code << "else"
      @code.wrap
      node.else_.accept self unless node.else_.nil?
      @code.unwrap
      @code << "end"
    end

    def visitWhile node
      puts "while"
      @code.newline
      @code << "while #{node.cond}"
      @code.wrap
      node.body.accept self unless node.body.nil?
      @code.unwrap
      @ode << "end"
    end

    def visitFor node
      puts "for"
      # make sure this works
      node.idx ||= "i"
      @code.newline
      @code << "for #{node.idx} in ("
      node.range.accept self unless node.range.nil?
      @code << ")"
      @code.wrap
      node.body.accept self unless node.body.nil?
      @code.unwrap
      @code << "end"
    end

    def visitCase node
      puts "case"
      @code.newline
      node.whens.accept self unless node.whens.nil?
      node.else_.accept self unless node.else_.nil?
      @code << "(CASE)"
    end

    def visitWhen node
      puts "when"
      @code.newline
      node.body.accept self unless node.body.nil?
      @code << "(WHEN)"
    end

    def visitMCall node
      puts "mcall"
      if node.caller.nil?
        @code << "#{node.method}("
      else
        node.caller.accept self
        @code << ".#{node.method}("
      end
      node.args.each_with_index do |arg,idx|
        if idx !=  0
          @code << ", "
        end
        arg.accept self
      end
      @code << ")"

    end

    def visitDStr node
      puts "dstr"
      node.elements.each_with_index do |el,idx|
        if idx != 0
          @code << " + "
        end
        el.accept self unless el.nil?
        if !(el.is_a? StrLit)
          @code << ".to_s"
        end
      end
    end

    def visitLVar node
      puts "lvar"
      @code << node.name.to_s
    end

    def visitIntLit node
      puts "intlit"
      @code << node.value.to_s
    end

    def visitFloatLit node
      puts "floatlit"
      @code << node.value.to_s
    end

    def visitStrLit node
      puts "strlit"
      @code << '"'+node.value.to_s+'"'
    end

    def visitIRange node
      puts "irange"
      #@code << "(IRANGE : (lhs : #{node.lhs}, rhs : #{node.rhs}))"
      @code << "("
      node.lhs.accept self
      @code << ".."
      node.rhs.accept self
      @code << ")"
    end

    def visitAry node
      puts "ary"
      @code << "["
      node.elements.each_with_index do |el,idx|
        if idx != 0
          @code << ","
        end
        el.accept self
      end
      @code << "]"
    end

    def visitHsh node
      puts "hsh"
      @code << "(HASH)"
    end

    def visitRegExp node
      puts "regexp"
      @code << "REGEXP"
    end

    def visitReturn node
      puts "return"
      @code.newline
      @code << "return "
      node.value.accept self unless node.value.nil?
    end

    def visitConst node
      puts "const"
      @code << "(CONST)"
    end

    def visitSym node
      puts "sym"
      @code << ":#{node.value}"
    end
  end


end
