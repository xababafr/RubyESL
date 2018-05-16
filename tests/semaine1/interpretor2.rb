code = Proc.new do
	puts "dodo"
	dada()
end

def interpretor(proc)
	def dada()
		puts "dadaaa"
	end
	proc.call()
end

interpretor(code)
