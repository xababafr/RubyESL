require "yaml"

require_relative "../MTS/mts_simulator"
require_relative "../MTS/mts_actors_model"
require_relative "../MTS/mts_actors_sim"
require_relative 'inferMePlz.rb'

my_hash = YAML.load(File.read('inferMePlz.yml'))

pp my_hash
