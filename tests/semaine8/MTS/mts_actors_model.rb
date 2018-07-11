#.....................................
# (c) jean-christophe le lann 2008
#  ENSTA Bretagne
#.....................................

require 'pp'
require_relative 'mts_types'
require_relative 'mts_metadata'

module MTS

  class Port
    attr_accessor :actor #belonging actor
    attr_accessor :channel
    def initialize(name)
      @channel=nil
      @actor=nil
    end
  end

  class Actor
    attr_reader :name
    attr_accessor :ports

    def initialize(name)
      @name = name
      @ports={}
      create_inputs
      create_outputs
    end

    # on peut potentiellement decrire toutes les variables d'une fonction d'un coup
    # cette fonction est obsolète et useless?
    # def type hash
    #   caller_method = caller_locations(1,1)[0].label
    #   hash.each do |name, typ|
    #     #puts "TYPES(#{name}, #{typ})"
    #     @_varTypes ||= {}
    #     @_varTypes[caller_method] ||= {}
    #     @_varTypes[caller_method][name] = TypeFactory.create typ
    #   end
    # end

    def get_types
      @_varTypes
    end

    def self.getInouts
      [@_inputs,@_outputs]
    end

    def self.input *args
      #are we before or after the annotation?
      if args.first.is_a?(Symbol)

        args.each do |name|
          send(:attr_accessor, name)
          # take note of this new input, we'll use it later
          @_inputs ||= []
          @_inputs << name
        end

      else

        # the hash has the {:a => :Integer} structure
        args.first.each do |name, typ|
          send(:attr_accessor, name)
          # take note of this new input, we'll use it later
          @_inputs ||= []
          @_inputs << name

          # for now I use another var to not break the system
          @_inputsTypes ||= {}
          @_inputsTypes[name] = typ
        end

      end

    end

    def self.output *args

      #are we before or after the annotation?
      if args.first.is_a?(Symbol)

        # THE CODE ISNT ANNOTED YET
        args.each do |name|
          send(:attr_accessor, name)
          # take note of this new input, we'll use it later
          @_outputs ||= []
          @_outputs << name
        end

      else

        # THE CODE IS ANNOTED
        args.first.each do |name, typ|
          send(:attr_accessor, name)
          # take note of this new input, we'll use it later
          @_outputs ||= []
          @_outputs << name

          # for now I use another var to not break the system
          @_outputsTypes ||= {}
          @_outputsTypes[name] = typ
        end

      end


    end

    def create_inputs
      ports_to_create=self.class.instance_variable_get(:@_inputs)
      ports_to_create.each do |name|
        send("#{name}=", p=Port.new(name))
        @ports[name]=p
        p.actor=self
      end if ports_to_create
    end

    def create_outputs
      ports_to_create=self.class.instance_variable_get(:@_outputs)
      ports_to_create.each do |name|
        send("#{name}=", p=Port.new(name))
        @ports[name]=p
        p.actor=self
      end if ports_to_create
    end
  end

  class Channel
    attr_reader :sender, :receiver
    def initialize(sender, receiver)
      @sender = sender
      @receiver = receiver
    end
  end

  class CspChannel < Channel
    def initialize(sender, receiver)
      super(sender,receiver)
      @data=nil
    end
  end

  class KpnChannel < Channel
    attr_accessor :capacity
    def initialize(sender, receiver,capacity=10)
      super(sender,receiver)
      @capacity=capacity
      @fifo=[]
    end
  end

  class WireChannel < Channel
    def initialize(sender, receiver,capacity=10)
      super(sender,receiver)
      @capacity=capacity
      @data=nil
    end
  end

  class System
    attr_reader :name,:actors,:ordered_actors, :connexions, :inouts
    attr_accessor :blockStr

    def initialize(name, &block)
      @name = name
      @actors = {}

      # my vars
      @ordered_actors = []
      @connexions = []

      @log={}
      self.instance_eval(&block)
    end

    def set_actors array
      @ordered_actors = array
    end

    # for temp file, temporary solution hehe
    def register sym, val

    end

    def create_inouts

      @inouts = {}

      @ordered_actors.each do |actor|
        currentInouts = []

        inputs, outputs = actor.class.getInouts[0], actor.class.getInouts[1]

        if !(inputs.nil?)
          inputs.each do |sym|
            currentInouts << {
              :symbol => sym,
              :direction => :input,
              :type => [],
              :value => :nil
            }
          end
        end

        if !(outputs.nil?)
          outputs.each do |sym|
            currentInouts << {
              :symbol => sym,
              :direction => :output,
              :type => [],
              :value => :nil
            }
          end
        end

        @inouts[actor.class.to_s.to_sym] = currentInouts

        # global access across the module
        DATA.inouts = @inouts
      end

    end

    # NOT WORKING YET
    # connect [Actor, :port] => [Actor2, :port2] , fifo
    def connect hash, fifo = :fifo10
      hash.first do |src,dst|
        source, sink = src[0], src[1]
        actors[source.actor.name]=source.actor
        @actors[ sink.actor.name ]=sink.actor
        channel=(fifo==:csp) ? CspChannel.new(source, sink) : KpnChannel.new(source,sink, capacity(fifo))
        source.channel=channel
        sink.channel=channel
      end
    end

    def connect_as moc_sym,source_sink_h
      source,sink=*source_sink_h.to_a.first
      @actors[source.actor.name]=source.actor
      @actors[ sink.actor.name ]=sink.actor
      channel=(moc_sym==:csp) ? CspChannel.new(source, sink) : KpnChannel.new(source,sink, capacity(moc_sym))
      source.channel=channel
      sink.channel=channel

      # ugly but for now I dont have the time to rework the Port class
      sourcePort = :undefined
      source.actor.ports.each do |key, val|
        #puts "SOURCE KEY/VAL : (#{key} , #{val})"
        if val == source
          sourcePort = key
        end
      end

      sinkPort = :undefined
      sink.actor.ports.each do |key, val|
        #puts "SINK KEY/VAL : (#{key} , #{val})"
        if val == sink
          sinkPort = key
        end
      end

      @connexions << [
          {
            :ename => source.actor.name.to_sym,
            :cname => source.actor.class.to_s.to_sym,
            :port => sourcePort,
            :moc => moc_sym
          },
          {
            :ename => sink.actor.name.to_sym,
            :cname => sink.actor.class.to_s.to_sym,
            :port => sinkPort,
            :moc => moc_sym
          }
      ]

      # global access
      DATA.connexions = @connexions
    end

    def capacity(moc)
      fifo=moc.to_s.match(/\A(kpn|fifo)(?<size>\d+)/)
      capacity=fifo.size if fifo
    end
  end
end #MTS
