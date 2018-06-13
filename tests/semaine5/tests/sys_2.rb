require "../libDyn/mts_actors_model"

class Sensor < MTS::Actor
  output :o1
  def behavior
    x=0
    while true
      send!(x,:o1)
      x+=1
      wait
    end
  end
end

class Processing < MTS::Actor
  input  :e1, :e2
  output :o
  def behavior
    accu=0
    while true
      v1=receive?(:e1)
      v2=receive?(:e2)
      accu+=v1+v2
      send!(accu,:o)
    end
  end
end

class Actuator < MTS::Actor
  def behavior
    while true
      v=receive?(:e)
      puts "actuating with value #{v}"
      puts "cycle #{now}"
    end
  end
end

sys=MTS::System.new("sys1") do
    sensor_1 = Sensor.new("sens1")
    sensor_2 = Sensor.new("sens2")
    compute  = Processing.new("proc1")
    actuator = Actuator.new("actu1")

    connect_as(:fifo5, sensor_1.o1 => compute.e1)
    connect_as(:fifo2, sensor_2.o1 => compute.e2)
    connect_as(:fifo4, compute.o   => actuator.e)
end
