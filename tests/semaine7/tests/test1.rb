require_relative "../MTS/mts_compiler"

visitor = MTS::AddProbes.new
compiler = MTS::Compiler.new "./inferMeDyn.rb" #, visitor
compiler.compile_dynamic

#puts visitor.code.get_source

#pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
