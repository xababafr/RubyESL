module MTS

  class Behaviour
    def behaviour
      raise NotImpelementedError.new
    end
  end

  class DefaultBehaviour < Behaviour
    def behaviour
      Proc.new {
        self.class.name
      }
    end
  end

  class BodyBehaviour < Behaviour
    def behaviour
      Proc.new {
        @stmts[0].get_type
      }
    end
  end

  class AssignBehaviour < Behaviour
    def behaviour
      Proc.new {
        DATA.contexts[DATA.currentContext][@lhs] = @rhs.get_type
      }
    end
  end

  class MCallBehaviour < Behaviour
    def behaviour
      Proc.new {
        userDefinedMethod = false
        oldcontext = nil
        newContext = nil
        retType = nil
        DATA.contexts.keys.each do |key|
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
          retType = DATA.signatures[callerType+"."+@method.to_s][argsTypes]

        else

          puts "userDefinedMethod"
          oldContext = DATA.currentContext.dup
          DATA.currentContext = newContext
          recursiveVisitor = BasicVisitor.new
          #pp DATA.methods
          DATA.methods.values.each do |met|
            if met.name == @method
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
          retType.join(" | ")
        else
          retType
        end
      }
    end
  end

  class LVarBehaviour < Behaviour
    def behaviour
      Proc.new {
        DATA.contexts[DATA.currentContext][@name]
      }
    end
  end

  class AryBehaviour < Behaviour
    def behaviour
      Proc.new {
        types = []
        @elements.each do |el|
          cType = el.get_type
          unless types.include? cType
            types << cType
          end
        end
        ("#{self.class.name}[#{types.size}][#{types.join(" | ")}]")
      }
    end
  end

  class ReturnBehaviour < Behaviour
    def behaviour
      Proc.new {
        typ = @value.get_type
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
        pp DATA.returnTypes
      }
    end
  end

end
