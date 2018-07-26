module NMTS

  DATA.verbose = [
    :Compiler
  ]

  def check_verbose obj
    DATA.verbose.include?( obj.class.to_s.split("::")[0].to_sym )
  end

  def V_print obj, str
    # use caller to get caller's class, then check if it can print
    if check_verbose
      print str
    end
  end

  def V_pp obj, var
    if check_verbose obj
      pp self, var
    end
  end

end
