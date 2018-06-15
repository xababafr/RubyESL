require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"
require_relative "sys_2"

my_hash = Marshal.load(File.read('TYPESDATA.marshal'))

pp my_hash
