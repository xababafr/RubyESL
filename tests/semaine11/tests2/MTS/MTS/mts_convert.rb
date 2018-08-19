require_relative "../mts_objects"
require_relative "./systemc"

module NMTS

  # this class contains only static methods
  # goal : make the necessary conversions betwween ruby and cpp
  # signatures are already handled by TypesObjs.
  # structures like For, While will be handled in the visitor.
  # Anything else is handled here. Ex : Convert::value([1,2]) ==> "{1,2}"
  class Convert
    def self.value val #variable => variable's str code
        # supported types : Bool, Int, Float, String, Arrays
        if val.is_a?(Array)
          val.to_s.gsub("[", "{").gsub("]", "}")
        else
          val.to_s
        end
    end

    def self.node astNode
      puts ""
      print "converting..."
      puts ""
      print astNode.class
      case astNode
      when MCall
        self.mcall(astNode)

      else
        astNode

      end
    end

    def self.mcall astNode
      puts "MCALL"
      pp astNode

      case astNode.method
      when :puts
        visitor = SystemC.new
        visitor.code << ""
        astNode.args[0].accept visitor
        scode = "cout << #{visitor.code.source} << endl"
        SystemCCode.new scode

      when :read
        SystemCCode.new "#{astNode.args[0].value}.read()"

      when :write
        visitor = SystemC.new
        visitor.code << ""
        astNode.args[0].accept visitor
        SystemCCode.new "#{astNode.args[1].value}.write(#{visitor.code.source})"

      when :<, :>, :<=, :>=, :==, :+, :-, :/, :*, :%, :**
        visitor = SystemC.new
        visitor.code << ""
        astNode.caller.accept visitor
        visitor.code < ( " " + astNode.method.to_s + " " )
        astNode.args[0].accept visitor
        SystemCCode.new "#{visitor.code.source}"

      when :[]
        visitor = SystemC.new
        visitor.code << ""
        astNode.caller.accept visitor
        visitor.code < "["
        astNode.args[0].accept visitor
        visitor.code < "]"
        LVar.new "#{visitor.code.source}"

      when :[]=
        visitor = SystemC.new
        visitor.code << ""
        astNode.caller.accept visitor
        visitor.code < "["
        astNode.args[0].accept visitor
        visitor.code < "]"
        Assign.new visitor.code.source, astNode.args[1]

      when :stop
        astNode.method = :sc_stop
        astNode

      else
        astNode
      end
    end

  end

end
