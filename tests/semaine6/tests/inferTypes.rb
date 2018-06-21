require 'yaml'
require 'parser/current'

require_relative "../MTS/mts_simulator"
require_relative "../MTS/mts_actors_model"
require_relative "../MTS/mts_actors_sim"

if $PROGRAM_NAME == __FILE__



  filename, iterations=ARGV[0], ARGV[1]
  raise "need a file !" if filename.nil?
  raise "need a number of iterations !" if iterations.nil?

  ########################################################
  ######## step1 = generate the intermediate file ########
  ########################################################
  code = File.read(filename)
  parsed_code = Parser::CurrentRuby.parse(code)

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

  # find the classes of the code and creates a ClassProcessor for eahc one
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
        if node.type == :lvar || node.type == :lvasgn
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
        if node.type == :lvar || node.type == :lvasgn
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


  code_processor = CodeProcessor.new
  code_processor.process(parsed_code)
  puts "NANANANANAANANAAAAAAAAAAAAAA"
  pp code_processor.classes
  puts "\n\n\n\n\n\n"
  puts "________________________________\n"

  # probiusOP
  probius = AddProbesProcessor.new code_processor.classes
  probius.process(parsed_code)
  puts "________________________________\n"
  puts "________________________________\n"
  puts "________________________________\n"
  pp probius.registerCalls


  #pp probius.createRegister :accu


  file = File.new(filename, "r")
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
  File.open("TEMP#{filename}",'w'){|f| f.puts(output)}


  ########################################################
  ### step2 = generate the types content in a yam file ###
  ########################################################
  simulator=MTS::Simulator.new
  simulator.open("TEMP"+filename)

  #$inouts = simulator.system.inouts
  #$connexions = simulator.system.connexions

  simulator.simulate simulator.system, iterations.to_i

  variables = {}

  simulator.system.ordered_actors.each do |actor|
    variables[actor.name.to_sym] = actor.vars
  end

  TYPESDATA = {
    :INOUTS => simulator.system.inouts,
    :VARIABLES => variables
  }

  File.open(filename.split('.')[0]+'.yml','w'){|f| f.puts(YAML.dump(TYPESDATA))}
  File.delete('TEMP'+filename)


end
