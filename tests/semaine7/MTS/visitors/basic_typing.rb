require_relative "./visitor"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  # on type chaque node. Pour la plupart, il s'agit simplement du nom de leur classe.
  # mais pour certaines nodes, un traitement est effectue
  class BasicTyping < Visitor
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
      node.type = nil
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
      node.type = nil
    end

    def visitDStr node
      puts "dstr"
      basic_type node
    end

    def visitLVar node
      puts "lvar"
      node.type = nil
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
      node.type = nil
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
