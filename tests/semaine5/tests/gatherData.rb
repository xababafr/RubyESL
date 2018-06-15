require "yaml"

require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"
require_relative "sys_2"

my_hash = YAML.load(File.read('inferMePlz.yml'))

pp my_hash
