#.....................................
# (c) jean-christophe le lann 2008
#  ENSTA Bretagne
#.....................................

require 'fiber'

class Port
  def initialize(name, channel)
    @channel = channel
  end

  def recv()
    @channel.recv()
  end

  def send(data)
    @channel.send(data)
  end
end

class TaggedValue
  attr_accessor :time,:value
  def initialize time,val
    @time,@value=time,val
  end
end

class Actor
  attr_reader :name, :state
  attr_reader :executed_steps
  attr_accessor :log
  def initialize(name)
    @name = name
    @ports={}
    @state = :IDLE
    @executed_steps=0
    @history=[]
    @log={:time=>[0]}
  end

  def increment_time inc
    @log[:time] << now+inc
  end

  def set_time time
    @log[:time] << time
  end

  def now
    @log[:time].last
  end

  def log_data data,value
    @log[data]||=[]
    @log[data] << {now => value}
  end

  def self.input *symbols
    symbols.each do |name|
      self.class.send(:attr_accessor, name)
    end
  end

  def self.output *symbols
    symbols.each do |name|
      self.class.send(:attr_accessor, name)
    end
  end

  def behavior
  end

  def receive(port)
    tagged_value = @ports[port].recv()
    fix_current_time_with(tagged_value.time)
    return tagged_value.value
  end

  # def receive(port)
  #   @ports[port].recv()
  # end

  def fix_current_time_with time
    current_time=(time<=now) ? nil : [time,now].max
    if current_time #not nil
      puts "fixing time for causality. Was : #{time} <= #{now} !"
      @log[:time].pop
      set_time current_time
    end
  end

  def send(data, port)
    @ports[port].send TaggedValue.new(now,data)
    increment_time(1)
  end

  def setPort(portName, channel)
    @ports[portName] = Port.new(portName, channel)
  end

  def start
    @fiber = Fiber.new {
      self.method(:behavior).call
      @state = :ENDED
    }
  end

  def step
    @state = @fiber.resume
    @executed_steps+=1
    @state
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

  def recv
    Fiber.yield(:RECV_STATE) until (data=@data)
    @data = nil
    data #[t,value]
  end

  def send(data)
    Fiber.yield(:SEND_STATE) while @data
    @data = data
  end
end

class KpnChannel < Channel
  attr_accessor :capacity
  def initialize(sender, receiver,capacity=10)
    super(sender,receiver)
    @capacity=capacity
    @fifo=[]
  end

  def recv
    Fiber.yield(:RECV_STATE) until (data=@fifo.shift)
    data
  end

  def send(data)
    Fiber.yield(:SEND_STATE) while @fifo.size >= @capacity
    @fifo.push data
  end
end

class WireChannel < Channel
  def initialize(sender, receiver,capacity=10)
    super(sender,receiver)
    @capacity=capacity
    @data=nil
  end

  def read
  end

  def write(data)
  end
end

class System
  attr_reader :name,:actors,:log
  def initialize(name, &block)
    @name = name
    @actors = {}
    @log={}
    self.instance_eval(&block)
  end

  def connect(act_out, port_out, act_in, port_in,moc)
    @actors[act_out.name] = act_out
    @actors[act_in.name]  = act_in
    channel = (moc==:csp) ? CspChannel.new(act_out, act_in) : KpnChannel.new(act_out, act_in, capacity(moc))
    act_out.setPort(port_out, channel)
    act_in.setPort(port_in, channel)
  end

  def capacity(moc)
    fifo=moc.to_s.match(/\A(kpn|fifo)(?<size>\d+)/)
    capacity=fifo.size if fifo
  end
end
