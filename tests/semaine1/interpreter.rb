def interpretor() 
	
	def dada()
		puts "dadaaaa"
	end

	yield if block_given?

end

interpretor do
	puts "dodo"
	dada
end
