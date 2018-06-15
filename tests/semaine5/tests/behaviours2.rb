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
