# le module MTS est la pour modeliser et simuler le systeme
# le module TINFER est la pour inferer les types d'un systeme, de maniere statique ou dynamique

require 'yaml'

# MTS
require_relative "../MTS/mts_simulator"
require_relative "../MTS/mts_actors_model"
require_relative "../MTS/mts_actors_sim"

require_relative "./processors"


module TINFER


  class Dynamic

    def initialize filename, simIterations
      code = File.read(filename)
      @filename, @iterations = filename, simIterations
      @parsed_code = Parser::CurrentRuby.parse(code)
    end

    def export_types filename
      code_processor = CodeProcessor.new
      code_processor.process(@parsed_code)

      probius = AddProbesProcessor.new code_processor.classes
      probius.process(@parsed_code)

      file = File.new(@filename, "r")
      output, i = "", 0
      while (line = file.gets)
        i += 1
        output += line
        if probius.registerCalls.key?(i)
          probius.registerCalls[i].each do |t|
            output += t
          end
        end
      end
      file.close
      File.open("TEMP#{@filename}",'w'){|f| f.puts(output)}

      simulator=MTS::Simulator.new
      simulator.open("TEMP"+@filename)

      simulator.simulate simulator.system, @iterations.to_i

      variables = {}

      simulator.system.ordered_actors.each do |actor|
        variables[actor.name.to_sym] = actor.vars
      end

      typesdata = {
        :INOUTS => simulator.system.inouts,
        :VARIABLES => variables
      }

      File.open(filename+'.yml','w'){|f| f.puts(YAML.dump(typesdata))}
      File.delete('TEMP'+@filename)
    end

  end


end
