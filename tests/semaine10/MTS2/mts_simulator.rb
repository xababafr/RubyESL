# this class defines the simulator of the system

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
