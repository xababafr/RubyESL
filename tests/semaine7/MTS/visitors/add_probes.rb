require_relative "./pretty_printer"
require_relative "./code"

module MTS


  # un prettyPrinter, mais qui ajoute aussi les calls a register(:a, a)
  class AddProbes < PrettyPrinter

    def visitLVar node
      puts "lvar"
      @code << node.name.to_s
      @code.addRegisterCall node.name, @code.size
    end

    def visitAssign node
      puts "assign"
      @code.newline
      @code << node.lhs.to_s + " = "
      node.rhs.accept self unless node.rhs.nil?
      @code.addRegisterCall node.lhs, @code.size
      @code.newline
    end

  end

end
