# this file defines the tyoes objects needed for the type inferring, and the type factory

module NMTS

  class Type
    def identifier
      "notImplemented"
    end

    def cpp_signature
      identifier()
    end
  end

  class SingleType < Type
    attr_reader :type

    def identifier
        @type.to_s
    end

    def cpp_signature
      # this method should tell the user if the var has a "baseline type" ( = bool, int, string)
      # yes, string is not a baseline type, but it can be written like baseline types, so, it matters not
      # or a "object type" ( UserDefinedClass, ...) (basically, baseline = can be instanciate like a bool, without proper constructor call)
      # if the object is composite, we save the class to instanciate, and the args to give
      # signature contains the string to write before the name of the var, in the instanciation
      # lets return : { :isBaseline => :baseline / :composite , signature => ... , class => ..., args => ...}
      klass, signature, args = @type.to_s, nil, nil

      baselineTypesMapping = {
        "TrueClass"  => "bool"   ,
        "FalseClass" => "bool"   ,
        "Boolean"    => "bool"   ,
        "String"     => "string" ,
        "Integer"    => "int"    ,
        "Float"      => "Double"
      }

      isBaseline =  baselineTypesMapping.keys.include?(klass)
      if isBaseline
        signature = baselineTypesMapping[klass]
      else
        signature = klass
      end

      # ret = {
      #   :nature     => "SingleT"  ,
      #   :isBaseline => isBaseline ,
      #   :signature  => signature  ,
      #   :class      => klass      ,
      #   :args       => args
      # }

      signature
    end

    # a single value
    def initialize value
        @type = value.class
    end
  end

    class UnionType < Type
        attr_reader :subTypes

        def identifier
            signatures = []
            @subTypes.each do |type|
                signatures << type.identifier
            end
            signatures.uniq.join(' | ')
        end

        # one or more values
        def initialize values
            subTypes,subSignatures = [], []
            values.each do |v|
                type = TypeFactory::genType(v)
                if !(subSignatures.include?(type.identifier))
                    subSignatures << type.identifier
                    subTypes << type
                end
            end
            @subTypes = subTypes
        end
    end

    class ArrayType < Type
        attr_reader :subType, :size

        def identifier
            # signatures doesnt print the size!!
            "[#{@subType.identifier}]"
        end

        def cpp_signature
          #if @subType.is_a?(SingleType)
          "#{@subType.cpp_signature}[#{@size}]"
          #end
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
            (self.genType(pValue).identifier != self.genType(cValue))
          )
            testUnion2 = UnionType.new [pValue,cValue]
            if testUnion2.subTypes.size > 1
              testUnion2
            else
              testUnion2.subTypes[0]
            end
          else
            self.genType(cValue)
          end
        end
    end

end

if $PROGRAM_NAME == __FILE__
  type1 = NMTS::TypeFactory.create nil, ["dada", 4, [3.2,6]]
  type2 = NMTS::TypeFactory.create "dada", 3
  type3 = NMTS::TypeFactory.create nil, [1,2,3]

  puts " #{type1.cpp_signature} \n #{type2.cpp_signature} \n #{type3.cpp_signature}"
  pp type1
  pp type2
  pp type3
end
