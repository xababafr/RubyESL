require_relative "./visitor"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  class StaticInfer < Visitor
    def basic_type node
      node.type = node.class.name
    end

    def visitRoot node
      puts "root"
      node.methods.each do |mname, method|
        puts "=================#{mname.to_s}=================="
        if mname[1] == :behavior
          DATA.currentContext = mname
          method.accept self # unless method.nil?
        end
      end
    end

    def visitUnknown node
      puts "unknown"
      basic_type node
    end

    def visitMethod node
      puts "method"
      node.body.accept self unless node.body.nil?
      basic_type node
    end

    def visitBody node
      puts "body"
      node.stmts.each do |el|
        el.accept self unless el.nil?
      end
      node.type = node.stmts[0].accept self
    end

    def visitAssign node
      puts "assign"
      node.rhs.accept self unless node.rhs.nil?
      node.type = DATA.contexts[DATA.currentContext][node.lhs] = node.rhs.accept self
    end

    def visitIf node
      puts "if"
      node.body.accept self unless node.body.nil?
      node.else_.accept self unless node.else_.nil?
      basic_type node
    end

    def visitWhile node
      puts "while"
      node.body.accept self unless node.body.nil?
      basic_type node
    end

    def visitFor node
      puts "for"
      node.body.accept self unless node.body.nil?
      basic_type node
    end

    def visitCase node
      puts "case"
      node.whens.accept self unless node.whens.nil?
      node.else_.accept self unless node.else_.nil?
      basic_type node
    end

    def visitWhen node
      puts "when"
      node.body.accept self unless node.body.nil?
      basic_type node
    end

    def visitMCall node
      puts "mcall"
      userDefinedMethod = false
      oldcontext = nil
      newContext = nil
      retType = nil
      DATA.contexts.keys.each do |key|
        # for now, we just check with the name
        # if we are a user defined method :
        if key[1] == node.method
          userDefinedMethod = true
          newContext = key
        end
      end
      argsTypes = []
      node.args.each do |arg|
        argsTypes << arg.accept(self)
      end

      if !userDefinedMethod

        puts "/////////#{node.method}/////////////"
        #puts "/////////#{node.caller.accept(self)}/////////////"
        callerType = node.caller.accept(self) unless node.caller.nil?
        # 'caller.methodname' 'argsTypes'
        puts "\n\n"
        puts callerType.to_s+"."+node.method.to_s
        puts argsTypes

        # return the type corresponding the the signature
        retType = DATA.signatures[callerType.to_s+"."+node.method.to_s][argsTypes]

      else

        puts "userDefinedMethod"
        oldContext = DATA.currentContext.dup
        DATA.currentContext = newContext
        #pp DATA.methods
        DATA.methods.values.each do |met|
          if met.name == node.method
            # define the context for the method
            for i in (0...met.args.size)
              DATA.contexts[newContext][met.args[i]] = argsTypes[i]
            end

            puts "newContext"
            pp DATA.contexts

            # then explore it
            met.accept self
            puts "RETURN TYPES"
            pp DATA.returnTypes

            retType = DATA.returnTypes[DATA.currentContext]
          end
        end

        DATA.currentContext = oldContext
        pp DATA.currentContext

      end

      if retType.kind_of?(Array)
        retType.join(" | ")
      else
        retType
      end
    end

    def visitDStr node
      puts "dstr"
      node.elements.each do |el|
        el.accept self unless el.nil?
      end
      basic_type node
    end

    def visitLVar node
      puts "lvar"
      node.type = DATA.contexts[DATA.currentContext][node.name]
    end

    def visitIntLit node
      puts "intlit"
      basic_type node
    end

    def visitFloatLit node
      puts "floatlit"
      basic_type node
    end

    def visitStrLit node
      puts "strlit"
      basic_type node
    end

    def visitIRange node
      puts "irange"
      basic_type node
    end

    def visitAry node
      puts "ary"
      types = []
      node.elements.each do |el|
        cType = el.accept self
        unless types.include? cType
          types << cType
        end
      end
      node.type = ("#{node.class.name}[#{types.size}][#{types.join(" | ")}]")
    end

    def visitHsh node
      puts "hsh"
      basic_type node
    end

    def visitRegExp node
      puts "regexp"
      basic_type node
    end

    def visitReturn node
      puts "return"
      node.value.accept self unless node.value.nil?
      typ = node.value.accept self
      oldType = DATA.returnTypes[DATA.currentContext]
      if oldType.size > 0
        union = true
        oldType.each do |type|
          if type == typ
            union = false
          end
        end
        if union
          DATA.returnTypes[DATA.currentContext] << typ
        end
      else
        DATA.returnTypes[DATA.currentContext] << typ
      end
      puts "RETURN TYPE REACHED"
      #pp DATA.returnTypes
      basic_type node
    end

    def visitConst node
      puts "const"
      basic_type node
    end

    def visitSym node
      puts "sym"
      basic_type node
    end
  end


end
