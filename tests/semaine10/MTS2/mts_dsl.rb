# there goes the defition of Ruby's systemC-like DSL
require "./mts_data"
require "./mts_simulator"
require "./mts_types"

module NMTS

  class InOut
    attr_reader :klass, :sym, :dir
    def initialize klass, sym, dir
      @klass, @sym, @dir = klass, sym, dir
    end
  end


  class Channel
    attr_reader :from, :to, :type

    def initialize inout1, inout2
      @from, @to, @data, @type = inout1, inout2, [], nil
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
    attr_reader :name, :threads

    def initialize name
      V_print self, "dsl_newActor #{self.class.get_klass()}"
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
      V_print self, "dsl_input #{get_klass()} => #{args}"
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
      V_print self, "dsl_output #{get_klass()} => #{args}"
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
      V_print self, "dsl_thread #{get_klass()} => #{args}"
      @@threads ||= []
      args.each do |thread|
        @@threads << thread
      end
    end

    def self.get_threads
      @@threads ||= []
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

    def register name, val, klass, method
      #V_print self, "REGISTER : (#{klass}, #{method}) ==> (#{name}, #{var})"
      DATA.local_vars[klass][method] ||= {}
      DATA.local_vars[klass][method][name] ||= []
      prev_val = DATA.local_vars[klass][method][name][0] # can be nil
      DATA.local_vars[klass][method][name] = [val, TypeFactory.create(prev_val, val)]
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
      DATA.channels ||= []
      DATA.local_vars ||= {}
      DATA.instance_vars ||= {}
      # channels already have a chan.type

      DATA.inouts ||= {}

      self.instance_eval(&block)
    end

    def set_actors array
      # actors_classes = []
      # array.each do |actor|
      #   actors_classes << actor.class.get_klass()
      # end
      # @ordered_actors = actors_classes.uniq!
      @ordered_actors = array
    end

    def type_instance_vars
      @ordered_actors.each do |actor|
        var_names = actor.instance_variables()
        klass = actor.class.get_klass()
        var_names.each do |vname|
          val = actor.instance_variable_get("#{vname}")
          DATA.instance_vars[klass][vname] = TypeFactory.create nil, val
        end
      end
    end

    def connect inoutsHash
      V_print self, "dsl_connect #{inoutsHash}"
      inout1, inout2 = inoutsHash.keys.first, inoutsHash.values.first
      DATA.channels << (Channel.new inout1, inout2)
    end

    # returns the channel that corresponds to this inout
    # breaks ==> no doublons allowed
    def get_channel inout
      ret = nil
      DATA.channels.each do |channel|
        if channel.from == inout_sym || channel.to == inout_sym
          ret = channel
          break
        end
      end
      ret
    end

  end #System


end
