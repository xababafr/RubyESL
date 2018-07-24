require_relative "./pretty_printer"
require_relative "./code"

module MTS


  # un prettyPrinter, mais qui ajoute aussi les calls a register(:a, a)
  class DynamicInfer < PrettyPrinter

    attr_accessor :currentClass

    def visitRoot node
      puts "root"
        # go for each method
        node.classes.each do |klass,methods|
          methods.each do |methArray|
            # i still reason with classes since I have to nest the AST, whihch doesnt represents entities
            node.ordered_actors.each do |entity|
              if entity.class.to_s == klass.to_s
                @currentClass = entity.name.to_sym
              end
            end
            methArray[1].accept self
          end
        end
        @code = Code.new

    end

    def visitLVar node
      puts "lvar"

      # puts "CURRENTCLASS"
      # pp @currentClass
      # pp DATA.dynTypes[:VARIABLES]

      if !DATA.dynTypes[:VARIABLES][@currentClass][node.name].nil?
        node.type = DATA.dynTypes[:VARIABLES][@currentClass][node.name]
      else
        node.type = "Not Typed"
      end

    end

    def visitAssign node
      puts "assign"
      node.rhs.accept self unless node.rhs.nil?

      puts "VARRR"
      pp DATA.dynTypes[:VARIABLES]

      if !DATA.dynTypes[:VARIABLES][@currentClass][node.lhs].nil?
        node.type = DATA.dynTypes[:VARIABLES][@currentClass][node.lhs]
      else
        node.type = "Not Typed"
      end

    end

  end

end
