# there goes the defition of Ruby's systemC-like DSL
require "./mts_data"
require "./mts_simulator"
require "./mts_types"

module MTS

  class InOut
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
      # the first reads returns the FIRST element written to the channel
      @data.pop
    end

    def write val
      # because when we insert new data, we insert it at position 0
      @data.insert 0, val
      @type = TypeFactory.create nil, val
    end
  end #Channel


  class Actor
    attr_reader :name, :threads

    def initialize name
      @name, @threads = name, []
    end

    def self.input *args
      args.each do |input|
        #@@inouts << ( InOut.new self.class, input, :input )
        send(:attr_accessor, input) # create the attribute
        send(input, ( InOut.new get_klass(), input, :input ) ) # give it a value
      end
    end

    def self.output *args
      args.each do |output|
        #@@inouts << ( InOut.new self.class, output, :output )
        send(:attr_accessor, output)
        send(output, ( InOut.new get_klass(), output, :output ) )
      end
    end

    def get_klass
      self.class.to_s.to_sym
    end

    def add_thread method_sym
      @threads << method_sym
    end

    # the use of break makes sure that only one connexion can be made per inout
    # more connexions will simply not be explored
    def read inout_sym
      ret = nil
      DATA.channels.each do |channel|
        if channel.to == inout_sym
          ret = channel.read
          break
        end
      end
      ret
    end

    def write val, inout_sym
      DATA.channels.each do |channel|
        if channel.from == inout_sym
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

    attr_accessor :reader

    def initialize(name, &block)
      @name = name
      @ordered_actors = []

      # here are the 3 vars that contains the types of all the system's content
      DATA.channels = []
      DATA.local_vars = {}
      DATA.instance_vars = {}
      # channels already have a chan.type

      self.instance_eval(&block)
    end

    def set_actors array
      @ordered_actors = array
      # now, we can create the structures of the typing vars

      actors_classes = []
      @ordered_actors.each do |actor|
        actors_classes << actor.get_klass()
      end
      actors_classes.uniq!

      actors_classes.each do |class_sym|
        DATA.local_vars[class_sym] = {} # method => { var_name => var_type_obj }
        DATA.instance_vars[class_sym] = {}  # var_name => var_type_obj
      end
    end

    def connect inout1, inout2
      DATA.channels << Channel.new inout1, inout2
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
