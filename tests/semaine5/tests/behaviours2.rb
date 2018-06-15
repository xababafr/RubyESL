require 'json'

require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"

simulator=MTS::Simulator.new
simulator.open "./sys_2.rb"

puts "\n============== INFOS =============="
pp simulator.system.inouts
puts "============================\n"
pp simulator.system.connexions

puts "===================================\n\n"

$inouts = simulator.system.inouts
$connexions = simulator.system.connexions

simulator.simulate simulator.system, 10

puts "\n============== INFOS =============="
pp simulator.system.inouts
puts "============================\n"
pp simulator.system.connexions

puts "===================================\n\n"

$variables = {}

simulator.system.ordered_actors.each do |actor|
  $variables[actor.name.to_sym] = actor.vars
end

$TYPESDATA = {
  :INOUTS => $inouts,
  :VARIABLES => $variables
}

pp $TYPESDATA

File.open('TYPESDATA.marshal','w'){|f| f.puts(Marshal.dump($TYPESDATA))}
