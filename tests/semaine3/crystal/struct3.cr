class OSystem
	property inputs	

	def initialize(name : String, &proc)
		@inputs = Hash{:a => 3, :b => 3.14}
	end
end

class Actor
  def initialize(name : String)
	puts "initialized : #{name}"
  end

  def receive(v)
  	1
  end
  
  def send(v,s)
    puts "sends (#{v}, #{s})"
  end

  def self.input(*inputs)

  end

  def self.output(*outputs)
	
  end
end








class Emitter < Actor
	output :f

	def behaviour
	  (0..10).each do |i|
        send(i, :p)
	  end
	end
end


class Computation < Actor
	input :a, :b
	output :f

	def behaviour
      a = receive(:a)
      b = receive(:b)
      v = (a+b)*2
	  (0..10).each {
        puts "computing v"
        send(v,:p)
	  }
	end
end


class Receiver < Actor
  input :i1

  def behaviour
	(0..10).each {
      i1 = receive(:i1)
      puts "received : #{i1}"
	}
  end
end

sys=OSystem.new("test1") {
  e1=Emitter.new("e1")
  e2=Emitter.new("e2")
  comp=Computation.new("comp")
  recv=Receiver.new("recv")

  connect e1,:f,comp,:a,:fifo10
  connect e2,:f,comp,:b,:fifo10
  connect comp,:f,recv,:i1,:fifo7
}









puts typeof(sys.inputs[:a])
