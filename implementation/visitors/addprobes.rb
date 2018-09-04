require_relative "./code"
require_relative "./visitor"
require_relative "./prettyprinter"
require_relative "./convert"

module RubyESL


  class AddProbes < PrettyPrinter
    attr_reader :code
    attr_accessor :parents_stack

    def create_register_call calling_node, varName
      if varName[0] == "@"
        rStr = "register(:#{varName},#{varName}, self.class.get_klass())"
      else
        rStr = "register(:#{varName},#{varName}, self.class.get_klass(), __method__)"
      end
      parent = @parents_stack.last
      if !parent.nil?
        parent.stmts.each_index do |i|
          node = parent.stmts[i]
          if node == calling_node && !parent.systemBlock
            callObj = RubyCode.new rStr
            parent.stmts.insert(i+1, callObj)
          end
        end
      end
    end

    def initialize
      @code = Code.new "    "
      @parents_stack = []
    end

    # returns the channel that corresponds to this inout
    # breaks ==> no doublons allowed
    def get_channel inout, channels
      ret = nil
      channels.each do |channel|
        if channel.from == inout || channel.to == inout
          ret = channel
          break
        end
      end
      ret
    end

    # def visitSystemCCode node
    #   @code < node.code
    # end

    def visitRubyCode node
      @code < node.code
    end

    def visitBody node
      #code << "body( #{node} )"
      if node.wrapperBody
        @parents_stack << node
        @code.wrap
        node.stmts.each do |el|
          if !el.nil?
            @code.newline
            el.accept self
          end
        end
        @code.unwrap
        @parents_stack.pop
      else
        @code < "("
        node.stmts.each do |el|
          el.accept self unless el.nil? # add inline?
        end
        @code < ")"
      end

    end

    def visitAssign node
      # in systemC, we dont initialize arrays.
      #code << "assign( #{node} )"
      @code < node.lhs.to_s + " = "
      node.rhs.accept self unless node.rhs.nil?
      create_register_call node, node.lhs.to_s
    end

    def visitOpAssign node
      @code < node.lhs.lhs.to_s + " #{node.mid}= "
      node.rhs.accept self unless node.rhs.nil?
      create_register_call node, node.lhs.lhs.to_s
    end

    def visitMCall node
      #code << "MCall( #{node} )"

      if node.caller.nil?
        @code < "#{node.method}("
      else
        node.caller.accept self
        @code < ".#{node.method}("
      end
      node.args.each_with_index do |arg,idx|
        if idx !=  0
          @code < ", "
        end
        arg.accept self
      end
      @code < ")"
      if node.method == :[]=
        create_register_call node, node.caller.tname.to_s
      end

    end

    def visitIVar node
      #code << "LVar( #{node} )"
      code < "@#{node.name}"
      create_register_call node, "@#{node.name}"
    end

    def visitLVar node
      #code << "LVar( #{node} )"
      code < "#{node.name}"
      create_register_call node, "#{node.name}"
    end

  end


end
