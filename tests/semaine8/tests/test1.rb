require_relative "../MTS/mts_compiler"

visitor = MTS::AddProbes.new
compiler = MTS::Compiler.new "./traitementImage.rb" #, visitor
compiler.compile_dynamic 1

#puts visitor.code.get_source

#pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
