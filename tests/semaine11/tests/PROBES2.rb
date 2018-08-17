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
        puts("
FIR::BEHAVIOR()

")
        vals = [0,0,0,0,0]
register(:vals,vals)
    
        while( (true) )
            (
            for i in ((0...4))
                (
                j = 
                4.-(i)
register(:j,j)
        
                vals.[]=(j, 
        
                val().[](
                j.-(1))))
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

class Sourcer < MTS::Actor
  
    output :inp
  
    def behavior()
        (
        puts("
SOURCER::BEHAVIOR()

")
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
  
  


end

class Sinker < MTS::Actor
    input :outp
  
  
    def behavior()
        (
        puts("
SINKER::BEHAVIOR()

")
        for i in ((0...64))
            (
            datain = 
            receive?(:outp)
register(:datain,datain)
      
            wait()
            puts((i).to_s + " --> " + (datain).to_s))
        end
        puts("sim stopped??"))
    end
  
  


end



sys=MTS::System.new("sys") do
    ucoef = [18,77,107,77,18]

    src0 = Sourcer.new("src0")
    snk0 = Sinker.new("snk0")
    fir0 = Fir.new("fir0", ucoef)

    # here lies the order of the actors for now
    # do they really need to have an order? I dont think so
    set_actors([src0, fir0, snk0])

    connect_as(:csp, src0.inp => fir0.inp)
    connect_as(:csp, fir0.outp => snk0.outp)
end

