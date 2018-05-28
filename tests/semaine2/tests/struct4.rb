require "../lib/mts_actors_model"

class Emitter < MTS::Actor
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

class Computation < MTS::Actor
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

class Receiver < MTS::Actor
  input :i1
  def behavior
    for i in 0..10
      v=receive(:i1)
      puts "received : #{v}"
    end
  end
end
