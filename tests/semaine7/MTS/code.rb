module MTS

  class Code

    attr_accessor :indent,:code

    def initialize indent=0
      @code=[""]
      @indent=indent
    end

    def <<(str)
      if @code.last.split.join(" ") == ""
        @code[-1] += "\t"*@indent + str
      else
        @code[-1] += str
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

    def get_source
      output = ""
      @code.each do |line|
        output += line + "\n"
      end
      output
    end

    def newline i = 1
      while i!= 0
        @code << "\t"*@indent
        i-= 1
      end
    end

    def size
      @code.size
    end


  end

end
