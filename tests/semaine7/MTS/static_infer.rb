require_relative "./visitor"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  # on type chaque node. Pour la plupart, il s'agit simplement du nom de leur classe.
  # mais pour certaines nodes, un traitement est effectue
  class StaticInfer < Visitor
    def basic_type node
      node.type = node.class.name
    end

    def visitRoot node
      puts "root"
      basic_type node
    end

    def visitUnknown node
        puts "unknown"
        basic_type node
    end

    def visitMethod node
      puts "method"
      basic_type node
    end

    def visitBody node
      puts "body"
      node.type = node.stmts[0].type
    end

    def visitAssign node
      puts "assign"
      # puts node.lhs
      # puts DATA.contexts
      # puts DATA.currentContext
      node.rhs.accept StaticInfer.new
      DATA.contexts[DATA.currentContext][node.lhs] = node.rhs.type
      node.type = node.rhs.type
    end

    def visitIf node
      puts "if"
      basic_type node
    end

    def visitWhile node
      puts "while"
      basic_type node
    end

    def visitFor node
      puts "for"
      basic_type node
    end

    def visitCase node
      puts "case"
      basic_type node
    end

    def visitWhen node
      puts "when"
      basic_type node
    end

    def visitMCall node
      puts "mcall"
      userDefinedMethod = false
      oldcontext = nil
      newContext = nil
      retType = nil
      node.caller.accept StaticInfer.new
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
        argsTypes << arg.type
      end

      if !userDefinedMethod

        callerType = node.caller.type
        # 'caller.methodname' 'argsTypes'
        puts "\n\n"
        puts callerType+"."+node.method.to_s

        # return the type corresponding the the signature
        retType = DATA.signatures[callerType+"."+node.method.to_s][argsTypes]

      else

        puts "userDefinedMethod"
        oldContext = DATA.currentContext.dup
        DATA.currentContext = newContext
        recursiveVisitor = StaticInfer.new
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
            met.accept recursiveVisitor
            puts "RETURN TYPES"
            pp DATA.returnTypes

            retType = DATA.returnTypes[DATA.currentContext]
          end
        end

        DATA.currentContext = oldContext
        pp DATA.currentContext

      end

      if retType.kind_of?(Array)
        node.type = retType.join(" | ")
      else
        node.type = retType
      end
    end

    def visitDStr node
      puts "dstr"
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
        el.accept StaticInfer.new
        cType = el.type
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
      puts "regexp"
      node.value.accept StaticInfer.new
      typ = node.value.type
      oldType = DATA.returnTypes[DATA.currentContext]
      if oldType != nil && oldType.size > 0
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
      pp DATA.returnTypes

      # we still only return the name's class
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
