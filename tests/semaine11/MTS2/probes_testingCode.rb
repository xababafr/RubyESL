require "../MTS2/mts_dsl"

# FIR filter

class Sourcer < NMTS::Actor
  output :inp
  thread :source

  def source
    puts "SOURCER"
    tmp = 0
    for i in 0...64
      if (i > 23 && i < 29)
register(:i, i, self.class.get_klass(), __method__)
        tmp = 256
      else
        tmp = 0
      end

      write(tmp, :inp)
      wait()
register(:tmp, tmp, self.class.get_klass(), __method__)
register(:i, i, self.class.get_klass(), __method__)
    end
register(:tmp, tmp, self.class.get_klass(), __method__)
register(:i, i, self.class.get_klass(), __method__)
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

    super(name, ucoef)
register(:i, i, self.class.get_klass(), __method__)
  end

  def behavior
    puts "\nFIR::BEHAVIOR()\n\n"

    vals = [0,0,0,0,0]
    while(true)
      for i in 0...4
        j = 4-i
        vals[j] = vals[j-1]
register(:vals, vals, self.class.get_klass(), __method__)
register(:j, j, self.class.get_klass(), __method__)
      end
      vals[0] = read(:inp)

      ret = 0
      for i in 0...5
        ret += @coef[i] * vals[i]
      end

      write(ret, :outp)
      wait()
register(:vals, vals, self.class.get_klass(), __method__)
register(:i, i, self.class.get_klass(), __method__)
register(:j, j, self.class.get_klass(), __method__)
register(:ret, ret, self.class.get_klass(), __method__)
    end
register(:vals, vals, self.class.get_klass(), __method__)
register(:i, i, self.class.get_klass(), __method__)
register(:j, j, self.class.get_klass(), __method__)
register(:ret, ret, self.class.get_klass(), __method__)
  end
end

class Sinker < NMTS::Actor
  input  :outp
  thread :sink

  def sink
    puts "\nSINKER::BEHAVIOR()\n\n"
    for k in 0...64
      datain = read(:outp)
      wait()

      puts "#{k} --> #{datain}"
register(:k, k, self.class.get_klass(), __method__)
register(:datain, datain, self.class.get_klass(), __method__)
register(:k, k, self.class.get_klass(), __method__)
register(:datain, datain, self.class.get_klass(), __method__)
    end
    stop()
register(:k, k, self.class.get_klass(), __method__)
register(:datain, datain, self.class.get_klass(), __method__)
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
