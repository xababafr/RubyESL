require_relative "./mts_analyzer"
require_relative "./mts_objectifier"
require_relative "./mts_signatures"

module MTS
  class TInfer

    def initialize file
      # we get the hash containing the ast of each method from each class available
      analyzer = Analyzer.new
      analyzer.open file

      # then we convert the ASTs into containers objects
      objectifier = Objectifier.new analyzer.methods_code_h
      @methods = objectifier.methods_objects
      #pp @methods

      # this vars contains all the vars and their type
      # for a given method's context
      # global for now, is there a better way?
      $contexts = {}
      $returnTypes = {}
      $currentContext = nil
      $methods = @methods

      puts "TInfer initialized : "
      pp @methods.keys
      @methods.keys.each do |key|
        $contexts[key], $returnTypes[key] = {}, []
      end

      inferTypes()
    end

    def inferTypes
      @methods.each do |methodArr|
        #pp method
        context, method = methodArr
        # assez degueu
        if context[1] == :behavior
          $currentContext = context
          methodArr[1].accept BasicVisitor.new
        end
      end

      pp $contexts

    end

  end
end
