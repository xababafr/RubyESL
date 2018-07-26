require "./mts_data"
require_relative "./mts_objects"

module NMTS
  class Analyzer
    attr_reader :ast,:sys, :behaviors, :methods_code_h

    def evaluate filename
      rcode=IO.read(filename)
      eval(rcode)
    end

    def open filename
      @behaviors = []
      @filename=filename
      @sys=evaluate(filename)
      @ast=parse()
      build_hash_code_for_classes # @class_code_h[:Sensor]=...

      pp @class_code_h

      #V_print self, "HASH FOR CLASSES"
      #pp @class_code_h
      @class_code_h.keys.each do |klass|
        get_methods klass
      end
      #V_print self, "HASH FOR METHODS"
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

    attr_accessor :methods_ast, :methods_objects

    def initialize filename
      analyzer = Analyzer.new
      analyzer.open filename

      @methods_ast = analyzer.methods_code_h
      @methods_objects = {}
      @methods_ast.keys.each do |key|
        parse_method @methods_ast[ [key[0],key[1]] ], key
      end
    end

    def parse_body body
      V_print self, "PARSE_BODY(#{caller_locations(1,1)[0].label})"
      if body != nil && body.type==:begin
        stmts=body.children.collect{|stmt| to_object(stmt)}
      else
        stmts=[]
        stmts << to_object(body)
      end
      Body.new(stmts)
    end

    def parse_method sexp, key
      name,args,body=*sexp.children[0..2]
      args=args.children.collect{|e| e.children.first}
      body=parse_body(body)
      met = Method.new(name,args,body)
      @methods_objects[key] = met
    end

    def to_object sexp
      return sexp unless sexp.is_a? Parser::AST::Node
      case sexp.type
      when :begin
        return parse_body(sexp)
      when :lvasgn
        return parse_assign(sexp,:local)
      when :ivasgn
        return parse_assign(sexp,:instance)
      when :op_asgn
        return parse_op_assign(sexp)
      when :if
        return parse_if(sexp)
      when :while
        return parse_while(sexp)
      when :for
        return parse_for(sexp)
      when :case
        return parse_case(sexp)
      when :and
        return parse_and(sexp)
      when :or
        return parse_or(sexp)
      when :when
        return parse_when(sexp)
      when :true
        return parse_true(sexp)
      when :false
        return parse_false(sexp)
      when :send
        return parse_send(sexp)
      when :block
        return parse_block(sexp)
      when :args
        return parse_args(sexp)
      # seems like ivar and lvar are the same for us?
    when :ivar
        return parse_lvar(sexp)
      when :lvar
        return parse_lvar(sexp)
      when :int
        return parse_int(sexp)
      when :float
        return parse_float(sexp)
      when :str
        return parse_str(sexp)
      when :return
        return parse_return(sexp)
      when :super
        return parse_super(sexp)
      when :irange
        return parse_irange(sexp)
      when :erange
        return parse_erange(sexp)
      when :array
        return parse_array(sexp)
      when :hash
        return parse_hash(sexp)
      when :regexp
        return parse_regexp(sexp)
      when :const
        return parse_const(sexp)
      when :sym
        return parse_sym(sexp)
      when :dstr
        return parse_dstr(sexp)
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
      If.new(cond,body,else_)
    end

    def parse_and sexp
      V_print self, "ANNND"
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
      While.new(cond,body)
    end

    def parse_for sexp
      idx,range,body=sexp.children.collect{|e| to_object(e)}
      For.new(idx,range,body)
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
      args = sexp.children.collect{|e| to_object(e)}
      Super.new(args)
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
      V_print self, "BLOCKBLOCK"
      pp sexp
      #pp sexp.children
      caller,args,body=sexp.children.collect{|e| to_object(e)}
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
      Hsh.new()
    end

    def parse_regexp sexp
      RegExp.new
    end

    def parse_const sexp
      Const.new sexp.children
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
