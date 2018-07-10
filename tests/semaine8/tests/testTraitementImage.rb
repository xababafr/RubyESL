require "../MTS/mts_simulator"
require "../MTS/mts_actors_model"

simulator=MTS::Simulator.new
sys=simulator.open("InferMeDyn.rb")
simulator.simulate(sys)
