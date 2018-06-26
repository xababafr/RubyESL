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

require_relative "./basic_typing"
require_relative "./pretty_printer"
require_relative "./static_infer"

module MTS


  class Compiler

    def initialize filename, visitor = PrettyPrinter.new, simIterations = 10

      @filename, @visitor, @iterations = filename, visitor, simIterations

      analyzer = Analyzer.new
      analyzer.open filename

      objectifier = Objectifier.new analyzer.methods_code_h
      #pp objectifier.methods_objects

      root = Root.new objectifier.methods_objects
      pp root

      #define the static inference's context
      DATA.contexts = {}
      DATA.returnTypes = {}
      DATA.currentContext = nil
      DATA.methods = objectifier.methods_objects
      DATA.methods.keys.each do |key|
        DATA.contexts[key], DATA.returnTypes[key] = {}, []
      end

      # we make a first, basic typing
      # root.accept BasicTyping.new

      # we start the visitor
      root.accept visitor

      pp DATA.contexts

    end

  end


end
