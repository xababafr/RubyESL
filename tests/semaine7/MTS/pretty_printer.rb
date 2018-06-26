require_relative "./visitor"

module MTS


  # on separe le traitement a faire sur chaque node de la maniere dont les parcourir
  class PrettyPrinter < Visitor
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
    end

    def visitMethod node
      puts "method"
      node.body.accept self unless node.body.nil?
    end

    def visitBody node
      puts "body"
      node.stmts.each do |el|
        el.accept self unless el.nil?
      end
    end

    def visitAssign node
      puts "assign"
      node.rhs.accept self unless node.rhs.nil?
    end

    def visitIf node
      puts "if"
      node.body.accept self unless node.body.nil?
      node.else_.accept self unless node.else_.nil?
    end

    def visitWhile node
      puts "while"
      node.body.accept self unless node.body.nil?
    end

    def visitFor node
      puts "for"
      node.body.accept self unless node.body.nil?
    end

    def visitCase node
      puts "case"
      node.whens.accept self unless node.whens.nil?
      node.else_.accept self unless node.else_.nil?
    end

    def visitWhen node
      puts "when"
      node.body.accept self unless node.body.nil?
    end

    def visitMCall node
      puts "mcall"
    end

    def visitDStr node
      puts "dstr"
      node.elements.each do |el|
        el.accept self unless el.nil?
      end
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
      node.value.accept self unless node.value.nil?
    end

    def visitConst node
      puts "const"
    end

    def visitSym node
      puts "sym"
    end
  end


end
