require 'yaml'
require 'parser/current'

require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"

if $PROGRAM_NAME == __FILE__



  filename, iterations=ARGV[0], ARGV[1]
  raise "need a file !" if filename.nil?
  aise "need a number of iterations !" if iterations.nil?

  ########################################################
  ######## step1 = generate the intermediate file ########
  ########################################################
  output = ""
  file = File.new(filename, "r")
  while (line = file.gets)
    output += line
    splitted = line.split('=')
    # if there is an assign
    if splitted.size == 2
      begin
        if Parser::CurrentRuby.parse(line).to_s[0..6] == "(lvasgn"
        # we add a call to register
        # /!\ WE SUPPOSED ITS NOT AN ARRAY!!
        # TO BE ADDED LATER ON IN THE PROGRAM
          output += "register(:#{splitted[0].strip},#{splitted[0].strip})\n"
        end
      rescue

      end
    end
  end
  file.close
  File.open("TEMP#{filename}",'w'){|f| f.puts(output)}


  ########################################################
  ### step2 = generate the types content in a yam file ###
  ########################################################
  simulator=MTS::Simulator.new
  simulator.open("TEMP"+filename)

  $inouts = simulator.system.inouts
  $connexions = simulator.system.connexions

  simulator.simulate simulator.system, iterations.to_i

  $variables = {}

  simulator.system.ordered_actors.each do |actor|
    $variables[actor.name.to_sym] = actor.vars
  end

  $TYPESDATA = {
    :INOUTS => $inouts,
    :VARIABLES => $variables
  }

  File.open(filename.split('.')[0]+'.yml','w'){|f| f.puts(YAML.dump($TYPESDATA))}
  #File.delete('TEMP'+filename)


end
