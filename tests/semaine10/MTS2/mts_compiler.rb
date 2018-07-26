# the compiler takes ruby code as an input, and can :
# - add probes
# - generate the ast
# - simulate the code to infer types
# - do all those 3 and create a systemC code

require "./mts_data"
require "./mts_objects"
require "./mts_analyzer"
require "./mts_objectifier"
require "./mts_addProbes"
require "./mts_dsl"
require "./mts_simulator"
require "./mts_addProbes"
require "./visitors/systemc"

module NMTS


  class Compiler
    def initialize

    end

    def get_ast filename
      analyzer = Analyzer.new
      analyzer.open filename
      objectifier = Objectifier.new analyzer.methods_code_h
      objectifier.methods_objects
      # .methods_ast would give the original non objectified ast
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
        puts "#SIM_ACTOR : #{actor}"
        actor.class.get_threads.each do |thread|
          fiber = Fiber.new do
            actor.method(thread).call
          end
          DATA.simulator.add_fiber("#{actor.class.get_klass}.#{thread}" , fiber)
        end
      end
      DATA.simulator.run
    end

    def generate_systemc filename
      # step 1 : get the System's objectified AST and organised in a hash
      # ast : { klass => [method1_, method2_ast,..], klass2 => ... }
      ast = get_ast filename

      puts "\n\n AST OBJ \n\n"
      pp ast
      puts "\n\n"

      # step 2 : add the probes to the file
      add_probes ( filename )

      puts "\n\n"

      # step 3 : get the sys object
      # this step eval the code, so the DATA.xxx are also structured by now
      sys = eval_dsl ( "probes_" + filename )

      puts "\n\n SYS OBJ \n\n"
      pp sys
      puts "\n\n"

      # step 4 : simulate the system to infer types
      # types are stored in the DATA singleton
      simulate sys
      sys.type_instance_vars

      pp DATA.local_vars
      puts "\n\n"
      pp DATA.instance_vars

      # contains all the data to recreate the overall system's constructor
      # entities names, constructor parameters, the order of actors....
      initBlock = nil

      puts "\n\n"
      root = Root.new ast, initBlock # + he collects the data from DATA

      # step 5 : generate the systemC code thanks to DATA's singleton and AST
    end
  end #Compiler


end #MTS





if $PROGRAM_NAME == __FILE__
  compiler = NMTS::Compiler.new
  compiler.generate_systemc "testingCode.rb"
end
