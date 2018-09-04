# there goes the defition of Ruby's systemC-like DSL
require "./resl_data"
require "./resl_simulator"
require "./resl_types"

module RubyESL

  class InOut
    attr_reader :klass, :sym, :dir
    def initialize klass, sym, dir
      @klass, @sym, @dir = klass, sym, dir
    end
  end


  class Channel
    attr_accessor :from, :to, :type, :name

    def initialize inout1, inout2
      @from, @to, @data, @type = inout1, inout2, [], nil
      @name = "#{from.klass.to_s.downcase}_#{@from.sym}_#{to.klass.to_s.downcase}_#{to.sym}_sig"
    end

    def read
      # we need to keep only last 2 values
      if @data.size > 1
        @data.pop
      else
        @data.first
      end
      #@data.pop
    end

    def write val
      # because when we insert new data, we insert it at position 0
      prev_val = @data.last # nil if doesnt exist, perfect for typefactory
      @data.insert 0, val
      # not very useful for now
      @type = TypeFactory.create prev_val, val
    end
  end #Channel


  class Actor
    attr_reader :name, :threads, :initArgs

    def initialize name, *args
      @initArgs = []
      if args.size > 0
        args.each do |arg|
          @initArgs << {
            :val => arg,
            :typ => (TypeFactory.create nil, arg)
          }
        end
      end
      @name = name
      DATA.inouts[self.class.get_klass()].each do |name, inout|
        # send(:attr_accessor, name) # create the attribute
        # send(name, inout) # give it a value
        # lets create a method that retuns the corresponding inout
        singleton_class.class_eval { attr_accessor "#{name}" }
        send( "#{name}=", DATA.inouts[self.class.get_klass()][name] )
        # self.define_singleton_method(name) do
        #   return DATA.inouts[name]
        # end
      end
    end

    #
    # CLASS METHODS (static)
    #

    def self.init_data
      DATA.local_vars[get_klass()] ||= {} # method => { var_name => var_type_obj }
      DATA.instance_vars[get_klass()] ||= {}  # var_name => var_type_obj
      DATA.inouts[get_klass()] ||= {} # inout_name => inout_obj
    end

    def self.input *args
      if ( DATA.local_vars[get_klass()].nil? ||
           DATA.instance_vars[get_klass()].nil? ||
           DATA.inouts[get_klass()].nil? )
        init_data()
      end

      args.each do |input|
        inout = ( InOut.new get_klass(), input, :input )
        DATA.inouts[get_klass()][input] = inout
      end
    end

    def self.output *args
      if ( DATA.local_vars[get_klass()].nil? ||
           DATA.instance_vars[get_klass()].nil? ||
           DATA.inouts[get_klass()].nil? )
        init_data()
      end

      args.each do |output|
        inout = ( InOut.new get_klass(), output, :output )
        DATA.inouts[get_klass()][output] = inout
      end
    end

    def self.thread *args
      @@threads ||= {}
      args.each do |thread|
        @@threads[self.get_klass()] ||= []
        @@threads[self.get_klass()] << thread
        @@threads[self.get_klass()].uniq!
      end
      #@@threads.uniq! # just all the threads, regarless of
    end

    def self.get_threads
      @@threads ||= {}
      @@threads
    end

    def self.get_klass
      s = self.to_s
      s.split("::").last.to_sym
    end

    #
    # INSTANCE METHODS
    #

    #
    # below this point, methods should be used only during simulation, not initialization
    #

    # the use of break makes sure that only one connexion can be made per inout
    # more connexions will simply not be explored

    def register name, val, klass, method = ""
      if name[0] == "@"
        name = name[1..-1].to_sym
        DATA.instance_vars[klass] ||= {}
        DATA.instance_vars[klass][name] ||= []
        DATA.instance_vars[klass][name] = TypeFactory.create(nil, val)
      else
        DATA.local_vars[klass][method] ||= {}
        DATA.local_vars[klass][method][name] ||= []
        prev_val = DATA.local_vars[klass][method][name][0] # can be nil
        DATA.local_vars[klass][method][name] = [val, TypeFactory.create(prev_val, val)]
      end
    end

    def read inout_sym
      ret = nil
      DATA.channels.each do |channel|
        if channel.to.sym == inout_sym && channel.to.klass == self.class.get_klass()
          ret = channel.read
          break
        end
      end
      ret
    end

    def write val, inout_sym
      DATA.channels.each do |channel|
        if channel.from.sym == inout_sym && channel.from.klass == self.class.get_klass()
          channel.write val
          break
        end
      end
    end

    # pauses the simulator
    def wait
      Fiber.yield
    end

    # stops the simulation
    def stop
      DATA.simulator.stop
    end
  end #Actor


  class System

    attr_accessor :reader, :ordered_actors

    def initialize(name, &block)
      @name = name
      @ordered_actors = []

      # here are the 3 vars that contains the types of all the system's content
      DATA.channels = []
      DATA.local_vars ||= {}
      DATA.instance_vars ||= {}
      # channels already have a chan.type

      DATA.inouts ||= {}

      self.instance_eval(&block)
    end

    def set_actors array
      @ordered_actors = array
    end

    def type_instance_vars
      @ordered_actors.each do |actor|
        var_names = actor.instance_variables()
        klass = actor.class.get_klass()
        var_names.each do |vname|
          # we remove the @ at the beginning of the name
          vvvname = ((vname.to_s)[1..-1]).to_sym
          if (
            ( !DATA.inouts[actor.class.get_klass()].keys.include?(vvvname) ) &&
            ( ![:name, :initArgs].include?(vvvname) )
          )
            val = actor.instance_variable_get("#{vname}")
            DATA.instance_vars[klass][vvvname] = TypeFactory.create nil, val
          end
        end
      end
    end

    def connect inoutsHash
      inout1, inout2 = inoutsHash.keys.first, inoutsHash.values.first
      DATA.channels << (Channel.new inout1, inout2)
    end


  end #System


end
