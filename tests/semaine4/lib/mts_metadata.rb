module MTS

  class Metadata
    attr_accessor :contexts, :currentContext, :methods
    include Singleton

    def initialize
      @contexts, @currentContext, @methods = nil, nil, nil
    end
  end

end
