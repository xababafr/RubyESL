# there goes all the global vars of the module
# might not be necessary

require 'singleton'

module NMTS

  # globals for the module
  class GlobalData
    include Singleton

    attr_accessor :simulator, :channels, :local_vars, :instance_vars, :inouts

    # :simulator => <Simulator>
    #
    # :channels => [<Channel>]
    #
    # :local_vars => {
    #   klass => {
    #     method => {
    #       var_name => [var_last_value,var_type_obj]
    #     }
    #   }
    # }
    #
    # :instance_vars => {
    #   klass => {
    #     var_name => [var_last_value,var_type_obj]
    #   }
    # }
    #
    # :inouts => {
    #   klass =>  {
    #     inout_name => inout_obj
    #   }
    # }

    def initialize
      self.channels ||= []
      self.local_vars ||= {}
      self.instance_vars ||= {}
      self.inouts ||= {}
    end
  end

  DATA = GlobalData.instance

end
