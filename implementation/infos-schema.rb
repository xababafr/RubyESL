require 'parser/current'

code2 = File.read('connexions.rb')
parsed_code2 = Parser::CurrentRuby.parse(code2)

#puts parsed_code2

# parcours les classes pour extraire leur behavior. En utilisant le tableau input/output d'un objet processor, on va tenter
# d'inferer les types de ces derniers
class Connexions < AST::Processor

	attr_accessor :system
	attr_accessor :conx
	attr_accessor :entities

	def initialize()
		@system = {
			:Emitter => {
			    :inputs=>[], :outputs=>[{:name=>:f, :type=>""}], :inherit=>"Actor"
			},
		   	:Computation => {
			    :inputs=>[{:name=>:a, :type=>""}, {:name=>:b, :type=>""}],
				:outputs=>[{:name=>:f, :type=>""}],
				:inherit=>"Actor"
			},
			:Receiver => {
				:inputs=>[{:name=>:i1, :type=>""}], :outputs=>[], :inherit=>"Actor"
			}
		}
		@conx = []
		@entities = []
	end

	def on_begin(node)
		node.children.each { |c| process(c) }
	end

	def on_class(node)
		
	end

	def on_def(node)
		
	end

	def on_send(node)
		# here, we create the connexions between our entities
		#puts node.children[1]
		if node.children[1] == :connect
				@conx << [{
				:ename => node.children[2].children,
				:port => node.children[3].children
			}, {
				:ename => node.children[4].children,
				:port => node.children[5].children # maybe add cname later, so @conx could be enougth (but data is duplicated)
			}]
		end
	end

	def on_lvasgn(node)
		# here , we create the entities in @conx
		@entities << { 
			:cname => node.children[1].children[0].children[1],
			:ename => node.children[0]	
	  	}
	end

	def handler_missing(node)
		puts "you're missing the #{node.type} node"
	end
end

# 1/ we get the connexions
ast = Connexions.new
ast.process(parsed_code2)
puts ast.entities
puts "-------------"
puts ast.conx
#puts "final @inouts : "
#puts ast.inouts
