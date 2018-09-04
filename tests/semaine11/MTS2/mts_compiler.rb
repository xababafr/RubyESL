# the compiler takes ruby code as an input, and can :
# - add probes
# - generate the ast
# - simulate the code to infer types
# - do all those 3 and create a systemC code

require "./mts_data"
require "./mts_objects"
require "./mts_objectifier"
require "./mts_addProbes"
require "./mts_dsl"
require "./mts_simulator"
require "./mts_addProbes"
require "./visitors/systemc"
require "./visitors/addprobes"

module NMTS


  class Compiler
    def initialize

    end

    def get_ast filename, convert = false
      objectifier = Objectifier.new filename, convert
      ret = objectifier.methods_objects
      ret[:sys] = objectifier.sys_ast
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

    def simulate sys
      sys.ordered_actors.each do |actor|
        puts "#SIM_ACTOR : #{actor}"
        pp Actor.get_threads
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

    def generate_ruby filename
      # step 1 : get the System's objectified AST and organised in a hash
      # ast : { klass => [method1_, method2_ast,..], klass2 => ... }
      ast = get_ast filename

      root = Root.new ast, {}, Actor.get_threads() # + it collects the data from DATA

      # step 2 : generate the ruby code thanks to the AST
      root.accept AddProbesVisitor.new

      File.open("probes2_#{filename}",'w'){|f| f.puts(root.sourceCode)}

      sys = eval_dsl ( "probes2_" + filename )

      simulate sys
    end

    def generate_systemc filename
      # step 1 : get the System's objectified AST and organised in a hash
      # ast : { klass => [method1_, method2_ast,..], klass2 => ... }
      ast = get_ast filename, true

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

      puts "\n\n"
      pp DATA.local_vars
      puts "\n\n"

      # pp DATA.local_vars
      # puts "\n\n"
      # pp DATA.instance_vars

      # contains all the data to recreate the overall system's constructor
      # entities names, constructor parameters, the order of actors....

      # ucoef_hash ==> see actor.initArgs
      # {
      #   [:Sourcer, "src0"]=>[[:req, :name]],
      #   [:Fir, "fir0"]=>[[:req, :name], [:req, :ucoef, ucoef_hash ]],
      #   [:Sinker, "snk0"]=>[[:req, :name]]
      # }

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

      # we generate a a representation of the ast (visual only)
      require_relative "./diagram/dot_generator"
      dot_generator = DotGenerator.new
      dot_generator.generate ast[ [:Sourcer, :source] ]

      puts "\n\n"
      root = Root.new ast, initParams, Actor.get_threads() # + it collects the data from DATA

      # step 5 : generate the systemC code thanks to DATA's singleton and AST
      root.accept SystemC.new
    end
  end #Compiler


end #MTS





if $PROGRAM_NAME == __FILE__
  compiler = NMTS::Compiler.new
  compiler.generate_systemc "testingCode.rb"
  #compiler.generate_ruby "testingCode.rb"
end
