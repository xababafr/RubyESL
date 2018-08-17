module NMTS

  class Code

    attr_accessor :indent, :lines, :tabStr

    def initialize tab = "\t", indent=0
      @lines, @indent, @tabStr = [], indent, tab
    end

    def <(str)
      str = "#{str}"
      # if @lines[-1].is_a?(Integer)
      #   newline
      # end
      @lines[-1] << str
    end

    def <<(str)
      str = "#{str}"
      pp str
      @lines << str
    end

    def wrap
      @lines << ( +1 )
    end

    def unwrap
      @lines << ( -1 )
    end

    def del nb = 1
      @lines.pop nb
    end

    def source
      output = ""
      @lines.each do |line|
        if line.is_a?(Integer)
          @indent += line
        else
          output += (@tabStr*@indent) + line + "\n"
        end
      end
      output[0..-2]
    end

    def newline i = 1
      while i!= 0
        @lines << ""
        i-= 1
      end
    end

    def size
      @lines.size
    end

  end

end


if $PROGRAM_NAME == __FILE__
  # use << only when you can add the full line of code
  code = NMTS::Code.new "    "
  code << "require 'lul'"
  code << "def dada a,b"
  code.wrap
    code << "if a > b"
    code.wrap
      code << "a"
    code.unwrap
    code << "end"
    code << "b"
  code.unwrap
  code << "end"

  print code.source
end
