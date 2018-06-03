# reutiliser la classe channel native?
class OChannel
  property sender
  property receiver
  
  def initialize(@sender : Symbol, @receiver : Symbol)
     
  end
end


class CspChannel < OChannel
  def initialize(sender : Symbol, receiver : Symbol)
    super(sender, receiver)
    @data=nil
  end
  
  def recv()
    until (data=@data)
		Fiber.yield(:RECV_STATE) 
	end
    @data = nil
    data
  end
  
  def send(data)
	while (@data)
    	Fiber.yield(:RECV_STATE)
	end
	@data = data
  end
end
    
    
class KpnChannel < OChannel
	property capacity
      
  def initialize(sender, receiver, @capacity = 10)
  	super(sender, receiver)
    @fifo = [] of ElementType 
  end
      
  def recv()
	until (data=@fifo.shift)
      Fiber.yield(:RECV_STATE)
	end
    data
  end
  
  def send(data)
    while (@fifo.size >= @capacity)
      Fiber.yield(:RECV_STATE)
	end
    @fifo.push(data)
  end
end


class Port
  def initialize(@name : String, @channel : Symbol)
 
  end
  
  def recv()
    @channel.recv()
  end
  
  def send(data)
    @channel.send(data)
  end
end
