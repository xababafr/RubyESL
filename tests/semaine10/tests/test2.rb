require_relative "../MTS/mts_compiler"

compiler = MTS::Compiler.new "./fir3.rb" #, visitor
compiler.compile_dynamic 60, "PROBES2" #, "SYSTEMC"

#puts visitor.code.get_source

#pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
