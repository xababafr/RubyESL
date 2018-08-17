module MTS

  class Code

    attr_accessor :indent,:code, :registerCalls

    def initialize indent=0
      @code=[""]
      @disabled = 0
      @indent=indent
      # a hash withthe key being the name number of a line where one or more registerCalls must be made
      # the key is an array containing all the vars in need of registerCalls
      # it's not really some line number, but more of a @code index instead
      @registerCalls = {}
    end

    def disable
      @disabled -= 1
    end

    def enable
      @disabled += 1
    end

    def register_allowed?
      (@disabled == 0)
    end

    # adds str to the current line of code
    def <(str)
      @code[-1] += str
    end

    # create a new line of code that contains str
    def <<(str)
      if @code.last.split.join(" ") == ""
        @code[-1] += "  "*@indent + str
      else
        @code[-1] += str
      end
    end

    def addRegisterCall symbol, line
      if register_allowed?
        @registerCalls[line] ||= []
        @registerCalls[line] << symbol
        @registerCalls[line].uniq!
      end
    end

    def wrap
      @indent +=1
      newline
    end

    def unwrap
      @indent -= 1
      newline
    end

    def includeRegisterCalls
      offset = 0
      @registerCalls.each do |line,varsArray|
        #print "LINE : #{line}"

        # we suppose that jeys are oredered in the good way. It should be.
        varsArray.each do |var|
          @code.insert ((line)+offset) , "register(:#{var},#{var})"
        end
        offset+=varsArray.size
      end
    end

    def get_source includeRegisterCalls = true
      output = ""
      includeRegisterCalls() unless !includeRegisterCalls
      @code.each_with_index do |line|
        output += line + "\n"
      end
      output
    end

    def newline i = 1
      while i!= 0
        @code << "  "*@indent
        i-= 1
      end
    end

    def size
      @code.size
    end


  end

end
