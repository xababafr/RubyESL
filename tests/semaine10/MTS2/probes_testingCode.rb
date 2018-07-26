require "../MTS2/mts_dsl"

# FIR filter

class Sourcer < NMTS::Actor
  output :inp
  thread :behavior

  def behavior
    puts "\nSOURCER::BEHAVIOR()\n\n"
    tmp = 0
    for i in 0...64
      if (i > 23 && i < 29)
register(:i, i)
        tmp = 256
      else
        tmp = 0
      end

      write(tmp, :inp)
      wait()
register(:tmp, tmp)
register(:i, i)
    end
register(:tmp, tmp)
register(:i, i)
  end

end

class Fir < NMTS::Actor
  input  :inp
  output :outp
  thread :behavior

  def initialize name, ucoef
    @coef = [0,0,0,0,0]
    for i in 0...5
      @coef[i] = ucoef[i]
    end

    super(name)
register(:i, i)
  end

  def behavior
    puts "\nFIR::BEHAVIOR()\n\n"

    vals = [0,0,0,0,0]
    while(true)
      for i in 0...4
        j = 4-i
        vals[j] = vals[j-1]
register(:vals, vals)
register(:j, j)
      end
      vals[0] = read(:inp)
      pp vals

      ret = 0
      for i in 0...5
        ret += @coef[i] * vals[i]
      end

      write(ret, :outp)
      wait()
register(:vals, vals)
register(:i, i)
register(:j, j)
register(:ret, ret)
    end
register(:vals, vals)
register(:i, i)
register(:j, j)
register(:ret, ret)
  end
end

class Sinker < NMTS::Actor
  input  :outp
  thread :behavior

  def behavior
    puts "\nSINKER::BEHAVIOR()\n\n"
    for i in 0...64
      datain = read(:outp)
      wait()

      puts "#{i} --> #{datain}"
register(:i, i)
register(:datain, datain)
register(:i, i)
register(:datain, datain)
    end
    stop()
register(:i, i)
register(:datain, datain)
  end

end

# |Sourcer| ==inp==> |Fir| ==outp==> |Sinker|

sys=NMTS::System.new("sys") do
    ucoef = [18,77,107,77,18]

    src0 = Sourcer.new("src0")
    snk0 = Sinker.new("snk0")
    fir0 = Fir.new("fir0", ucoef)

    # here lies the order of the actors for now
    # do they really need to have an order? I dont think so
    set_actors([src0, fir0, snk0])

    connect  src0.inp => fir0.inp
    connect fir0.outp => snk0.outp
end
