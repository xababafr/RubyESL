require "../MTS/mts_actors_model"

# FIR filter

class Fir < MTS::Actor
  input  :inp
  output :outp

  def initialize name, ucoef
    @coef = [0,0,0,0,0]
    for i in 0...5
      @coef[i] = ucoef[i]
    end
    add_thread(:fir_main)

    super(name)
  end

  def fir_main
    puts "Fir :: fir_main()"

    vals = [0,0,0,0,0]
    while(true)
      for i in 0...4
        vals[i] = vals[i-1]
      end
      vals[0] = receive?(:inp)

      ret = 0
      for i in 0...5
        ret += coef[i] * vals[i]
      end

      send!(ret, :outp)
      wait()
    end
  end

  def behavior

  end
end


class TestBench < MTS::Actor
  input  :outp
  output :inp

  def initialize name
    add_thread(:source)
    add_thread(:sink)

    super(name)
  end

  def source
    puts "TB :: source()"
    tmp = 0
    for i in 0...64
      if (i > 23 && i < 29)
        tmp = 256
      else
        tmp = 0
      end

      send!(tmp, :inp)
      wait()
    end
  end

  def sink
    puts "TB :: sink()"
    for i in 0...64
      datain = receive?(:outp)
      wait()

      puts "#{i} --> #{datain}"
    end
    #stop()
    puts "sim stopped"
  end

  def behavior

  end

end


sys=MTS::System.new("sys") do
    ucoef = [18,77,107,77,18]

    fir0 = Fir.new("fir0", ucoef)
    tb0 = TestBench.new("tb0")

    # here lies the order of the actors for now
    set_actors([tb0, fir0])

    connect_as(:fifo10, tb0.outp => fir0.inp)
    connect_as(:fifo10, fir0.outp => tb0.inp)
end
