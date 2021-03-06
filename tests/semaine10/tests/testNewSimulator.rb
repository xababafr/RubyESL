require "fiber"

class Simulator
  def initialize
    @mustStop = false
    @time = 0
    @fibers = {} #fiber's name ==> the fiber itself
  end

  def add_fiber name, fiber
    @fibers[name] = fiber
  end

  def keep_going
    ret = false
    @fibers.each_value do |fiber|
      if fiber.alive?
        ret = true
      end
    end
    if @time > 100 || @mustStop
      ret = false
    end
    ret
  end

  def stop
    @mustStop = true
  end

  def step
    @time += 1
    @fibers.each do |name,fiber|
      if fiber.alive?
        fiber.resume
      end
    end
    puts " ==================[#{@time}]================== "
  end

  def run
    puts "[[  simulation starts  ]]"
    puts "\n"

    while keep_going do
      step
    end

    puts "\n"
    puts "[[   simulation ends   ]]"
  end
end





DATA = {
  :outp => nil,
  :inp  => nil
}

def wait
  Fiber.yield
end

def send val, port
  DATA[port] = val
end

def receive port
  DATA[port]
end

fiber1 = Fiber.new do
  coef = [18,77,107,77,18]
  vals = [0,0,0,0,0]
  while(true)
    for i in 0...4
      j = 4-i
      vals[j] = vals[j-1]
    end
    vals[0] = receive(:inp)

    ret = 0
     for i in 0...5
      ret += coef[i] * vals[i]
    end

    send(ret, :outp)
    wait()
  end
end

fiber2 = Fiber.new do
  tmp = 0
  for i in 0...64
    if (i > 23 && i < 29)
      tmp = 256
    else
      tmp = 0
    end

    send(tmp, :inp)
    wait()
  end
end

fiber3 = Fiber.new do
  for i in 0...64
    datain = receive(:outp)
    wait()

    puts "#{i} --> #{datain}"
  end
  stop()
end

SIMULATOR = Simulator.new

def stop
  SIMULATOR.stop
end

SIMULATOR.add_fiber "fib1", fiber2
SIMULATOR.add_fiber "fib2", fiber1
SIMULATOR.add_fiber "fib3", fiber3

SIMULATOR.run
