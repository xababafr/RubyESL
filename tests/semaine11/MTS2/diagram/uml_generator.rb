
require 'parser/current'

module NMTS


  class MyProcessor < AST::Processor
    def handler_missing node
      #puts "you're missing the #{node.type} node"
      node.children.each do |child|
        if child.is_a? AST::Node
          process(child)
        end
      end
    end
  end

  class CodeProcessor < MyProcessor
    attr_reader :full_str

    def initialize
      @full_str = []
    end

    def on_class node
      #pp node
      puts "////#{node.children[0].children[1]}/////"
      puts "________________________________"
      classes_processor = ClassesProcessor.new
      classes_processor.process node
      @full_str << classes_processor.str
    end
  end

  class ClassesProcessor < MyProcessor
    attr_reader :str

    def on_class(node)
      pp node.children[1]
      @currentClass = node.children[0].children[1]
      @str[0] = "#{@currentClass}"
      @str[3] = "#{node.children[1].children[1]}" unless node.children[1].nil?
      handler_missing node
    end

    def initialize
      # name, ivars, methods, inherits
      @str = ["", [], [],""]
    end

    def on_def node
      @currentMethod = node.children[0]
      @str[2] << "#{@currentMethod}()"
      handler_missing node
      puts "________________"
    end

    def on_ivar node
      str[1] << "#{node.children[0]} : #{node.children[0].class}"
      str[1].uniq!
    end
  end


  class UmlGenerator
    def initialize filename
      code = File.read(filename)
      @filename = filename
      @parsed_code = Parser::CurrentRuby.parse(code)
    end

    def generate_file
      code_processor = CodeProcessor.new
      code_processor.process(@parsed_code)

      #pp code_processor.full_str

      str = ""
      code_processor.full_str.each do |classArr|
        inheritStr = ""
        if classArr[3] != ""
          inheritStr = "[#{classArr[3]}]^-"
        end
        cstr = "#{inheritStr}[#{classArr[0]}|#{classArr[1].join(';')}|#{classArr[2].join(';')}] \n"
        str << cstr
      end
      print str
    end
  end


end


if $PROGRAM_NAME == __FILE__

  uml_gen = NMTS::UmlGenerator.new "../visitors/convert.rb"
  uml_gen.generate_file

end
