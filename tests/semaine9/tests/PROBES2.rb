require '../MTS/mts_actors_model'

class Camera < MTS::Actor
  
    output :out1, :out2
  
    def initialize(name, video)
        (
        @fullImg = video
register(:@fullImg,@fullImg)
register(:video,video)
    
        super(name)
register(:name,name)
        )
    end
  
    def behavior()
        (
        for i in ((0..4))
            (
            puts("sending " + (
            @fullImg.[](i)).to_s)
register(:@fullImg,@fullImg)
            send!(
            @fullImg.[](i), :out1)
register(:@fullImg,@fullImg)
            send!(
            @fullImg.[](i), :out2))
register(:@fullImg,@fullImg)
        end)
    end
  
  


end

class Processing < MTS::Actor
    input :imgT
  
  
    def initialize(name, algo)
        (
        @algo = algo
register(:@algo,@algo)
register(:algo,algo)
    
        super(name)
register(:name,name)
        )
    end
  
    def processing(img)
        (
        output = 
        Array.new()
register(:output,output)
register(:Array,Array)
    
        if (
        @algo.==("+"))
register(:@algo,@algo)
      
      
            img.each() do |pixel|
register(:img,img)
      
            output.push(
            pixel.+(1))
register(:output,output)
register(:pixel,pixel)
            end
        else
      
            if (
            @algo.==("-"))
register(:@algo,@algo)
        
        
                img.each() do |pixel|
register(:img,img)
        
                output.push(
                pixel.-(1))
register(:output,output)
register(:pixel,pixel)
                end
            else
        
                output = img
register(:output,output)
register(:img,img)
        
            end
      
        end
        output)
register(:output,output)
    end
  
    def behavior()
        (
        for i in ((0..4))
            (
            img = 
            receive?(:imgT)
register(:img,img)
      
            puts("received : " + (img).to_s + " (by " + (@name).to_s + ")")
            processed = 
            processing(img)
register(:processed,processed)
      
            puts("Processed img : " + (processed).to_s))
        end)
    end
  
  


end



sys=MTS::System.new("sys") do
    camera = Camera.new("camera", [ [1,1,1,1], [2,2,2,3], [3,3,4,3], [0,1,1,0] ])
    proc1 = Processing.new("processing", "-")
    proc2 = Processing.new("processing", "+")

    # here lies the order of the actors for now
    set_actors([camera,proc1, proc2])

    connect_as(:fifo10, camera.out1 => proc1.imgT)
    connect_as(:fifo10, camera.out2 => proc2.imgT)
end

