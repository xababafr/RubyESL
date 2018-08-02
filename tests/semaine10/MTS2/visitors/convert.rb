module NMTS

  # this class contains only static methods
  # goal : make the necessary conversions betwween ruby and cpp
  # signatures are already handled by TypesObjs.
  # structures like For, While will be handled in the visitor.
  # Anything else is handled here. Ex : Convert::value([1,2]) ==> "{1,2}"
  class Convert
    def self.value val #variable => variable's str code
        # supported types : Bool, Int, Float, String, Arrays
        if val.is_a?(Array)
          val.to_s.gsub("[", "{").gsub("]", "}")
        else
          val.to_s
        end
    end
  end


end
