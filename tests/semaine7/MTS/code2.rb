module MTS

  class Code

    attr_accessor :indent,:code

    def initialize indent=0
      @code=[]
      @indent=indent
    end

    def <<(str)
      if str.is_a? Code
        @indent += 4
        str.code.each do |line|
          @code << " "*@indent+line
        end
        @indent -= 4
      elsif str.is_a? Array
        str.each do |kode|
          @code << kode
        end
      elsif str.nil?
      else
        @code << " "*@indent+str
      end
      return @code
    end

    def finalize dot=false
      if dot
        return @code.join('\n')
      end
      @code.join("\n") if @code.any?
    end

    def newline
      @code << " "
    end

    def save_as filename,verbose=true,sep="\n"
      str=self.finalize
      File.open(filename,'w'){|f| f.puts(str)}
      puts "saved code in file #{filename}" if verbose
      return filename
    end

    def size
      @code.size
    end


  end

end
