require_relative "./code"
require_relative "./visitor"
require_relative "./convert"

module NMTS


  class SystemC < Visitor
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

    def visitSystemCCode node
      @code < node.code
    end

    def visitUnknown node
      code << "unknown( #{node} )"
    end

    def visitMethod node
      #code << "method( #{node} )"
      argsStr = ""
      if node.args.size > 0
        # create the argsStr
      end
      @code << "#{node.returnType.cpp_signature}#{node.name} (#{argsStr})"
      node.body.toDeclare = node.toDeclare
      node.body.accept self unless node.body.nil?
    end

    def visitBody node
      #code << "body( #{node} )"
      if node.wrapperBody

        @code << "{"
        @code.wrap

        if node.toDeclare.keys.size > 0
          node.toDeclare.each do |localVarName, localVarArr|
            @code << localVarArr[1].cpp_signature(localVarName)
            code < ";"
          end
          @code.newline
        end

        node.stmts.each do |el|
          if !el.nil?
            @code.newline
            el.accept self
            if !( ([For, If, While, Case, Super]).include?(el.class) )
              @code < ";"
            end
          end
        end
        @code.unwrap
        @code << "}"

      else

        @code < "("
        node.stmts.each do |el|
          el.accept self unless el.nil?
        end
        @code < ")"
      end

    end

    def visitAssign node
      # in systemC, we dont initialize arrays.
      if !node.rhs.is_a?(Ary)
        #code << "assign( #{node} )"
        if node.lhs.to_s[0] == "@"
          @code < node.lhs.to_s[1..-1] + " = "
        else
          @code < node.lhs.to_s + " = "
        end
        node.rhs.accept self unless node.rhs.nil?
      end
    end

    def visitSuper node
      #code << "super( #{node} )"
      @code.del
    end

    def visitBlock node
      code << "block( #{node} )"
    end

    def visitArgs node
      code << "args( #{node} )"
    end

    def visitOpAssign node
      #code << "OpAssign( #{node} )"
      @code < node.lhs.lhs.to_s + " #{node.mid}= "
      node.rhs.accept self unless node.rhs.nil?
    end

    def visitIf node
      #code << "If( #{node} )"
      @code < "if "
      pp node.cond
      node.cond.accept self
      node.body.accept self unless node.body.nil?
      @code.newline
      @code < "else" unless node.else_.nil?
      node.else_.accept self unless node.else_.nil?
    end

    def visitWhile node
      #code << "While( #{node} )"
      @code < "while "
      node.cond.accept self
      node.body.accept self unless node.body.nil?
    end

    def visitFor node
      #code << "For( #{node} )"
      node.idx ||= "i"
      @code < "for("
      node.range.accept self
      @code < ")"
      node.body.accept self
    end

    def visitIRange node # <
      #code << "irange( #{node} )"
      @code < "int #{node.idx} = "
      node.lhs.accept self
      @code < "; #{node.idx} < "
      node.rhs.accept self
      @code < "; #{node.idx}++"
    end

    def visitERange node # <=
      #code << "erange( #{node} )"
      @code < "int #{node.idx} = "
      node.lhs.accept self
      @code < "; #{node.idx} <= "
      node.rhs.accept self
      @code < "; #{node.idx}++"
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

    end

    def visitDStr node
      node.elements.each_with_index do |el,idx|
        if idx != 0
          @code < " << "
        end

        # if !(el.is_a? StrLit)
        #   @code < "std::to_string("
        # end

        el.accept self unless el.nil?

        # if !(el.is_a? StrLit)
        #   @code < ")"
        # end
      end
    end

    def visitAnd node
      #code << "And (#{node} )"
      @code < "( "
      node.lhs.accept self
      @code < " ) && ( "
      node.rhs.accept self
      @code < " )"
    end

    def visitOr node
      #code << "Or( #{node} )"
      @code < "( "
      node.lhs.accept self
      @code < " ) || ( "
      node.rhs.accept self
      @code < " )"
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
      code < "#{node.name}"
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
      @code < "{"
      node.elements.each_with_index do |el,idx|
        if idx !=  0
          @code < ", "
        end
        el.accept self
      end
      @code < "}"
    end

    def visitRoot node
      code << "#include <systemc.h>"
      code << "#include <iostream>"
      code << "#include <string>"
      code.newline # for each module
      node.rootIterate.each do |moduleName, moduleHash|
        code << "SC_MODULE( #{moduleName} ) {"
        code.newline
        code.wrap

        # define vars and inouts
        code << "// clock"
        code << "sc_in<bool> clk;"
        code.newline

        code << "// inouts"
        moduleHash[:inouts].each do |inout|
          channel = get_channel inout, node.channels
          dir = ""
          if inout.dir == :input
            dir = "sc_in"
          else
            dir = "sc_out"
          end

          code << "#{dir}< #{channel.type.cpp_signature} > #{inout.sym};"
        end
        code.newline

        code << "// ivars"
        puts "IVARS"
        node.instanceVars[moduleName].each do |iname, itype|
          code << itype.cpp_signature(iname) + ";"
        end
        code.newline

        # print 'initParams : '
        # print node.initParams

        # if there needs to be one, write the special constructor
        node.initParams.each do |idArray, paramsArray|
          klass, entity = idArray[0], idArray[1]
          if klass == moduleName && paramsArray.size > 1 && paramsArray[1][0] != :rest
            # same func as below with the sys's constructor
            paramStr = ""
            paramsArray.each_with_index do |par, idx|
              if idx != 0
                paramStr += ", #{paramsArray[idx][2][:typ].cpp_signature(paramsArray[idx][1])}"
              end
            end
            code << "#{moduleName}(sc_module_name sc_m_name#{paramStr})"
            code << ": sc_module(sc_m_name) {"
            code.wrap
              code.newline
              node.rootIterate[moduleName][:methods].each do |methodHash|
                if methodHash[:name] == :initialize
                  methodAst = methodHash[:ast]

                  pp methodAst

                  # we go throught this one indirectly, to get rid of unecessary body wrapping
                  visitor = SystemC.new
                  visitor.code.indent = code.indent + 1
                  visitor.code << ""
                  methodAst.accept visitor
                  src = visitor.code.source
                  src = src.split("{")[1..-1].join("{")
                  src = src.split("}")[0..-1].join("}")

                  sysc = SystemCCode.new "#{src}"
                  sysc.accept self
                end
              end
              code.newline
              node.threads[moduleName].each do |thread|
                code << "SC_CTHREAD( #{thread}, clk.pos() );"
              end
            code.unwrap
            code << "}"
          end
        end
        code.newline

        # write the standart constructor
        code << "SC_CTOR( #{moduleName} ) {"
        code.wrap
        node.threads[moduleName].each do |thread|
          code << "SC_CTHREAD( #{thread}, clk.pos() );"
        end
        code.unwrap
        code << "};"
        code.newline

        node.threads[moduleName].each do |thread|
          #code << "void #{thread}() {"
          # then we start visiting recursively the methods to print the sysc code
          node.rootIterate[moduleName][:methods].each do |methodHash|
            if methodHash[:name] == thread
              # save the local vars to declare
              methodHash[:ast].toDeclare = node.localVars[moduleName][thread]
              methodHash[:ast].accept self
            end
          end
        end
        code.newline

        code << "..."

        code.unwrap
        code << "};"
        code.newline
      end
      code.newline # end of all modules

      code << "SC_MODULE( System ) {"
      code.wrap

      # create the vars containing the entities
      code << "//entities"
      node.initParams.each do |idArray, paramsArray|
        klass, entity = idArray[0], idArray[1]
        code << "#{klass} *#{entity};"
      end
      code.newline

      # create the signals and the clock
      code << "// signals"
      node.channels.each do |channel|
        code << "sc_signal< #{channel.type.cpp_signature()} > #{channel.name};"
      end
      code << "sc_clock clk_sig;"
      code.newline

      # constructor of the top System
      code << "SC_CTOR( System )"
      code << ': clk_sig ("clk_sig", 10, SC_NS)'
      code << "{"
      code.wrap
      node.initParams.each do |idArray, paramsArray|
        klass, entity = idArray[0], idArray[1]
        paramStr, initStr = "", []
        paramsArray.each_with_index do |par, idx|
          if idx != 0 && paramsArray[idx][0] != :rest
            paramStr += ", #{paramsArray[idx][1]}"

            # argHash
            initStr << "#{paramsArray[idx][2][:typ].cpp_signature(paramsArray[idx][1])} = #{Convert::value(paramsArray[idx][2][:val])};"
          end
        end
        initStr.each do |iStr|
          code << iStr
        end
        code << "#{entity} = new #{klass}(\"#{entity}\"#{paramStr});"
        code << "#{entity}->clk( clk_sig );"

        node.channels.each do |channel|
          if channel.from.klass == klass
            code << "#{entity}->#{channel.from.sym}( #{channel.name}  );"
          end
          if channel.to.klass == klass
            code << "#{entity}->#{channel.to.sym}( #{channel.name}  );"
          end
        end
        code.newline
      end
      code.unwrap
      code << "}"
      code.newline

      code << "~System(){"
      code.wrap
      node.initParams.each do |idArray, paramsArray|
        klass, entity = idArray[0], idArray[1]
        code << "delete #{entity};"
      end
      code.unwrap
      code << "}"

      code.unwrap
      code << "};"
      code.newline

      # main
      code << "System *sys = NULL;"
      code.newline
      code << "// main"
      code << "int sc_main(int, char* [])"
      code << "{"
      code.wrap
        code << 'sys = new System("sys");'
        code << "sc_start();"
        code << "return 0;"
      code.unwrap
      code << "}"
    end

    def visitHsh node
      code << "Hsh( #{node} )"
    end

    def visitRegExp node
      code << "RegExp( #{node} )"
    end

    def visitReturn node
      code << "Return( #{node} )"
    end

    def visitConst node
      #code << "Const (#{node})"
      @code < "#{node.children[1]}"
    end

    def visitSym node
      #code << "Sym( #{node} )"
      @code < ":#{node.value}"
    end
  end


end
