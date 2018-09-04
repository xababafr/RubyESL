# the compiler takes ruby code as an input, and can :
# - add probes
# - generate the ast
# - simulate the code to infer types
# - do all those 3 and create a systemC code

require "./resl_data"
require "./resl_objects"
require "./resl_objectifier"
require "./resl_dsl"
require "./resl_simulator"
require "./visitors/systemc"
require "./visitors/prettyprinter"
require "./visitors/addprobes"

module RubyESL


  class Compiler
    def initialize

    end

    def get_ast filename, convert = false
      objectifier = Objectifier.new filename, convert
      ret = objectifier.methods_objects
      ret[:sys] = objectifier.sys_ast

      puts "\n\n"
      pp ret[[:Sourcer,:source]]

      ret
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

    def deep_copy(o)
      Marshal.load(Marshal.dump(o))
    end


    def simulate sys
      sys.ordered_actors.each do |actor|
        actor_threads = Actor.get_threads[actor.class.get_klass()]
        actor_threads.each do |thread|
          fiber = Fiber.new do
            actor.method(thread).call
          end
          DATA.simulator.add_fiber("#{actor.class.get_klass}.#{thread}" , fiber)
        end
      end
      DATA.simulator.run
    end

    def get_init_params sys
      initParams = {}
      sys.ordered_actors.each do |actor|
        key = [actor.class.get_klass(), actor.name]
        initParams[key] = actor.method(:initialize).parameters

        if actor.initArgs.size > 0
          actor.initArgs.each_with_index do |argHash, i|
            initParams[key][i+1] << argHash
          end
        end
      end
      initParams
    end

    def generate_systemc filename
      puts "\n\n\n"
      puts "[STEP 1 : GET INPUT'S CODE AST]".center(80,"=")
      puts "\n\n\n"
      ast = get_ast filename
      s_ast = get_ast filename, true

      puts "\n\n\n"
      puts "[STEP 2 :ADD PROBES TO THE CODE]".center(80,"=")
      puts "\n\n\n"
      root = Root.new ast, {}, Actor.get_threads() # + it collects the data from DATA
      root.accept AddProbes.new

      File.open("P_#{filename}",'w'){|f| f.puts(root.sourceCode)}

      sys = eval_dsl ( "P_" + filename )

      puts "\n\n\n"
      puts "[STEP 3 : SIMULATE THE CODE TO INFER TYPES]".center(80,"=")
      puts "\n\n\n"
      simulate sys

      puts "\n\n"
      pp DATA.instance_vars
      puts "\n\n"
      pp DATA.local_vars
      puts "\n\n"

      initParams = get_init_params sys

      puts "\n\n\n"
      puts "[STEP 4 : GENERATE THE SYSTEMC CODE]".center(80,"=")
      puts "\n\n\n"
      root = Root.new s_ast, initParams, Actor.get_threads()
      root.accept SystemC.new
    end

  end #Compiler


end #MTS





if $PROGRAM_NAME == __FILE__
  compiler = RubyESL::Compiler.new
  compiler.generate_systemc "#{ARGV[0]}"
end
