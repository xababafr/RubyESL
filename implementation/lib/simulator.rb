
#.......................................................
# Do not move this 'evaluate'  function inside a module
# Otherwise, the eval_uated class will be prefixed
# with the module itself
# ......................................................
def evaluate simfile
  rcode=IO.read(simfile)
  eval(rcode)
end

module RubyESL
  class Simulator
    attr_accessor :system

    def initialize(system)
      puts "Newage simulator".center(80,'=')
      @system=system
      @stop_condition={}
    end

    def open simfile
      puts "=> open simulation file #{simfile}"
      @system=evaluate(simfile)
    end

    def simulate max_steps=nil
      puts "=> simulating #{system.name}"
      puts " - nb of actors = #{actors.size}"
      actors.each{|name,actor| actor.start}
      running=not_stop?(max_steps)
      while running
        runnables.each {|actor|
          state=actor.step
          puts "state #{actor.name} ".ljust(15)+": #{state}"
        }
        running = not_stop?(max_steps)
      end
    end

    def dump_logs
      puts "==> dumping logs..."
      actors.each do |name,actor|
        filename="#{name}.log"
        puts "   -file #{filename}"
        File.open(filename,'w'){|f| f.puts actor.log}
      end
    end

    alias :run :simulate

    def actors
      @system.actors
    end

    def runnables
      actors.values.reject{|a| a.state==:ENDED}
    end

    def stop?(max_steps)
      stop_state? or max_step_reached?(max_steps)
    end

    def not_stop? max_steps
      !stop?(max_steps)
    end

    def max_step_reached?(max_to_reach)
      max_steps=actors.values.collect{|actor| actor.executed_steps}.max
      ret=max_step_reached=(max_to_reach && max_steps >= max_to_reach)
      puts "max steps #{max_to_reach} reached " if ret
      ret
    end

    def stop_state?
      @stop_condition.any?{|name,state| actors[name].state==state}
    end

    def stop_when hash #DSL syntax
      @stop_condition=hash
      #check that the names are known as actors
      incorrect=hash.keys.any?{|name| actors[name].nil?}
      if incorrect
        raise "the stop condition refers to an unkown actor name"
      end
    end
  end #class
end#newage

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a file !" if filename.nil?
  simulator=RubyESL::Simulator.new
  sys=simulator.open(filename)
  simulator.simulate(sys)
end
