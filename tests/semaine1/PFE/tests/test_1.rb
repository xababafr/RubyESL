require "pp"
require_relative "../lib/actors"

class Emitter < Actor
  output :f
  def initialize name
    super(name)
  end

  def behavior
    for i in 0..10
      send(i,:f)
    end
  end
end

class Computation < Actor
  input :a,:b
  output :f

  def behavior
    for i in 0..10
      a=receive(:a)
      b=receive(:b)
      v=a*b
      puts "computing #{a}*#{b} => #{v}"
      send(v,:f)
    end
  end
end

class Receiver < Actor
  input :i1
  def behavior
    for i in 0..10
      v=receive(:i1)
      puts "received : #{v}"
    end
  end
end

sys=System.new("test1"){
  e1=Emitter.new("e1")
  e2=Emitter.new("e2")
  comp=Computation.new("comp")
  recv=Receiver.new("recv")

  connect e1,:f,comp,:a,:fifo10
  connect e2,:f,comp,:b,:fifo10
  connect comp,:f,recv,:i1,:fifo7
}

require_relative "../lib/simulator"
simulator=RubyESL::Simulator.new(sys)
simulator.stop_when "recv" => :ENDED
simulator.run
