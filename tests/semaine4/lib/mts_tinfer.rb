require_relative "./mts_analyzer"
require_relative "./mts_objectifier"
require_relative "./mts_metadata"

module MTS
  class TInfer

    def initialize file
      # we get the hash containing the ast of each method from each class available
      analyzer = Analyzer.new
      analyzer.open file

      # then we convert the ASTs into containers objects
      objectifier = Objectifier.new analyzer.methods_code_h
      #@methods = objectifier.methods_objects
      #pp @methods

      # this vars contains all the vars and their type
      # for a given method's context
      # global for now, is there a better way?
      #$contexts = {}
      #$returnTypes = {}
      #$currentContext = nil
      #$methods = @methods

      DATA.contexts = {}
      DATA.returnTypes = {}
      DATA.currentContext = nil
      DATA.methods = objectifier.methods_objects

      puts "TInfer initialized : "
      pp DATA.methods
      DATA.methods.keys.each do |key|
        DATA.contexts[key], DATA.returnTypes[key] = {}, []
      end

      inferTypes()
    end

    def inferTypes
      DATA.methods.each do |methodArr|
        #pp method
        context, method = methodArr
        # assez degueu
        if context[1] == :behavior
          DATA.currentContext = context
          methodArr[1].accept BasicVisitor.new
        end
      end

      pp DATA.contexts

    end

  end
end
