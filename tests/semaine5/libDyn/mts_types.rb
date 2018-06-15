module MTS

  class Type
    attr_reader :val

    def initialize val
      @val = val
    end
  end

  # val is supposed to be a symbol like :Integer
  class SingleType < Type
    def to_s
      @val.to_s
    end

    def is_core?
      [Integer, Float, String, Boolean].include? @val.class
    end
  end

  class ArrayType < Type
    def initialize val, size
      @val = val
      @size = size
    end

    def to_s
      "Array(#{size})[#{@val.join(' | ')}]"
    end

    def is_core?
      true
    end
  end

  # val is supposed to be an array of symbols like #Float
  # you CANNOT be a union of Arrays and Single types
  class UnionType < Type
    def to_s
      @val.join(' | ')
    end
  end

  class TypeFactory
    def self.create val, size = 1
      if (val.is_a? Array)
        if (val.size > 1)
          UnionType.new val
        elsif (val.size == 1) && (val[0].is_a? Array)
          ArrayType.new val[0], size
        else
          SingleType.new val
        end
      else
        SingleType.new [val]
      end
    end
  end

end
