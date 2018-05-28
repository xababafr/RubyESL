require_relative "../lib/mts_parser2" #2!!
require_relative "consts"

analyzer=MTS::Analyzer.new

# with the system's structure, we suppose we know which behaviors we need to examine
# it's also implied here that we know the order?
analyzer.open "./struct4.rb", [
  { :class => :Computation, :method => :behavior }
]
analyzer.parse # now we have all the behaviors in analyser.behaviors
#pp analyzer.behaviors

# now we can create some visitors to go througth the methods and infer the behaviors
# for now, let's suppose inferring the types forthe class works for every entity (might be true with arrays of types)
# we also suppose that only the behavior method is relevant
class BasicVisitor < Visitor
  # the inputs and outputs that we want to infer in the given method
  def initialize inouts
    @inouts = inouts
  end

  def visit subject
    puts "\n\n /!\\ I, the #{subject.hash[:mclass]}.#{subject.hash[:mname]} method, am being visited /!\\ \n\n"
    pp subject.hash[:method]

    currentInouts = @inouts[subject.hash[:mclass]]
    pp currentInouts

    # l'idee pour chaque methode behavior est uniquement de typer le send()
    # en effet, si il y a des receive, ils sont déja types par les visiteurs precedents qui ont types des send
    
  end
end

analyzer.accept (BasicVisitor.new ({

  # for now, let's relate to the class and not the entity
  # it might make sense, as we dont have any way to distinguish entities anyways
  # (lets just make array of types if needed)
	:Computation => [{
		:symbol => :a,
		:type   => [Integer]
	}, {
		:symbol => :b,
		:type   => [Integer]
	}, {
		:symbol => :f,
		:type   => []
	}]

}) )
