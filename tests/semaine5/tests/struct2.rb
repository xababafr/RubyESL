require "../lib/mts_actors_model"

class Sensor < MTS::Actor
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

sys=MTS::System.new("sys1") do
  sensor_1 = Sensor.new("sens1")
end
