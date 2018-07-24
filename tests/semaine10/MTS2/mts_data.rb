# there goes all the global vars of the module

require 'singleton'

module MTS

  # globals for the module
  class MetaData
    include Singleton

    def initialize

    end
  end

  DATA = MetaData.instance

end
