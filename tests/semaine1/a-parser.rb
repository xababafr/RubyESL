class Animal
	attr_accessor :nom

	def initialize(nom)
		@nom = nom
	end

	def parler
		puts "je suis #{nom}"
	end
end
