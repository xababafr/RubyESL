require_relative "./code"
require_relative "./visitor"
require_relative "./convert"

module NMTS


  class AddProbesVisitor < Visitor
    attr_reader :code

    def initialize
      @code = Code.new "    "
    end

    # returns the channel that corresponds to this inout
    # breaks ==> no doublons allowed
    def get_channel inout, channels
      ret = nil
      channels.each do |channel|
        if channel.from == inout || channel.to == inout
          ret = channel
          break
        end
      end
      ret
    end

    # def visitSystemCCode node
    #   @code < node.code
    # end

    def visitRoot node
      code << "require \"../MTS2/mts_dsl\""

      code.newline # for each module
      node.rootIterate.each do |moduleName, moduleHash|
        code << "class #{moduleName} < NMTS::Actor"
        code.newline
        code.wrap

        # define inouts
        moduleHash[:inouts].each do |inout|
          channel = get_channel inout, node.channels
          dir = ""
          if inout.dir == :input
            dir = "input"
          else
            dir = "output"
          end

          code << "#{dir} :#{inout.sym}"
        end

        #define threads
        code << "thread :#{node.threads[moduleName].join(', :')}"
        code.newline

        # then, go for the methods
        node.rootIterate[moduleName][:methods].each do |methodHash|
          methodHash[:ast].accept self
          code.newline
        end

        code.unwrap
        code << "end"
        code.newline 2
      end

      # constructor of the top System
      node.sysAst.accept self

    end

    def visitUnknown node
      code << "unknown(#{node})"
    end

    def visitMethod node
      @code << "def #{node.name} "
      node.args.accept self unless node.args.args.size < 1
      node.body.accept self unless node.body.nil?
      @code << "end"
    end

    def visitBody node
      #code << "body( #{node} )"
      if node.wrapperBody
        @code.wrap
        node.stmts.each do |el|
          if !el.nil?
            @code.newline
            el.accept self
          end
        end
        @code.unwrap
      else
        @code < "("
        node.stmts.each do |el|
          el.accept self unless el.nil? # add inline?
        end
        @code < ")"
      end

    end

    def visitAssign node
      # in systemC, we dont initialize arrays.
      #code << "assign( #{node} )"
      @code < node.lhs.to_s + " = "
      node.rhs.accept self unless node.rhs.nil?
    end

    def visitSuper node
      code << "super "
      node.args.accept self
    end

    def visitBlock node
      code << "block( #{node} )"
    end

    def visitArgs node
      code < "#{node.args.join(', ')}"
    end

    def visitOpAssign node
      #code << "OpAssign( #{node} )"
      @code < node.lhs.lhs.to_s + " #{node.mid}= "
      node.rhs.accept self unless node.rhs.nil?
    end

    def visitIf node
      #code << "If( #{node} )"
      @code << "if "
      node.cond.accept self
      node.body.accept self unless node.body.nil?
      @code << "else" unless node.else_.nil?
      node.else_.accept self unless node.else_.nil?
      @code << "end"
    end

    def visitWhile node
      #code << "While( #{node} )"
      @code < "while "
      node.cond.accept self
      node.body.accept self unless node.body.nil?
      @code << "end"
    end

    def visitFor node
      #code << "For( #{node} )"
      node.idx ||= "i"
      @code < "for #{node.idx} in "
      node.range.accept self
      node.body.accept self
      @code << "end"
    end

    def visitIRange node # <
      #code << "irange( #{node} )"
      node.lhs.accept self
      @code < ".."
      node.rhs.accept self
    end

    def visitERange node # <=
      #code << "erange( #{node} )"
      node.lhs.accept self
      @code < "..."
      node.rhs.accept self
    end

    def visitCase node
      code << "Case( #{node} )"
    end

    def visitWhen node
      code << "When( #{node} )"
    end

    def visitMCall node
      #code << "MCall( #{node} )"

      if node.caller.nil?
        @code < "#{node.method}("
      else
        node.caller.accept self
        @code < ".#{node.method}("
      end
      node.args.each_with_index do |arg,idx|
        if idx !=  0
          @code < ", "
        end
        arg.accept self
      end
      @code < ")"

    end

    def visitBlock node
      #code << "Block( #{node} )"
      pp node
      node.caller.accept self
      argsStr = node.args.args.join(',')
      afterDoStr = ""
      if node.args.args.size > 0
        afterDoStr = "|#{argsStr}|"
      end
      @code < " do #{afterDoStr}"
      node.body.accept self
      @code << "end"
    end

    def visitDStr node
      node.elements.each_with_index do |el,idx|
        if idx != 0
          @code < " + "
        end
        el.accept self unless el.nil?
        if !(el.is_a? StrLit)
          @code < ".to_s"
        end
      end
    end

    def visitAnd node
      #code << "And (#{node} )"
      @code < "("
      node.lhs.accept self
      @code < ") && ("
      node.rhs.accept self
      @code < ")"
    end

    def visitOr node
      #code << "Or( #{node} )"
      @code < "("
      node.lhs.accept self
      @code < ") || ("
      node.rhs.accept self
      @code < ")"
    end

    def visitTrue node
      #code << "True( #{node} )"
      @code < "true"
    end

    def visitFalse node
      #code << "False( #{node} )"
      @code < "false"
    end

    def visitIVar node
      #code << "LVar( #{node} )"
      code < "@#{node.name}"
    end

    def visitLVar node
      #code << "LVar( #{node} )"
      code < "#{node.name}"
    end

    def visitIntLit node
      #code << "IntLit( #{node} )"
      @code < "#{node.value}"
    end

    def visitFloatLit node
      #code << "FloatLit( #{node} )"
      @code < "#{node.value}"
    end

    def visitStrLit node
      #code << "StrLit( #{node} )"
      node.value = node.value.gsub("\n", '\n').gsub("\t", '\t') unless node.value.nil?
      @code < "\"#{node.value}\""
    end

    def visitAry node
      #code << "Ary( #{node} )"
      @code < "["
      node.elements.each_with_index do |el,idx|
        if idx !=  0
          @code < ", "
        end
        el.accept self
      end
      @code < "]"
    end

    def visitHsh node
      @code < "{"
      node.pairs.each_index do |i|
        @code < " => " unless i == 0
        node.pairs[i].accept self
      end
      @code < "}"
    end

    def visitPair node
      node.val.accept self
    end


    def visitRegExp node
      code << "RegExp( #{node} )"
    end

    def visitReturn node
      code << "return( #{node} )"
    end

    def visitConst node
      #code << "Const (#{node})"
      node.children.each do |child|
        if child.is_a?(Const)
          child.accept self
          @code < "::"
        end
      end
      @code < "#{node.children[1]}"
    end

    def visitSym node
      #code << "Sym( #{node} )"
      @code < ":#{node.value}"
    end
  end


end
