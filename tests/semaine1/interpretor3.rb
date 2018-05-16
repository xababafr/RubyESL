code = Proc.new do
	for i in 0..10
		a = receive(:a)
		b = receive(:b)
		v = a*b
		send(v,:f)
	end
end

def interpretor(proc)
	# here we can say that :a ad :b corresponds to 2 and 3 thanks to a corresponding table updated by previous evals()	
	corresp = [[:a, 2], [:b, 3]]
		
	def send(var,symbol)
		corres << [symbol, var]
	end

	def receive(symbol)
		ret = :nil
		corresp.each { |tab|
			if tab[0] == symbol
				ret tab[1]
			end
		}
		ret
	end
	proc.call()
end

interpretor(code)
