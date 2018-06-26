require 'singleton'

module MTS

  # globals for the module
  class MetaData
    attr_accessor :contexts, :currentContext, :returnTypes, :methods, :signatures, :inouts, :connexions
    include Singleton

    def initialize inouts = nil, connexions = nil
      #static
      @contexts, @currentContext, @methods, @returnTypes, @signatures = nil, nil, nil, nil, nil

      #static and dynamic
      @inouts, @connexions = inouts, connexions
    end
  end

  DATA = MetaData.instance
  DATA.signatures = {
    # the key is the name of the class . the name of the method
    # the value is a hash of inputs to outputs types
    "MTS::FloatLit.*" => {
      ["MTS::IntLit"] => "MTS::FloatLit"
    },
    "MTS::IntLit.+" => {
      ["MTS::IntLit"] => "MTS::IntLit"
    },
    "MTS::FloatLit.+" => {
      ["MTS::IntLit"] => "MTS::FloatLit",
      ["MTS::FloatLit"] => "MTS::FloatLit",
    },
    ".puts" => {
      ["MTS::Dstr"] => "MTS::StrLit",
      ["MTS::Str"] => "MTS::StrLit",
    }
  }

end
