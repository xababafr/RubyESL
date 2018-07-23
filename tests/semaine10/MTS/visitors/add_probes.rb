require_relative "./pretty_printer"
require_relative "./code"

module MTS


  # un prettyPrinter, mais qui ajoute aussi les calls a register(:a, a)
  class AddProbes < PrettyPrinter

    def visitMCall node
      puts "mcall"
      pp node
      @code.newline

      # we disable the registercalls during the method call
      @code.disable

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

      @code.enable

      if !(node.name.nil?)
        @code.addRegisterCall node.name, @code.size
      end

      # we ignore pointers ( = fonctions that alter the args you pass in)
      #node.args.each do |arg|
      #  @code.addRegisterCall arg, @code.size
      #end

    end

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

    def visitIf node
      puts "if"

      @code.disable

      @code.newline
      @code << "if ("
      node.cond.accept self
      @code << ")"

      @code.enable

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

  end

  def visitWhile node
    puts "while"
    pp node
    @code.newline

    @code.enable

    @code << "while( "
    node.cond.accept self
    @code << " )"

    @code.disable

    @code.wrap
    node.body.accept self unless node.body.nil?
    @code.unwrap
    @code << "end"
  end

end
