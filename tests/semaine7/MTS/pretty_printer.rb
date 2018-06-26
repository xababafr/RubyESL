require_relative "./visitor"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  class PrettyPrinter < Visitor
    def visitRoot node
      puts "root"
    end

    def visitUnknown node
        puts "unknown"
    end

    def visitMethod node
      puts "method"
    end

    def visitBody node
      puts "body"
    end

    def visitAssign node
      puts "assign"
    end

    def visitIf node
      puts "if"
    end

    def visitWhile node
      puts "while"
    end

    def visitFor node
      puts "for"
    end

    def visitCase node
      puts "case"
    end

    def visitWhen node
      puts "when"
    end

    def visitMCall node
      puts "mcall"
    end

    def visitDStr node
      puts "dstr"
    end

    def visitLVar node
      puts "lvar"
    end

    def visitIntLit node
      puts "intlit"
    end

    def visitFloatLit node
      puts "floatlit"
    end

    def visitStrLit node
      puts "strlit"
    end

    def visitIRange node
      puts "irange"
    end

    def visitAry node
      puts "ary"
    end

    def visitHsh node
      puts "hsh"
    end

    def visitRegExp node
      puts "regexp"
    end

    def visitReturn node
      puts "return"
    end

    def visitConst node
      puts "const"
    end

    def visitSym node
      puts "sym"
    end
  end


end
