# there goes all the global vars of the module
# might not be necessary

require 'singleton'

module MTS

  # globals for the module
  class MetaData
    include Singleton

    attr_accessor :simulator, :channels, :local_vars, :instance_vars

    def initialize

    end
  end

  DATA = MetaData.instance

end
