require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./struct2.rb"
analyzer.parse
pp analyzer.behaviors
