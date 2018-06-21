require_relative "../TINFER/static"

static = TINFER::Static.new "struct1.rb"
static.export_types "Stypes"
