require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./struct1.rb"
analyzer.parse
