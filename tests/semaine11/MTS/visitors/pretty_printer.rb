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

      @code << "require '../MTS/mts_actors_model'"
      @code.newline 2

      # for each class
      node.classes.each do |klass,methods|
        @code << "class #{klass}"
        oredered_actors_classes = node.ordered_actors.map { |a| a.class.to_s }
        puts "ORDERED CLASSES"
        pp oredered_actors_classes
        if oredered_actors_classes.uniq.include?(klass.to_s)
          @code << " < MTS::Actor"
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
        @code << "input " unless inputs.size == 0
        inputs.uniq.each_with_index do |input,idx|
          if idx != 0
            @code << ", "
          end
          @code << ":#{input}"
        end
        @code.newline
        @code << "output " unless outputs.size == 0
        outputs.uniq.each_with_index do |output,idx|
          if idx != 0
            @code << ", "
          end
          @code << ":#{output}"
        end
        @code.newline

        @code.newline

        # go for each method
        methods.each do |methArray|
          #code << methArray[0].to_s + "\n"
          methArray[1].accept self
        end

        @code.unwrap
        @code.newline 2
        @code << "end"
        @code.newline 2

        #puts "KOUKOUUUUUU"
        #pp node
        #pp node.connexions

      end

      # now we have sys.blockStr to print the block's content easily

      # if !node.connexions.nil?
      #   @code << "sys=MTS::System.new('sys1') do"
      #   @code.wrap
      #
      #   node.ordered_actors.each do |actor|
      #     @code << "#{actor.name} = #{actor.class}.new('#{actor.name}')\n"
      #   end
      #
      #   @code << "set_actors(["
      #   node.ordered_actors.each_with_index do |actor,idx|
      #     if idx != 0
      #       @code << ","
      #     end
      #     @code << actor.name
      #   end
      #   @code << "])\n"
      #
      #   node.connexions.each do |conx|
      #     #@code << "connect(#{conx})"
      #     @code << "connect_as(:#{conx[0][:moc]}, #{conx[0][:ename]}.#{conx[0][:port]} => #{conx[1][:ename]}.#{conx[1][:port]})\n"
      #   end
      #   @code.unwrap
      #   @code << "end"
      #
      # end

      @code.newline 2
      @code << 'sys=MTS::System.new'+node.blockStr

      # then we create the sys objet
    end

    # def visitRoot node
    #   puts "root"
    #   pp node
    #
    #   @code << "require '../MTS/mts_actors_model'"
    #   @code.newline 2
    #
    #   #should work fine, the sorting is made on the
    #   iterate_on = node.methods.keys.sort!
    #   #node.methods.sort!
    #   previous = ""
    #   iterate_on.each do |mname|
    #     puts "=================#{mname.to_s}=================="
    #     #if mname[1] == :behavior
    #     DATA.currentContext = mname
    #
    #     if previous != mname[0].to_s
    #       previous = mname[0].to_s
    #       @code << "class #{mname[0]} < MTS::Actor"
    #       @code.newline 2
    #       @code.wrap
    #     end
    #
    #     node.methods[mname].accept self # unless method.nil?
    #
    #     if previous != mname[0].to_s
    #       @code.unwrap
    #       @code.newline 2
    #       @code << "end"
    #       @code.newline 2
    #     end
    #     #end
    #   end
    #
    #   @code.unwrap
    #   @code.newline 2
    #   @code << "end"
    #
    #   @code.newline 2
    #   @code << "sys=MTS::System.new('sys1') do \n  sensor_1 = Sensor.new('sens1')\nend"
    #
    # end

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

    # def visitBody node
    #   puts "body"
    #   @code << "("
    #   if node.methodBody
    #     @code.newline
    #   end
    #   node.stmts.each do |el|
    #     el.accept self unless el.nil?
    #   end
    #   if node.methodBody
    #     @code.newline
    #   end
    #   @code << ")"
    # end

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
      @code << "while( "
      node.cond.accept self
      @code << " )"
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

    def visitIRange node
      puts "irange"
      #@code << "(IRANGE : (lhs : #{node.lhs}, rhs : #{node.rhs}))"
      @code << "("
      node.lhs.accept self
      @code << ".."
      node.rhs.accept self
      @code << ")"
    end

    def visitERange node
      puts "erange"
      @code << "("
      node.lhs.accept self
      @code << "..."
      node.rhs.accept self
      @code << ")"
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

    def visitAnd node
      puts "and"
      @code << "( "
      node.lhs.accept self
      @code << " ) && ( "
      node.rhs.accept self
      @code << " )"
    end

    def visitOr node
      puts "or"
      @code << "( "
      node.lhs.accept self
      @code << " ) || ( "
      node.rhs.accept self
      @code << " )"
    end

    def visitTrue node
      @code << "true"
    end

    def visitFalse node
      @code << "false"
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
