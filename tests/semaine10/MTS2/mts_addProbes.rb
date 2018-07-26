# the AddProbes class takes Ruby code as an input, and generates a new ruby cde with probes
# only detects local vars, not instance vars (see object.instance_variables() for that)

require 'parser/current'

module NMTS

  class MyProcessor < AST::Processor
    def handler_missing node
      #puts "you're missing the #{node.type} node"
      node.children.each do |child|
        if child.is_a? AST::Node
          process(child)
        end
      end
    end
  end

  # find the classes of the code and creates a ClassProcessor for each one
  class CodeProcessor < MyProcessor
    attr_reader :classes

    def initialize
      @classes = {}
    end

    def on_class node
      #pp node
      puts "////#{node.children[0].children[1]}/////"
      puts "________________________________"
      classes_processor = ClassesProcessor.new
      classes_processor.process node
      @classes[node.children[0].children[1]] = classes_processor.vars
    end
  end

  # find each variable of the class
  class ClassesProcessor < MyProcessor
    attr_reader :vars

    def on_class(node)
      @currentClass = node.children[0].children[1]
      handler_missing node
    end

    def initialize
      @vars = {}
    end

    def on_def node
      pp node
      @vars[node.children[0]] = []
      @currentMethod = node.children[0]
      handler_missing node
      puts "________________"
    end

    def on_lvasgn node
      puts "FOUND A VAR : #{node.children[0]} ( context : #{@currentClass}.#{@currentMethod}() )"
      @vars[@currentMethod] << node.children[0]
      @vars[@currentMethod].uniq!
    end
  end

  # represents a begin blocks. Is able to tell if it contains a given var
  class BeginBlockProcessor < AST::Processor
    # so we can define SExpressions
    include AST::Sexp

    def initialize node, varsToCheck, registerCalls
      @varsToCheck = varsToCheck
      @registerCalls = registerCalls
      #@varIsHere = var_appears node, varSymbol
      @subBegins = []

      # to call the on_begin() iterations
      # each on_begin will create a new beginBlockProcessor, so the recursive
      # registerCalls are going to be added as well
      process_all(node)

      varsToCheck.each do |varSymbol|
        if var_appears(node, varSymbol)
          puts "last line(#{varSymbol}) : #{node.children[-1].location.expression.last_line}"
          lineNb = node.children[-1].location.expression.last_line
          createRegisterCall(lineNb, varSymbol)
        end
      end
    end

    # creates the line of code : register(:symbol, symbol)
    def createRegisterCall lineNb, symbol
      puts "REGISTERCALL"
      # s(:send, nil, :register,
      #   s(:sym, symbol),
      #   s(:lvar, symbol)
      # )
      @registerCalls[lineNb] ||= []
      @registerCalls[lineNb] << "register(:#{symbol}, #{symbol})\n"
    end

    # takes a node as an input, and returns true if the node contains the var, false otherwise
    def var_appears node, varSymbol
      boolean = false

      if node.is_a? AST::Node
        if node.type == :lvar || node.type == :ivar || node.type == :lvasgn
          boolean = boolean || ( node.children[0] == varSymbol )
        else
          node.children.each do |child|
            if child.is_a? AST::Node
              # recursive call to vars_appears
              boolean = boolean || ( var_appears child, varSymbol )
            end
          end
        end
      end

      boolean
    end

    def on_begin node
      @subBegins << BeginBlockProcessor.new(node, @varsToCheck, @registerCalls)
    end

    def handler_missing node
      #puts "you're missing the #{node.type} node"
      node.children.each do |child|
        if child.is_a? AST::Node
          process(child)
        end
      end
    end
  end

  # add the variable probes/sensors to the ast
  class AddProbesProcessor < AST::Processor
    # so we can define SExpressions
    include AST::Sexp

    attr_reader :registerCalls

    def initialize classesVars
      @classes = classesVars
      @registerCalls = {}
    end

    def on_class(node)
      @currentClass = node.children[0].children[1]
      handler_missing node
    end

    def on_def node
      puts "DEEEEFFFF #{@currentClass}.#{@currentMethod}()"
      @currentMethod = node.children[0]
      pp node.children[2]
      if node.children[2].is_a? AST::Node
        # we iterate on each "block" of the method. If any involves a var,
        # lets add a call to register to the right place
        # the right place is the lowest_level (recursively speaking) :begin block that contains the var
        # well.... kinda...
        if node.children[2].is_a?(AST::Node) && node.children[2].type == :begin
          # we create a beginBlockProcessor that will alter the child's ast
          BeginBlockProcessor.new node.children[2], @classes[@currentClass][@currentMethod], @registerCalls
        else
          node.children[2].children.each do |child|
            if child.is_a?(AST::Node) && child.type == :begin
              # we create a beginBlockProcessor that will alter the child's ast
              BeginBlockProcessor.new child, @classes[@currentClass][@currentMethod], @registerCalls
            end
          end
        end

        puts "REGISTER CALLS ADDED TO #{@currentClass}.#{@currentMethod}() for the variables #{@classes[@currentClass][@currentMethod]}"
        pp node.children[2]
      end

      # node.children.each do |child|
      #   puts "CHILD".center(80,'=')
      #   pp child
      # end
      handler_missing node
    end

    # takes a node as an input, and returns true if the node contains the var, false otherwise
    def var_appears node, varSymbol
      boolean = false

      if node.is_a? AST::Node
        if node.type == :lvar || node.type == :ivar || node.type == :lvasgn
          boolean = boolean || ( node.children[0] == varSymbol )
        else
          node.children.each do |child|
            if child.is_a? AST::Node
              # recursive call to vars_appears
              boolean = boolean || ( var_appears child, varSymbol )
            end
          end
        end
      end

      boolean
    end

    def handler_missing node
      # if node.type == :lvar || node.type == :lvasgn
      #   pp node
      #   pp node.children
      # end
      node.children.each do |child|
        if child.is_a? AST::Node
          process(child)
        end
      end
    end

    # creates the line of code : register(:symbol, symbol)
    def createRegister symbol
      s(:send, nil, :register,
        s(:sym, symbol),
        s(:lvar, symbol)
      )
    end
  end

  class AddProbes
    def initialize filename
      code = File.read(filename)
      @filename = filename
      @parsed_code = Parser::CurrentRuby.parse(code)
    end

    def generate_file
      code_processor = CodeProcessor.new
      code_processor.process(@parsed_code)

      probius = AddProbesProcessor.new code_processor.classes
      probius.process(@parsed_code)

      file = File.new(@filename, "r")
      output, i = "", 0
      while (line = file.gets)
        i += 1
        output += line
        if probius.registerCalls.key?(i)
          probius.registerCalls[i].each do |t|
            output += t
          end
        end
      end
      file.close
      File.open("probes_#{@filename}",'w'){|f| f.puts(output)}
    end
  end

