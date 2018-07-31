require_relative "./code"
require_relative "./visitor"

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

    def visitRoot node
      code << "#include <systemc.h>"
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

        print 'initParams : '
        print node.initParams

        # if there needs to be one, write the special constructor
        node.initParams.each do |idArray, paramsArray|
          klass, entity = idArray[0], idArray[1]
          if klass == moduleName && paramsArray.size > 1
            # same func as below with the sys's constructor
            paramStr = ""
            paramsArray.each_with_index do |par, idx|
              if idx != 0
                paramStr += ", void #{paramsArray[idx][1]}"
              end
            end
            code << "#{moduleName}(sc_module_name sc_m_name#{paramStr})"
            code << ": sc_module(sc_m_name) {"
            code.wrap
              code << "..."
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

        code << "..."

        code.unwrap
        code << "}"
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
      code << "SC_CTOR( sys )"
      code << ': clk_sig ("clk_sig", 10, SC_NS)'
      code << "{"
      code.wrap
      node.initParams.each do |idArray, paramsArray|
        klass, entity = idArray[0], idArray[1]
        paramStr = ""
        paramsArray.each_with_index do |par, idx|
          if idx != 0
            paramStr += ", void #{paramsArray[idx][1]}"
          end
        end
        code << "#{entity} = new #{klass}(\"#{entity}\"#{paramStr});"
        code << "#{entity}->clk( clk_sig );"

        # DOESNT WORK FOR NOW
        node.channels.each do |channel|
          if channel.from.sym == klass
            code << "#{entity}->#{channel.from.sym}( #{channel.name}  );"
          end
          if channel.to.sym == klass
            code << "#{entity}->#{channel.to.sym}( #{channel.name}  );"
          end
        end
        code.newline
      end
      code.unwrap
      code << "}"

      code.unwrap
      code << "}"
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

    def visitUnknown node
      raise NotImplementedError.new
    end

    def visitMethod node
      raise NotImplementedError.new
    end

    def visitBody node
      raise NotImplementedError.new
    end

    def visitAssign node
      raise NotImplementedError.new
    end

    def visitSuper node
      raise NotImplementedError.new
    end

    def visitIRange node
      raise NotImplementedError.new
    end

    def visitErange node
      raise NotImplementedError.new
    end

    def visitBlock node
      raise NotImplementedError.new
    end

    def visitArgs node
      raise NotImplementedError.new
    end

    def visitOpAssign node
      raise NotImplementedError.new
    end

    def visitIf node
      raise NotImplementedError.new
    end

    def visitWhile node
      raise NotImplementedError.new
    end

    def visitFor node
      raise NotImplementedError.new
    end

    def visitCase node
      raise NotImplementedError.new
    end

    def visitWhen node
      raise NotImplementedError.new
    end

    def visitMCall node
      raise NotImplementedError.new
    end

    def visitBlock node
      raise NotImplementedError.new
    end

    def visitArgs node
      raise NotImplementedError.new
    end

    def visitDStr node
      raise NotImplementedError.new
    end

    def visitAnd node
      raise NotImplementedError.new
    end

    def visitOr node
      raise NotImplementedError.new
    end

    def visitTrue node
      raise NotImplementedError.new
    end

    def visitFalse node
      raise NotImplementedError.new
    end

    def visitLVar node
      raise NotImplementedError.new
    end

    def visitIntLit node
      raise NotImplementedError.new
    end

    def visitFloatLit node
      raise NotImplementedError.new
    end

    def visitStrLit node
      raise NotImplementedError.new
    end

    def visitAry node
      raise NotImplementedError.new
    end

    def visitHsh node
      raise NotImplementedError.new
    end

    def visitRegExp node
      raise NotImplementedError.new
    end

    def visitReturn node
      raise NotImplementedError.new
    end

    def visitConst node
      raise NotImplementedError.new
    end

    def visitSym node
      raise NotImplementedError.new
    end
  end


end
