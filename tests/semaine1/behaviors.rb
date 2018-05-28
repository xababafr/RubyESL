behaviors = []

behaviors << { "entity" => :e1, "proc" => Proc.new do

		for i in 0..10
			send(i, :f)
		end

	end
}

behaviors << { "entity" => :e2, "proc" => Proc.new do

		for i in 0..10
			send(i, :f)
		end

	end
}

behaviors << { "entity" => :comp, "proc" => Proc.new do

		for i in 0..10
			a = receive(:a)
			b = receive(:b)
			v = a*b
			if i < 5
				send(v, :f)
			else
				send("d",:f)
			end
		end

	 end
}

behaviors << { "entity" => :recv, "proc" => Proc.new do

	 	for i in 0..10
			v = receive(:i1)
			puts "received : #{v}"
		end

	 end
}

$connexions = [
	[ {:ename=>:e1, :port=>:f}   , {:ename=>:comp, :port=>:a}  ],
	[ {:ename=>:e2, :port=>:f}   , {:ename=>:comp, :port=>:b}  ],
	[ {:ename=>:comp, :port=>:f} , {:ename=>:recv, :port=>:i1} ]
]

$inouts = {

	:e1 => [{
		:symbol => :f,
	    :type   => [],
		:value  => :nil
	}],

	:e2 => [{
		:symbol => :f,
	    :type   => [],
		:value  => :nil
	}],

	:comp => [{
		:symbol => :a,
		:type   => [],
		:value  => :nil	
	}, {
		:symbol => :b,
		:type   => [],
		:value  => :nil	
	}, {
		:symbol => :f,
		:type   => [],
		:value  => :nil	
	}],

	:recv => [{
		:symbol => :i1,
	    :type   => [],
		:value  => :nil
	}]

}

# FAIRE UN TABLEAU DE VALEURS
def interpretor(proc)
		
	def send(var,symbol)
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

	def receive(symbol)
		ret = :nil
		$inouts[$cEntity].each do |hash|
			if hash[:symbol] == symbol
				ret = hash[:value]
			end
		end
		ret
	end

	proc.call()

end

behaviors.each do |behavior|

	$cEntity = behavior["entity"]
	interpretor( behavior["proc"] )

end

puts $inouts
