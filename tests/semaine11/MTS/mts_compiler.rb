# le module MTS est la pour modeliser et simuler le systeme
# le module TINFER est la pour inferer les types d'un systeme, de maniere statique ou dynamique

require 'yaml'
require 'parser'
require 'parser/current'

# MTS
require_relative "./evaluate"
require_relative "./mts_simulator"
require_relative "./mts_actors_model"
require_relative "./mts_actors_sim"
require_relative "./mts_analyzer"
require_relative "./mts_objectifier"
require_relative "./mts_metadata"

require_relative "./visitors/basic_typing"
require_relative "./visitors/pretty_printer"
require_relative "./visitors/add_probes"
require_relative "./visitors/static_infer"
require_relative "./visitors/dynamic_infer"
require_relative "./visitors/systemc_printer"

module MTS


  class Compiler

    def initialize filename
      @filename = filename

      analyzer = Analyzer.new
      analyzer.open filename

      objectifier = Objectifier.new analyzer.methods_code_h
      #pp objectifier.methods_objects

      #simulator=MTS::Simulator.new
      #simulator.open(@filename)
      sys = evaluate @filename
      puts "SYSYSYSYS"
      pp objectifier.methods_objects
      sys.blockStr = File.read(@filename).split('MTS::System.new').last
      @root = Root.new objectifier.methods_objects, sys

      #define the static inference's context
      DATA.contexts = {}
      DATA.returnTypes = {}
      DATA.currentContext = nil
      DATA.methods = objectifier.methods_objects
      DATA.methods.keys.each do |key|
        DATA.contexts[key], DATA.returnTypes[key] = {}, []
      end
    end

    def compile visitor = PrettyPrinter.new #, simIterations = 10

      #@visitor, @iterations = visitor, simIterations

      # we make a first, basic typing
      # root.accept BasicTyping.new

      # we start the visitor
      @root.accept visitor
      visitor.code.get_source

      #pp DATA.contexts

      #puts visitor.code.finalize unless visitor.code.nil?
      #puts visitor.code.get_source

    end

    def compile_static
      @root.accept StaticInfer.new
    end

    def compile_dynamic imIterations = 10, probesFilename = "PROBES"
      # 1/ add the probes
      #sys = eval(File.read(@filename))
      #puts "SYYYS"
      #pp sys
      @root.accept AddProbes.new
      File.open("#{probesFilename}.rb", "w") { |f| f.write(@root.sourceCode) }

      # 2/ simulate the new system
      simulator=MTS::Simulator.new
      simulator.open("#{probesFilename}.rb")
      simulator.simulate simulator.system, imIterations.to_i

      variables = {}

      simulator.system.ordered_actors.each do |actor|
        variables[actor.name.to_sym] = actor.varsTypes
      end

      typesdata = {
        :INOUTS     => simulator.system.inouts,
        :VARIABLES  => variables,
        :CONNEXIONS => simulator.system.connexions
      }

      # global access
      DATA.dynTypes = typesdata

      File.open(@filename+'.yml','w'){|f| f.puts(YAML.dump(typesdata))}

      # 3/ visit the objectified AST again and nest its nodes with inferred types
      @root.accept DynamicInfer.new

      #puts "FINAL AST"
      #pp @root

      # root.inouts and root.connexion are already defined in its constructor
      @root.variables = variables
    end

    def compile_systemc imIterations = 10, probesFilename = "PROBES", systemcFilename = "SYSTEMC"
      # 1/ use compile_dynamic() to put the types right into the ast
      compile_dynamic imIterations, probesFilename
      # @root.code should have been reset by DynamicInfer,
      # so the systemc_printer can write safely

      # 2/ now we can use the nested @root object to generate systemC code
      @root.accept SystemcPrinter.new
      File.open(systemcFilename+'.cpp','w'){|f| f.puts( @root.sourceCode )}
    end
  end


end
