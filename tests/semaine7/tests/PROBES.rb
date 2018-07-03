require '../MTS/mts_actors_model'

class UselessClass
  
  
  
    def initialize()
        ()
    end
  
  


end

class Sensor < MTS::Actor
  
    output :o1, :o2
  
    def behavior()
        (
        x = 0
register(:x,x)
    
        y = [1,2,"3"]
register(:y,y)
    
        y.<<([1.2])
register(:y,y)
        while (true)
            (
            send!(x, :o1)
register(:x,x)
            send!(y, :o2)
register(:y,y)
            x += 1.2
      
            wait())
        end)
    end
  
  


end

class Processing < MTS::Actor
    input :e1, :e2, :e3, :e4
    output :o
  
    def behavior()
        (
        accu = 0
register(:accu,accu)
    
        accu += 1
    
        while (true)
            (
            v1 = 
            receive?(:e1)
register(:v1,v1)
      
            v2 = 
            receive?(:e2)
register(:v2,v2)
      
            v3 = 
            receive?(:e3)
register(:v3,v3)
      
            v4 = 
            receive?(:e4)
register(:v4,v4)
      
            accu += 
            v1.+(v2)
register(:v2,v2)
register(:v1,v1)
      
            if ((
            v2.>(5)))
register(:v2,v2)
        
                send!(accu, :o)
register(:accu,accu)
            else
        
                send!(
                UselessClass.new(), :o)
            end)
        end)
    end
  
  


end

class Actuator < MTS::Actor
    input :e
  
  
    def behavior()
        (
        while (true)
            (
            v = 
            receive?(:e)
register(:v,v)
      
            puts("actuating with value " + (v).to_s)
register(:v,v)
            puts("cycle " + (
            now()).to_s))
        end)
    end
  
  


end

sys=MTS::System.new('sys1') do
    sens1 = Sensor.new('sens1')
sens2 = Sensor.new('sens2')
proc1 = Processing.new('proc1')
actu1 = Actuator.new('actu1')
set_actors([sens1,sens2,proc1,actu1])
connect_as(:fifo5, sens1.o1 => proc1.e1)
connect_as(:fifo2, sens2.o1 => proc1.e2)
connect_as(:fifo5, sens1.o2 => proc1.e3)
connect_as(:fifo5, sens2.o2 => proc1.e4)
connect_as(:fifo4, proc1.o => actu1.e)

end
