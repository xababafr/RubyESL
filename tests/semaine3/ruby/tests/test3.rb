require_relative "../lib/mts_parser3"

analyzer=MTS::Analyzer.new
analyzer.open "./struct3.rb"
analyzer.parse

puts "BEHAVIORS"

pp analyzer.behaviors

$vars = {
  [:Sensor,:behavior] => {

  },
  [:Sensor, :test] => {
    
  }
}

$methods = {
  # the key is the name of the class . the name of the method
  # the value is a hash of inputs to outputs types
  "MTS::FloatLit.*" => {
    ["MTS::IntLit"] => "MTS::Float"
  },
  "MTS::IntLit.+" => {
    ["MTS::IntLit"] => "MTS::IntLit"
  },
}

# dans ce test 2, on suppose que les assignations ne sont faites qu'avec des litteraux,
# ou bien des mcalls imbriques

class BasicVisitor < Visitor
  # the inputs and outputs that we want to infer in the given method
  def initialize
  end

  def visit subject
    pp subject
  end
end

analyzer.behaviors[0][:method].accept BasicVisitor.new

puts "\n\n TEST 3 RESULTS : \n\n"

pp $vars
