module MTS

  class Type
    def signature
      "notImplemented"
    end

    def cpp_signature
      signature()
    end
  end

  class SingleType < Type
    attr_reader :type

    def signature
        @type.to_s
    end

    # a single value
    def initialize value
        @type = value.class
    end
  end

    class UnionType < Type
        attr_reader :subTypes

        def signature
            signatures = []
            @subTypes.each do |type|
                signatures << type.signature
            end
            signatures.uniq.join(' | ')
        end

        # one or more values
        def initialize values
            subTypes,subSignatures = [], []
            values.each do |v|
                type = TypeFactory::genType(v)
                if !(subSignatures.include?(type.signature))
                    subSignatures << type.signature
                    subTypes << type
                end
            end
            @subTypes = subTypes
        end
    end

    class ArrayType < Type
        attr_reader :subType

        def signature
            # signatures doesnt print the size!!
            "[#{@subType.signature}]"
        end

        # a single subType (Single, Union or Array type)
        def initialize subType, size
            @subType, @size = subType, size
        end
    end

    # typefactory.create takes two arguments : previous and current value
    # (nil if no previous value)
    class TypeFactory
        def self.genType value
            if value.is_a?(Array)
                testUnion = UnionType.new(value)
                if (testUnion.subTypes.size > 1)
                    ArrayType.new(testUnion, value.size)
                else
                    # first param of an array is always a type, and only 1
                    ArrayType.new((testUnion.subTypes[0]), value.size)
                end
            else
                SingleType.new(value)
            end
        end

        def self.create pValue, cValue
          if (
            (!(pValue.nil?) && !(cValue.nil?)) &&
            (self.genType(pValue).signature != self.genType(cValue))
          )
            UnionType.new [pValue,cValue]
          else
            self.genType(cValue)
          end
        end
    end

end
