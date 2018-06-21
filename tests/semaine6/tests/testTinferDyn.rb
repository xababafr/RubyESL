require_relative "../TINFER/dynamic"

dynamic = TINFER::Dynamic.new "inferMePlz.rb", 10
dynamic.export_types "types"
