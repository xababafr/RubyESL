# the compiler takes ruby code as an input, and can :
# - add probes
# - generate the ast
# - simulate the code to infer types
# - do all those 3 and create a systemC code

require "./mts_objectifier"
require "./mts_addProbes"
require "./mts_dsl"
require "./mts_simulator"
require "./mts_addProbes"
require "./visitor/systemc"

module MTS


  class Compiler
    def initialize

    end

    def get_ast filename
      nil, nil
    end

    def add_probes filename
      add_probes = AddProbes.new filename
      add_probes.generate_file
    end

    def eval_dsl filename
      rcode=IO.read(filename)
      eval(rcode)
    end

    def simulate sys
      sys.ordered_actors.each do |actor|
        actor.threads.each do |thread|
          DATA.simulator.add_thread ( Fiber.new do
            actor.method(thread).call
          end )
        end
      end
      DATA.simulator.run
    end

    def generate_systemc filename
      # step 1 : get the System's structure and its objectified AST
      struct, ast = get_ast filename

      # step 2 : add the probes to the file
      add_probes ( "probes__" + filename )

      # step 3 : get the sys object
      # this step eval the code, so the DATA.xxx are also structured by now
      sys = eval_dsl ( "probes__" + filename )

      # step 4 : simulate the system to infer types
      # types are stored in the DATA singleton
      simulate sys

      # step 5 : generate the systemC code thanks to DATA's singleton and AST
    end
  end


end
