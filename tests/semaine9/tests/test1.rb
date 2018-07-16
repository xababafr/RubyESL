require_relative "../MTS/mts_compiler"

compiler = MTS::Compiler.new "./traitementImage.rb" #, visitor
compiler.compile_systemc 1

#puts visitor.code.get_source

#pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
