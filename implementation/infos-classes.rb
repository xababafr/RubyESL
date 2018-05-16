require 'parser/current'

code = File.read('structure.rb')
parsed_code = Parser::CurrentRuby.parse(code)

code2 = File.read('connexions.rb')
parsed_code2 = Parser::CurrentRuby.parse(code2)

# parcours les classes et stocke dans un tableau les inputs/outputs de chacune d'entre elle
class InOuts < AST::Processor

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
		@currentClass = node.children[0].children[1]
	
		@inouts[ @currentClass ] = {
			:inputs => [],
			:outputs => [],
			:inherit => node.children[1].children[1]
		}
		
		process(node.children[2])	
	end

	def on_send(node)
		sendType = ""
		if node.children[1] == :output
			sendType = :outputs 
		elsif node.children[1] == :input
			sendType = :inputs
		else
			sendType = :nothing
		end
		node.children.each_index { |i|
			if i >= 2
				if sendType != :nothing
					@inouts[ @currentClass ][sendType] << { :name => node.children[i].children[0], :type => :none }
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

# 1/ we get the inouts with Processor
ast = InOuts.new
ast.process(parsed_code)
puts "final @inouts : " 
puts ast.inouts
