# method_finder.rb
require 'parser'
require 'parser/current'

class MethodFinder
  def initialize(filename)
    @ast = parse(filename)
  end

  def find(method_name)
    recursive_search_ast(@ast, method_name)
    return @method_source
  end

  private
  def parse(filename)
    Parser::CurrentRuby.parse(File.open(filename, "r").read)
  end

  def recursive_search_ast(ast, method_name)
    ast.children.each do |child|
      if child.class.to_s == "Parser::AST::Node"
        if (child.type.to_s == "def" or child.type.to_s == "defs") and (child.children[0].to_s == method_name or child.children[1].to_s == method_name)
          @method_source = child.loc.expression.source
        else
          recursive_search_ast(child, method_name)
        end
      end
    end
  end
end
