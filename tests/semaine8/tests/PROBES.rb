require '../MTS/mts_actors_model'

class Camera < MTS::Actor
  
    output :imgT
  
    def behavior()
        (
    
        ((1..5)).each() do |x|
    
        print(x)
register(:x,x)
        end
        fullImg = [[1,1,1,1],[2,2,2,3],[3,3,4,3],[0,1,1,0]]
register(:fullImg,fullImg)
    
        for i in ((0..4))
            (
            puts("sending " + (
            fullImg.[](i)).to_s)
register(:i,i)
register(:fullImg,fullImg)
            send!(
            fullImg.[](i), :imgT))
register(:i,i)
register(:fullImg,fullImg)
        end)
    end
  
  


end

class Processing < MTS::Actor
    input :imgT
  
  
    def processing(img)
        (
    
        img.each() do |pixel|
register(:img,img)
    
        pixel += 1
    
        end)
    end
  
    def behavior()
        (
        for i in ((0..4))
            (
            img = 
            receive?(:imgT)
register(:img,img)
      
            puts("received : img")
            puts("Processed img : " + (
            processing(img)).to_s))
register(:img,img)
        end)
    end
  
  


end

sys=MTS::System.new('sys1') do
    camera = Camera.new('camera')
processing = Processing.new('processing')
set_actors([camera,processing])
connect_as(:fifo10, camera.imgT => processing.imgT)

end
