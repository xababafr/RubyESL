require 'parser/current'

code = File.read('structure.rb')
parsed_code = Parser::CurrentRuby.parse(code)

#puts parsed_code

class Processor < AST::Processor
	def on_begin(node)
		node.children.each { |c| process(c) }
	end

	def on_class(node)
		#puts "---------\n\n"
		#puts node.children
		puts "class " + 
		     node.children[0].children[1].to_s + 
		     " < " + 
		     node.children[1].children[1].to_s
		
		process(node.children[2])	
	end

	def on_send(node)
		puts "SEND : "
		#puts node.children.size
		if node.children[1].to_s == "output"
			puts "OUTPUT " #+ node.children[i].children.size.to_s #node.children[2].children[0].to_s
		elsif node.children[1].to_s == "input"
			puts "INPUT " #+ node.children[i].children.size.to_s #node.children[2].children[0].to_s
		else
			puts "NOTHIN'"
		end
		node.children.each_index { |i|
			if i >= 2
				puts node.children[i].children[0]
			end	
		}
	end

	def on_def(node)
		puts "DEF " + node.children[0].to_s
		#puts node
		if node.children[0].to_s == "behavior"
			puts "{"
			puts node.children
			puts "}"
		end
	end

	def handler_missing(node)
		puts "you're missing the #{node.type} node"
	end
end

# ce code parcours toutes les classes du fichier structure.rb. Pour chacune d'entre elle, il parcours les inputs, outputs et behaviors
# pour l'instant, il s'agit d'un simple parcours. Il faudrait rajouter un @classe_actuelle ou un truc du style pour savoir à quel endroit du parcours on en est.

ast = Processor.new
ast.process(parsed_code)
