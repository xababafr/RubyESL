require_relative "./visitor"
require_relative "./code"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  class SystemcPrinter < Visitor
    attr_accessor :code

    def initialize
      @code = Code.new
    end

    def visitRoot node
      puts "root"

      @code << "#include <systemc.h>"
      @code.newline 2

      # for each class
      node.classes.each do |klass,methods|
        oredered_actors_classes = node.ordered_actors.map { |a| a.class.to_s }
        puts "ORDERED CLASSES"
        pp oredered_actors_classes
        if oredered_actors_classes.uniq.include?(klass.to_s)
          @code << "SC_MODULE( #{klass} ) {"
        else
          @code << "class #{klass} {"
        end
        @code.wrap

        # printing inouts
        inputs, outputs = [], []
        node.connexions.each do |conx|
          if conx[0][:cname] == klass
            outputs << conx[0][:port]
          end
          if conx[1][:cname] == klass
            inputs << conx[1][:port]
          end
        end

        inputs.uniq.each do |input|
          # for now, let's not put the type
          @code << "sc_in<TYP> #{input};"
          @code.newline
        end

        outputs.uniq.each do |output|
          # for now, let's not put the type
          @code << "sc_out<TYP> #{output};"
          @code.newline
        end

        @code.newline

        # go for each method
        #methods.each do |methArray|
          #code << methArray[0].to_s + "\n"
          #methArray[1].accept self
        #end

        @code.unwrap
        @code.newline
        @code << "};"
        @code.newline 2

      end

    end

    def visitUnknown node
        puts "unknown"
        @code << node.to_s
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

      # for now, always inactive.
      if node.wrapperBody

        @code.newline
        node.stmts.each do |el|
          el.accept self unless el.nil?
        end
        @code.newline

      else

        @code << "("
        node.stmts.each do |el|
          el.accept self unless el.nil?
        end
        @code << ")"

      end

    end

    def visitAssign node
      puts "assign"
      @code.newline
      @code << node.lhs.to_s + " = "
      node.rhs.accept self unless node.rhs.nil?
      @code.newline
    end

    def visitSuper node
      puts "assign"
      @code.newline
      @code << "super("
      node.args.each_with_index do |arg,idx|
        if idx != 0
          @code << ", "
        end
        arg.accept self
      end
      @code << ")"
      @code.newline
    end

    def visitOpAssign node
      puts "op_assign"
      @code.newline
      @code << node.lhs.lhs.to_s + " #{node.mid}= "
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
      @code.newline
    end

    def visitWhile node
      puts "while"
      @code.newline
      @code << "while #{node.cond}"
      @code.wrap
      node.body.accept self unless node.body.nil?
      @code.unwrap
      @code << "end"
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
      @code.newline
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

    def visitBlock node
      puts "block"
      @code.newline

      node.caller.accept self

      @code << " do "

      @code << "|"
      node.args.accept self
      @code << "|"

      @code.newline
      node.body.accept self
      @code.newline
      @code << "end"
    end

    def visitArgs node
      puts "args"

      node.args.each_with_index do |arg,idx|
        if idx != 0
          @code << ", "
        end
        @code << arg.to_s
      end
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
      pp node
      @code << "#{node.children[1]}"
    end

    def visitSym node
      puts "sym"
      @code << ":#{node.value}"
    end
  end


end
