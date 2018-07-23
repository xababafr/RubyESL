require_relative "../MTS/mts_compiler"

compiler = MTS::Compiler.new "./fir2.rb" #, visitor
compiler.compile_systemc 1, "PROBES", "SYSTEMC"

#puts visitor.code.get_source

#pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
