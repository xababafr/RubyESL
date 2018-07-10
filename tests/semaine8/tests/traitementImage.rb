require "../MTS/mts_actors_model"

# simulates a camera that captures images in real time
# and sends it to a processing unit

# |Camera| -- img --> |Processing|

class Camera < MTS::Actor
  output :imgT

  #def initialize name, fullImg
    # an array of images ( = the video, or successive shots)
    #@fullImg = fullImg
  #end

  # def initialize name
  #   @fullImg = [ [1,1,1,1], [2,2,2,3], [3,3,4,3], [0,1,1,0] ]
  # end

  def behavior
    (1..5).each do |x|
      print x
    end
    fullImg = [ [1,1,1,1], [2,2,2,3], [3,3,4,3], [0,1,1,0] ]
    for i in 0..4
      puts "sending #{fullImg[i]}"
      send!( fullImg[i], :imgT )
    end
  end
end



class Processing < MTS::Actor
  input :imgT

  def processing img
    img.each do |pixel|
      pixel += 1
    end
  end

  def behavior
    for i in 0..4
      img = receive?(:imgT)
      puts "received : img"
      puts "Processed img : #{processing(img)}"
    end
  end
end


sys=MTS::System.new("sys") do
    camera = Camera.new("camera")
    processing = Processing.new("processing")

    # here lies the order of the actors for now
    set_actors([camera,processing])

    connect_as(:fifo10, camera.imgT => processing.imgT)
end
