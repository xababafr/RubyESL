require "../MTS/mts_actors_model"

# simulates a camera that captures images in real time
# and sends it to a processing unit

# |Camera| -- img --> |Processing|

class Camera < MTS::Actor
  output :out1, :out2

  def initialize name, video
    @fullImg = video
    super(name)
  end

  def behavior
    for i in 0..4
      puts "sending #{@fullImg[i]}"
      send!( @fullImg[i], :out1 )
      send!( @fullImg[i], :out2 )
    end
  end
end



class Processing < MTS::Actor
  input :imgT

  def initialize name, algo
    @algo = algo
    super(name)
  end

  def processing img
    output = Array.new
    if @algo == "+"
      img.each do |pixel|
        output.push(pixel + 1)
      end
    elsif @algo == "-"
      img.each do |pixel|
        output.push(pixel - 1)
      end
    else
      output = img
    end
    output
  end

  def behavior
    for i in 0..4
      img = receive?(:imgT)
      puts "received : #{img} (by #{@name})"
      processed = processing(img)
      puts "Processed img : #{processed}"
    end
  end
end


sys=MTS::System.new("sys") do
    camera = Camera.new("camera", [ [1,1,1,1], [2,2,2,3], [3,3,4,3], [0,1,1,0] ])
    proc1 = Processing.new("proc1", "-")
    proc2 = Processing.new("proc2", "+")

    # here lies the order of the actors for now
    set_actors([camera,proc1, proc2])

    connect_as(:fifo10, camera.out1 => proc1.imgT)
    connect_as(:fifo10, camera.out2 => proc2.imgT)
end
