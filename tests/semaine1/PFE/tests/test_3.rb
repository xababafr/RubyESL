require 'parser/current'

code = File.read('structure.rb')
parsed_code = Parser::CurrentRuby.parse(code)

code2 = File.read('connexions.rb')
parsed_code2 = Parser::CurrentRuby.parse(code2)

puts parsed_code2

# parcours les classes et stocke dans un tableau les inputs/outputs de chacune d'entre elle
class Processor < AST::Processor

	attr_accessor :inouts
	attr_accessor :currentClass

	def initialize()
		@inouts = {}
		@currentClass = ""	
	end

	def on_begin(node)
		node.children.each { |c| process(c) }
	end

	def on_class(node)
		#puts "---------\n\n"
		#puts node.children
	
		@currentClass = node.children[0].children[1].to_s
	
		#puts "CLASS : " + @currentClass

		@inouts[ @currentClass ] = {
			:inputs => [],
			:outputs => [],
			:inherit => node.children[1].children[1].to_s
		}

		#puts @inouts

		#	puts "class " + 
		#     node.children[0].children[1].to_s + 
		#     " < " + 
		#     node.children[1].children[1].to_s
		
		process(node.children[2])	
	end

	def on_send(node)
		#puts "SEND : "
		#puts @inouts
		#puts node.children.size
		sendType = ""
		if node.children[1].to_s == "output"
			#puts "OUTPUT " #+ node.children[i].children.size.to_s #node.children[2].children[0].to_s
			#@inouts[ @currentClass ][:outputs] =
			sendType = :outputs 
		elsif node.children[1].to_s == "input"
			#puts "INPUT " #+ node.children[i].children.size.to_s #node.children[2].children[0].to_s
			sendType = :inputs
		else
			#puts "NOTHIN'"
			sendType = :nothing
		end
		node.children.each_index { |i|
			if i >= 2
				#puts node.children[i].children[0]
				if sendType != :nothing
					@inouts[ @currentClass ][sendType] << { :name => node.children[i].children[0], :type => "" }
				end
			end	
		}
	end

	def on_def(node)

	end

	def handler_missing(node)
		puts "you're missing the #{node.type} node"
	end
end

# parcours les classes pour extraire leur behavior. En utilisant le tableau input/output d'un objet processor, on va tenter
# d'inferer les types de ces derniers
class Behavior < AST::Processor
	
	attr_accessor :inouts

	def initialize(inouts)
		@inouts = inouts
	end

	def on_begin(node)
		node.children.each { |c| process(c) }
	end

	def on_class(node)
		process(node.children[2])	
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

	def on_send(node) 
	
	end

	def handler_missing(node)
		puts "you're missing the #{node.type} node"
	end
end

# 1/ we get the inouts with Processor
ast = Processor.new
ast.process(parsed_code)
puts "final @inouts : " 
puts ast.inouts

# 2/ we can start inferring types with Behavior
beh = Behavior.new(ast.inouts)
beh.process(parsed_code)
