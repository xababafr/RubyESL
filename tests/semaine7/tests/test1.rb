require_relative "../MTS/mts_compiler"

# visitor = MTS::PrettyPrinter.new
# compiler = MTS::Compiler.new "./inferMeDyn.rb", visitor

visitor = MTS::StaticInfer.new
compiler = MTS::Compiler.new "./inferMeStat.rb", visitor
