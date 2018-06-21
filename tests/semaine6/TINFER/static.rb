require 'yaml'

require_relative "../MTS/mts_analyzer"
require_relative "../MTS/mts_objectifier"
require_relative "../MTS/mts_metadata"

module TINFER
  class Static

    def initialize file
      # we get the hash containing the ast of each method from each class available
      analyzer = MTS::Analyzer.new
      analyzer.open file

      # then we convert the ASTs into containers objects
      objectifier = MTS::Objectifier.new analyzer.methods_code_h
      #@methods = objectifier.methods_objects
      #pp @methods

      # this vars contains all the vars and their type
      # for a given method's context
      # global for now, is there a better way?
      #$contexts = {}
      #$returnTypes = {}
      #$currentContext = nil
      #$methods = @methods

      MTS::DATA.contexts = {}
      MTS::DATA.returnTypes = {}
      MTS::DATA.currentContext = nil
      MTS::DATA.methods = objectifier.methods_objects

      puts "TInfer initialized : "
      pp MTS::DATA.methods
      MTS::DATA.methods.keys.each do |key|
        MTS::DATA.contexts[key], MTS::DATA.returnTypes[key] = {}, []
      end

      #inferTypes()
    end

    def export_types filename
      MTS::DATA.methods.each do |methodArr|
        #pp method
        context, method = methodArr
        # assez degueu
        if context[1] == :behavior
          MTS::DATA.currentContext = context
          methodArr[1].accept BasicVisitor.new
        end
      end

      pp MTS::DATA.contexts

      File.open(filename+'.yml','w'){|f| f.puts(YAML.dump(MTS::DATA.contexts))}

    end

  end
end