end




if $PROGRAM_NAME == __FILE__
  ruby_code = %q(

require "../MTS2/mts_dsl"

# FIR filter

class Fir < NMTS::Actor
  input  :inp
  output :outp

  def initialize name, ucoef
    @coef = [0,0,0,0,0]
    for i in 0...5
      @coef[i] = ucoef[i]
    end
    super(name)
  end

  def behavior
    puts "\nFIR::BEHAVIOR()\n\n"

    vals = [0,0,0,0,0]
    while(true)
      for i in 0...4
        j = 4-i
        vals[j] = val[j-1]
      end
      vals[0] = receive?(:inp)

      ret = 0
      for i in 0...5
        ret += @coef[i] * vals[i]
      end

      send!(ret, :outp)
      wait()
    end
  end
end


class Sourcer < NMTS::Actor
  output :inp

  def behavior
    puts "\nSOURCER::BEHAVIOR()\n\n"
    tmp = 0
    for i in 0...64
      if (i > 23 && i < 29)
        tmp = 256
      else
        tmp = 0
      end

      send!(tmp, :inp)
      wait()
    end
  end

end

class Sinker <N MTS::Actor
  input  :outp

  def behavior
    puts "\nSINKER::BEHAVIOR()\n\n"
    for i in 0...64
      datain = receive?(:outp)
      wait()

      puts "#{i} --> #{datain}"
    end
    #stop()
    puts "sim stopped??"
  end

end

# |Sourcer| ==inp==> |Fir| ==outp==> |Sinker|

sys=NMTS::System.new("sys") do
    ucoef = [18,77,107,77,18]

    src0 = Sourcer.new("src0")
    snk0 = Sinker.new("snk0")
    fir0 = Fir.new("fir0", ucoef)

    # here lies the order of the actors for now
    # do they really need to have an order? I dont think so
    set_actors([src0, fir0, snk0])

    connect_as(src0.inp => fir0.inp)
    connect_as(fir0.outp => snk0.outp)
end

  )

  File.open("testingCode.rb",'w'){|f| f.puts(ruby_code)}

  add_probes = NMTS::AddProbes.new "testingCode.rb"
  add_probes.generate_file
end
