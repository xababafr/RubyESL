module MTS

  class Code

    attr_accessor :indent,:code, :registerCalls

    def initialize indent=0
      @code=[""]
      @indent=indent
      # a hash withthe key being the name number of a line where one or more registerCalls must be made
      # the key is an array containing all the vars in need of registerCalls
      # it's not really some line number, but more of a @code index instead  
      @registerCalls = {}
    end

    def <<(str)
      if @code.last.split.join(" ") == ""
        @code[-1] += "  "*@indent + str
      else
        @code[-1] += str
      end
    end

    def addRegisterCall symbol, line
      @registerCalls[line] ||= []
      @registerCalls[line] << symbol
      @registerCalls[line].uniq!
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
        print "LINE : #{line}"

        # we suppose that jeys are oredered in the good way. It should be.
        varsArray.each do |var|
          @code.insert ((line)+offset) , "register(:#{var},#{var})"
        end
        offset+=varsArray.size
      end
    end

    def get_source
      output = ""
      includeRegisterCalls()
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
