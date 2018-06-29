require_relative "../MTS/mts_compiler"

visitor = MTS::AddProbes.new
compiler = MTS::Compiler.new "./inferMeStat.rb", visitor

pp visitor.code.registerCalls

# visitor = MTS::StaticInfer.new
# compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
