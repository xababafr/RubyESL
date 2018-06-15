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

  # val is supposed to be an array of symbols like #Float
  class UnionType < Type
    def to_s
      @val.join(' | ')
    end
  end

  class TypeFactory
    def self.create val
      if (val.is_a? Array)
        if (val.size > 1)
          UnionType.new val
        else
          SingleType.new val
        end
      else
        SingleType.new [val]
      end
    end
  end

end
