require '../MTS/mts_actors_model'

class Fir < MTS::Actor
    input :inp
    output :outp
  
    def initialize(name, ucoef)
        (
        @coef = [0,0,0,0,0]
register(:@coef,@coef)
    
        for i in ((0...5))
      
            @coef.[]=(i, 
            ucoef.[](i))
register(:@coef,@coef)
        end
        super(name)
register(:name,name)
        )
    end
  
    def behavior()
        (
        puts("FIR :: behavior()")
        vals = [0,0,0,0,0]
register(:vals,vals)
    
        while( (true) )
            (
            for i in ((0...4))
        
                vals.[]=(i, 
                vals.[](
                i.-(1)))
register(:vals,vals)
            end
            vals.[]=(0, 
            receive?(:inp))
register(:vals,vals)
            ret = 0
register(:ret,ret)
      
            for i in ((0...5))
        
                ret += 
        
                @coef.[](i).*(
                vals.[](i))
register(:@coef,@coef)
        
            end
            send!(ret, :outp)
            wait())
        end)
    end
  
  


end

class TestBench < MTS::Actor
    input :outp
    output :inp
  
    def source()
        (
        puts("TB :: source()")
        tmp = 0
register(:tmp,tmp)
    
        for i in ((0...64))
            (
            if ((( 
            i.>(23) ) && ( 
            i.<(29) )))
        
                tmp = 256
register(:tmp,tmp)
        
            else
        
                tmp = 0
register(:tmp,tmp)
        
            end
      
            send!(tmp, :inp)
            wait())
        end)
    end
  
    def sink()
        (
        puts("TB :: sink()")
        for i in ((0...64))
            (
            datain = 
            receive?(:outp)
register(:datain,datain)
      
            wait()
            puts((i).to_s + " --> " + (datain).to_s))
        end
        stop()
        puts("sim stopped"))
    end
  
    def behavior()
        (
        source()
        sink())
    end
  
  


end



sys=MTS::System.new("sys") do
    ucoef = [18,77,107,77,18]

    fir0 = Fir.new("fir0", ucoef)
    tb0 = TestBench.new("tb0")

    # here lies the order of the actors for now
    set_actors([tb0, fir0])

    connect_as(:fifo10, tb0.inp => fir0.inp)
    connect_as(:fifo10, fir0.outp => tb0.outp)
end

