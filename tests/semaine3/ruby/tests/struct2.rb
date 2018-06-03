require "../lib/mts_actors_model"

class Sensor < MTS::Actor
  input :a,:b
  output :f

  def behavior
    for i in 0..10
      a=3.14
      b=2
      v=a*b
      puts "computing #{a}*#{b} => #{v}"
    end
  end
end

sys=MTS::System.new("sys1") do
  sensor_1 = Sensor.new("sens1")
end
