def generate_yaml(filename, iterations)
  

  simulator=MTS::Simulator.new
  simulator.open(filename)

  simulator.simulate simulator.system, iterations.to_i

  variables = {}

  simulator.system.ordered_actors.each do |actor|
    variables[actor.name.to_sym] = actor.vars
  end

  typesdata = {
    :INOUTS     => simulator.system.inouts,
    :VARIABLES  => variables,
    :CONNEXIONS => simulator.system.connexions
  }

  File.open(filename+'.yml','w'){|f| f.puts(YAML.dump(typesdata))}
end

generate_yaml()
