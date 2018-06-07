module MTS
  SIGNATURES = {
    # the key is the name of the class . the name of the method
    # the value is a hash of inputs to outputs types
    "MTS::FloatLit.*" => {
      ["MTS::IntLit"] => "MTS::FloatLit"
    },
    "MTS::IntLit.+" => {
      ["MTS::IntLit"] => "MTS::IntLit"
    },
  }
end
