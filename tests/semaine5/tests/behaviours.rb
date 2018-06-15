require_relative "../libDyn/mts_simulator"
require_relative "../libDyn/mts_actors_model"
require_relative "../libDyn/mts_actors_sim"

simulator=MTS::Simulator.new
sys=simulator.open "./sys_2.rb"

pp sys

behaviours = []
$inouts = {}

behaviours << { :entity => :sens1, :proc => Proc.new do

    x=0
    while true
      send!(x,:o1)
      x+=1
      wait
    end

	end
}

behaviours << { :entity => :sens2, :proc => Proc.new do

    x=0
    while true
      send!(x,:o1)
      x+=1
      wait
    end

	end
}

behaviours << { :entity => :proc1, :proc => Proc.new do

    accu=0
    while true
      v1=receive?(:e1)
      v2=receive?(:e2)
      accu+=v1+v2
      send!(accu,:o)
    end

	 end
}

behaviours << { :entity => :actu1, :proc => Proc.new do

    while true
      v=receive?(:e)
      puts "actuating with value #{v}"
      puts "cycle #{now}"
    end

	 end
}

sys.ordered_actors.each do |actor|
  # behaviours << {
  #   :entity => actor.name,
  #    :proc  => actor.method(:behaviour).to_proc
  # }

  currentInouts = []

  inputs, outputs = actor.class.getInouts[0], actor.class.getInouts[1]

  if !(inputs.nil?)
    inputs.each do |sym|
      currentInouts << {
        :symbol => sym,
        :direction => :input,
        :type => [],
        :value => :nil
      }
    end
  end

  if !(outputs.nil?)
    outputs.each do |sym|
      currentInouts << {
        :symbol => sym,
        :direction => :output,
        :type => [],
        :value => :nil
      }
    end
  end

  $inouts[actor.name.to_sym] = currentInouts
end

$connexions = sys.connexions

#pp $inouts
pp behaviours
#pp sys.connexions


# FAIRE UN TABLEAU DE VALEURS
def interpretor(proc)

	def send!(var,symbol)
    puts "SEND!! CALLED"
		# 1/ write the value in the correspondig symbol
		$inouts[$cEntity].each do |hash|
			if hash[:symbol] == symbol
				hash[:value] = var
				hash[:type] << var.class
				hash[:type] = hash[:type].uniq
			end
		end

		# 2/ write it to the symbols that are connected to the previous one
		$connexions.each do |connexion|
			if ( connexion[0][:ename] == $cEntity )  &&  ( connexion[0][:port] == symbol )
				# then repeat 1/ on the connected symbol (might happen more than once if multiple connexions)
				$inouts[ connexion[1][:ename] ].each do |hash|
					if hash[:symbol] == connexion[1][:port]
						hash[:value] = var
						hash[:type] << var.class
						hash[:type] = hash[:type].uniq
					end
				end
			end
		end
	end

	def receive?(symbol)
    puts "RECEIVE!! CALLED"
		ret = :nil
		$inouts[$cEntity].each do |hash|
			if hash[:symbol] == symbol
				ret = hash[:value]
			end
		end
		ret
	end

  def wait

  end

	proc.call()

end

behaviours.each do |behaviour|

	$cEntity = behaviour[:entity]
	interpretor( behaviour[:proc] )

end

puts $inouts
