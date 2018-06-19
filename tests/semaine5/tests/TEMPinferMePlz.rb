require "../libDyn/mts_actors_model"

class UselessClass
  def initialize

  end
end

class Sensor < MTS::Actor
  output :o1, :o2
  def behavior
    x=0
register(:x,x)
    y = [1,2,"3"]
register(:y,y)
    while true
      send!(x,:o1)
      send!(y,:o2)
      x+=1.2
      wait
    end
  end
end

class Processing < MTS::Actor
  input  :e1, :e2, :e3, :e4
  output :o
  def behavior
    accu=0
register(:accu,accu)
    while true
      v1=receive?(:e1)
register(:v1,v1)
      v2=receive?(:e2)
register(:v2,v2)
      v3=receive?(:e3)
register(:v3,v3)
      v4=receive?(:e4)
register(:v4,v4)
      accu+=v1+v2

      #testing union type
      if (v2 > 5)
        send!(accu,:o)
      else
        send!(UselessClass.new, :o)
      end
    end
  end
end

class Actuator < MTS::Actor
  input :e
  def behavior
    while true
      v=receive?(:e)
register(:v,v)
      puts "actuating with value #{v}"
      puts "cycle #{now}"
    end
  end
end

sys=MTS::System.new("sys1") do
    sensor_1 = Sensor.new("sens1")
register(:sensor_1,sensor_1)
    sensor_2 = Sensor.new("sens2")
register(:sensor_2,sensor_2)
    compute  = Processing.new("proc1")
register(:compute,compute)
    actuator = Actuator.new("actu1")
register(:actuator,actuator)

    # here lies the order of the actors for now
    set_actors([sensor_1,sensor_2, compute, actuator])

    #connect ({ [sensor_1, :o1] => [compute, :e1] }) , :fifo5
    #connect ({ [sensor_2, :o1] => [compute, :e1] }) , :fifo2
    #connect ({ [compute, :o]  => [actuator, :e] }) , :fifo4

    connect_as(:fifo5, sensor_1.o1 => compute.e1)
    connect_as(:fifo2, sensor_2.o1 => compute.e2)

    connect_as(:fifo5, sensor_1.o2 => compute.e3)
    connect_as(:fifo5, sensor_2.o2 => compute.e4)

    connect_as(:fifo4, compute.o   => actuator.e)
end
