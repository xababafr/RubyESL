require 'parser'
require 'parser/current'

module NMTS
  class Analyzer
    attr_reader :ast,:sys, :behaviors, :methods_code_h

    def evaluate filename
      rcode=IO.read(filename)
      eval(rcode)
    end

    def open filename
      @behaviors = []
      @filename=filename
      @sys=evaluate(filename)
      @ast=parse()
      build_hash_code_for_classes # @class_code_h[:Sensor]=...

      pp @class_code_h

      #puts "HASH FOR CLASSES"
      #pp @class_code_h
      @class_code_h.keys.each do |klass|
        get_methods klass
      end
      #puts "HASH FOR METHODS"
      #pp @methods_code_h
    end

    def get_actor_classes
      classes_code={}
      recursive_code_for_class
    end

    def parse
      Parser::CurrentRuby.parse(File.open(@filename, "r").read)
    end

    def build_hash_code_for_classes
      rec_build_hash_code_for_classes @ast
    end

    def rec_build_hash_code_for_classes ast
      ast.children.each do |child|
        if child.class.to_s == "Parser::AST::Node"
          if child.type.to_s == "class"
            class_name=child.children[0].children[1]
            @class_code_h||={}
            @class_code_h[class_name]=child
          else
            rec_build_hash_code_for_classes child
          end
        end
      end
    end

    def get_methods klass
      @methods_code_h ||= {}
      rec_get_methods @class_code_h[klass], klass
    end

    def rec_get_methods node, klass
      node.children.each do |child|
        next unless child.class.to_s == "Parser::AST::Node"
        if (child.type==:def)
          @methods_code_h[ [klass, child.children[0]] ] = child
        else
          rec_get_methods child, klass unless (child == nil)
        end
      end
    end

  end

end
