require_relative "./mts_objects"

module NMTS
  class Analyzer
    attr_reader :ast,:sys, :behaviors, :methods_code_h, :sys_ast

    def evaluate filename
      rcode=IO.read(filename)
      eval(rcode)
    end

    def open filename
      @behaviors = []
      @filename=filename
      @sys=evaluate(filename)
      @ast=parse()

      puts "PARSED : "
      pp @ast

      build_hash_code_for_classes # @class_code_h[:Sensor]=...

      pp @class_code_h[:Sourcer]
      File.open('./ast.txt', 'w') { |file| file.write("NANI") }

      print "sourcyy"
      pp @class_code_h

      #puts "HASH FOR CLASSES"
      #pp @class_code_h
      @class_code_h.keys.each do |klass|
        get_methods klass
      end
      #puts "HASH FOR METHODS"
      #pp @methods_code_h
    end

    def get_actor_classes
      classes_code={}
      recursive_code_for_class
    end

    def parse
      Parser::CurrentRuby.parse(File.open(@filename, "r").read)
    end

    def build_hash_code_for_classes
      rec_build_hash_code_for_classes @ast
    end

    def rec_build_hash_code_for_classes ast
      ast.children.each do |child|
        if child.class.to_s == "Parser::AST::Node"
          if child.type.to_s == "class"
            class_name=child.children[0].children[1]
            @class_code_h||={}
            @class_code_h[class_name]=child
          elsif (child.type.to_s == "lvasgn" && child.children.first == :sys)
            @sys_ast = child
          else
            rec_build_hash_code_for_classes child
          end
        end
      end
    end

    def get_methods klass
      @methods_code_h ||= {}
      rec_get_methods @class_code_h[klass], klass
    end

    def rec_get_methods node, klass
      node.children.each do |child|
        next unless child.class.to_s == "Parser::AST::Node"
        if (child.type==:def)
          @methods_code_h[ [klass, child.children[0]] ] = child
        else
          rec_get_methods child, klass unless (child == nil)
        end
      end
    end

  end


  class Objectifier

    # the onky goal of this class is to give access to these two accessors

    attr_accessor :methods_ast, :methods_objects, :convert, :sys_ast

    def initialize filename, convert = false
      analyzer = Analyzer.new
      analyzer.open filename
      @convert = convert
      @methods_ast = analyzer.methods_code_h
      @methods_objects = {}
      @methods_ast.keys.each do |key|
        parse_method(@methods_ast[ [key[0],key[1]] ], key)
      end
      @sys_ast = parse_assign(analyzer.sys_ast, :local)
    end

    def parse_body body, bodyWrapper = false
      puts "PARSE_BODY(#{caller_locations(1,1)[0].label})"
      if body != nil && body.type==:begin
        stmts=body.children.collect{|stmt| to_object(stmt)}
      else
        stmts=[]
        stmts << to_object(body)
      end
      Body.new(stmts, bodyWrapper)
    end

    def parse_method sexp, key
      name,args,body=*sexp.children[0..2]
      args=args.children.collect{|e| e}
      body=parse_body(body, true)
      met = Method.new(name,(Args.new args),body)
      @methods_objects[key] = met
    end

    def convert obj
      if @convert
        Convert::node( obj )
      else
        obj
      end
    end

    def to_object sexp
      return sexp unless sexp.is_a? Parser::AST::Node
      case sexp.type
      when :begin
        convert( parse_body(sexp) )
      when :lvasgn
        convert( parse_assign(sexp,:local) )
      when :ivasgn
        convert( parse_assign(sexp,:instance) )
      when :op_asgn
        convert( parse_op_assign(sexp) )
      when :if
        convert( parse_if(sexp) )
      when :while
        convert( parse_while(sexp) )
      when :for
        convert( parse_for(sexp) )
      when :case
        convert( parse_case(sexp) )
      when :and
        convert( parse_and(sexp) )
      when :or
        convert( parse_or(sexp) )
      when :when
        convert( parse_when(sexp) )
      when :true
        convert( parse_true(sexp) )
      when :false
        convert( parse_false(sexp) )
      when :send
        convert( parse_send(sexp) )
      when :block
        convert( parse_block(sexp) )
      when :args
        convert( parse_args(sexp) )
      # seems like ivar and lvar are the same for us?
      when :ivar
        convert( parse_ivar(sexp) )
      when :lvar
        convert( parse_lvar(sexp) )
      when :int
        convert( parse_int(sexp) )
      when :float
        convert( parse_float(sexp) )
      when :str
        convert( parse_str(sexp) )
      when :return
        convert( parse_return(sexp) )
      when :super
        convert( parse_super(sexp) )
      when :irange
        convert( parse_irange(sexp) )
      when :erange
        convert( parse_erange(sexp) )
      when :array
        convert( parse_array(sexp) )
      when :hash
        convert( parse_hash(sexp) )
      when :pair
        convert( parse_hash(sexp) )
      when :regexp
        convert( parse_regexp(sexp) )
      when :const
        convert( parse_const(sexp) )
      when :sym
        convert( parse_sym(sexp) )
      when :dstr
        convert( parse_dstr(sexp) )
      else
        #raise "NIY : #{sexp.type} => #{sexp}"
        Unknown.new sexp
      end
    end

    def parse_int sexp
      IntLit.new(sexp.children.first)
    end

    def parse_float sexp
      FloatLit.new(sexp.children.first)
    end

    def parse_str sexp
      StrLit.new(sexp.children.first)
    end

    def parse_return sexp
      Return.new(to_object sexp.children.first)
    end

    def parse_irange sexp
      lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
      IRange.new(lhs,rhs)
    end

    def parse_erange sexp
      lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
      ERange.new(lhs,rhs)
    end

    def parse_ivar sexp
      IVar.new(sexp.children.first)
    end

    def parse_lvar sexp
      LVar.new(sexp.children.first)
    end

    def parse_true sexp
      TrueLit.new()
    end

    def parse_false sexp
      FalseLit.new()
    end

    def parse_op_assign sexp
      lhs,mid,rhs=*sexp.children[0..2].collect{|stmt| to_object(stmt)}
      OpAssign.new(lhs,mid,rhs)
    end

    def parse_assign sexp,locality
      lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
      Assign.new(lhs,rhs)
    end

    def parse_if sexp
      cond,body,else_=sexp.children.collect{|e| to_object(e)}
      # happens if only one line of code is in the body of the if
      pp body
      if !body.is_a?(Body)
        b = body.dup
        body = Body.new([b])
      end
      if !else_.is_a?(Body)
        e = else_.dup
        else_ = Body.new([e])
      end
      body.wrapperBody = true
      else_.wrapperBody = true
      If.new(cond,body,else_)
    end

    def parse_and sexp
      pp sexp.children
      lhs,rhs = sexp.children.collect{|e| to_object(e)}
      And.new(lhs,rhs)
    end

    def parse_or sexp
      lhs,rhs = sexp.children.collect{|e| to_object(e)}
      Or.new(lhs,rhs)
    end

    def parse_while sexp
      cond,body=sexp.children.collect{|e| to_object(e)}
      # happens if only one line of code is in the body of the while
      pp body
      if !body.is_a?(Body)
        b = body.dup
        body = Body.new([b])
      end
      body.wrapperBody = true
      While.new(cond,body)
    end

    def parse_for sexp
      idx,range,body=sexp.children.collect{|e| to_object(e)}
      # happens if only one line of code is in the body of the for
      pp body
      if !body.is_a?(Body)
        b = body.dup
        body = Body.new([b])
      end
      body.wrapperBody = true
      range.idx = idx.lhs unless (idx.nil? || idx.lhs.nil?)
      puts "FORRR\n\n"
      For.new(range.idx,range,body)
    end

    def parse_case sexp
      pp sexp
      elems=sexp.children.collect{|e| to_object(e)}
      expr=elems.shift
      whens=elems.select{|e| e.is_a? MTS::When}
      else_=elems.pop
      Case.new(expr,whens,else_)
    end

    def parse_super sexp
      args = sexp.children
      Super.new( (Args.new args) )
    end

    def parse_when sexp
      expr,body=sexp.children.collect{|e| to_object(e)}
      When.new(expr,body)
    end

    def parse_send sexp
      caller,method,args=to_object(sexp.children[0]), to_object(sexp.children[1]), []
      (sexp.children.size-2).times do |i|
        args << to_object(sexp.children[i+2])
      end
      MCall.new(caller,method,args)
    end

    def parse_block sexp
      #caller,method,args=*sexp.children.collect{|e| to_object(e)}
      pp sexp
      #pp sexp.children
      caller,args,body=sexp.children.collect{|e| to_object(e)}
      if !body.is_a?(Body)
        b = body.dup
        body = Body.new([b])
      end
      body.wrapperBody = true
      Block.new(caller,args,body)
    end

    def parse_args sexp
      Args.new(sexp.children)
    end

    def parse_array sexp
      elements=*sexp.children.collect{|e| to_object(e)}
      Ary.new(elements)
    end

    def parse_hash sexp
      # we pass the pairs
      elements=*sexp.children.collect{|e| to_object(e)}
      Hsh.new(elements)
    end

    def parse_pair sexp
      # we pass the pairs
      elements=*sexp.children.collect{|e| to_object(e)}
      Pair.new(elements[0])
    end

    def parse_regexp sexp
      RegExp.new
    end

    def parse_const sexp
      children = []
      sexp.children.each do |child|
        if child.class.to_s == "Parser::AST::Node"
          children << to_object(child)
        else
          children << child
        end
      end
      Const.new children
    end

    def parse_sym sexp
      Sym.new sexp.children.first
    end

    def parse_dstr sexp
      elements=*sexp.children.collect{|e| to_object(e)}
      Dstr.new(elements)
    end

  end
end
