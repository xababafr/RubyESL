# MTS
require_relative "../MTS/evaluate"
require_relative "../MTS/mts_simulator"
require_relative "../MTS/mts_actors_model"
require_relative "../MTS/mts_actors_sim"
require_relative "../MTS/mts_analyzer"
require_relative "../MTS/mts_objectifier"
require_relative "../MTS/mts_metadata"

simulator=MTS::Simulator.new
sys=simulator.open("traitementImage.rb")
simulator.simulate(simulator.system,2)
