require "../MTS/mts_actors_model"

class Sensor < MTS::Actor
  input :a,:b
  output :f

  def test2
    return 3
  end

  def test(a,b)
    c = test2()
    if a > b
      return (a + b)
    else
      return "0" #union types test
    end
  end

  def behavior
    for i in 0..10
      a=3.14
      b=2
      c=3
      3+4
      d=test a,c
      e = [1,2.4,"10"]
      v=a*(b+c)
      puts "computing #{a}*#{b} => #{v}"
    end
  end
end

sys=MTS::System.new("sys1") do
  sensor_1 = Sensor.new("sens1")
end
