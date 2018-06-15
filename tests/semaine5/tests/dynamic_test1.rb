require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"
simulator=MTS::Simulator.new
sys=simulator.open "./sys_1.rb"

pp sys

simulator.simulate sys, 10
