module NMTS

  class Code

    attr_reader :indent, :lines, :tabStr

    def initialize tab = "\t", indent=0
      @lines, @indent, @tabStr = [], indent, tab
    end

    def <<(str)
      @lines << str unless ( !str.is_a?(String) )
    end

    def wrap
      @lines << ( +1 )
    end

    def unwrap
      @lines << ( -1 )
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
      output
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
