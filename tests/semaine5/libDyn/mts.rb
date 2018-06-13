
module MTS

  class AstNode
  end

  class System < AstNode
    def initialize name,&block
      instance_eval(&block)
      @actors={}
    end

    def connect source,sink

    end
  end

  class Actor < AstNode

    def self.inputs
      @inputs ||=[]
    end

    def self.outputs
      @inputs||=[]
    end

    def self.input h
      inputs << i=Input.new(*h.to_a.first)
    end

    def self.output h
      outputs << o=Output.new(*h.to_a.first)
    end

    def self.ports
      inputs + outputs
    end

    def read p_sym
      puts "reading port #{p_sym}"
      port=self.class.inputs.find{|input| input.name==p_sym}
      port.value
    end

    def write p_sym,value
      puts "writing #{value} on port #{p_sym}"
      port=self.class.outputs.find{|port| port.name==p_sym}
      port.value=value
    end

    def method_missing sym,args=[]
      port=self.class.ports.find{|p| p.name==sym}
      if port
        return port
      else
        raise "unkown port named '#{sym}'"
      end
    end
  end

  class Typed < AstNode
    attr_accessor :type
    def initialize type
      @type=type
    end
  end

  class TypedName < Typed
    attr_accessor :name
    def initialize name,type
      super(type)
      @name=name
    end
  end

  class Port < TypedName
    attr_accessor :value
    attr_accessor :sinks
    def initialize name,value
      super(name,value)
      @sinks=[]
    end

    def connect sink
      puts "connecting #{self} --> #{sink}"
      @sinks << sink
    end

    def value=(val)
      @value=val
      @sinks.each{|sink| sink.value=val}
    end
  end

  class Input < Port
  end

  class Output < Port
  end
end
