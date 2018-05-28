require 'parser'
require 'parser/current'
require_relative "evaluate"
require_relative "mts_bhv_model"
require_relative "visitor"

module MTS
  # the node that can be visited
  class HashMethod
    include Visitable

    attr_reader :hash

    def initialize hashMethod
      @hash = hashMethod
    end
  end

  class Analyzer
    include Visitable # it is now visitable

    attr_reader :ast,:sys, :behaviors

    def open filename, methods
      @behaviors = []
      puts "=> open system file #{filename}"
      @filename=filename
      @sys=evaluate(filename)
      @ast=parse()
      build_hash_code_for_classes # @class_code_h[:Sensor]=...
      methods.each do |el|
        #puts el
        parse_method(el[:class],el[:method])
        #parse_method(:Sensor,:behavior)
      end
    end

    # you are supposed to call this AFTER calling open(), so the variable @behaviors exists
    def accept visitor
      @behaviors.each do |hashMethod|
        hashMethod.accept visitor
      end
    end

    def get_actor_classes
      puts "==> collecting classes"
      classes_code={}
      recursive_code_for_class
    end

    def parse
      Parser::CurrentRuby.parse(File.open(@filename, "r").read)
    end

    def build_hash_code_for_classes
      puts "=> building hash for classe codes"
      rec_build_hash_code_for_classes @ast
    end

    def rec_build_hash_code_for_classes ast
      ast.children.each do |child|
        if child.class.to_s == "Parser::AST::Node"
          if child.type.to_s == "class"
            class_name=child.children[0].children[1]
            puts " - got a class named #{class_name}"
            @class_code_h||={}
            @class_code_h[class_name]=child
          else
            rec_build_hash_code_for_classes child
          end
        end
      end
    end

    def get_method klass,method
      print "searching method #{klass}.#{method} : "
      ret=rec_get_method(@class_code_h[klass],method)
      puts "found!" if ret
      ret
    end

    def rec_get_method node,method
      node.children.each do |child|
        next unless child.class.to_s == "Parser::AST::Node"
        if (child.type==:def && child.children[0]==method)
          return child
        else
          ret=rec_get_method(child, method)
          return ret unless ret.nil?
        end
      end
      nil
    end

    def parse_method klass,method
      puts "parsing method #{method}".center(80,'=')
      sexp=get_method(klass,method)
      name,args,body=*sexp.children[0..2]
      args=args.children.collect{|e| e.children.first}
      pp body
      body=parse_body(body)
      met = Method.new(name,args,body)
      #pp met
      @behaviors << (HashMethod.new ({
          :method => met,
          :mclass => klass,
          :mname => method
      }))
    end

    def parse_body body
      puts "parsing body".center(80,'=')
      if body.type==:begin
        stmts=body.children.collect{|stmt| to_object(stmt)}
      else
        stmts=[]
        stmts << to_object(body)
      end
      puts "="*80
      Body.new(stmts)
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
      when :if
        return parse_if(sexp)
      when :while
        return parse_while(sexp)
      when :for
        return parse_for(sexp)
      when :case
        return parse_case(sexp)
      when :when
        return parse_when(sexp)
      when :send
        return parse_send(sexp)
      when :lvar
        return parse_lvar(sexp)
      when :int
        return parse_int(sexp)
      when :str
        return parse_str(sexp)
      when :irange
        return parse_irange(sexp)
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
        raise "NIY : #{sexp.type} => #{sexp}"
      end
    end

    def parse_int sexp
      IntLit.new(sexp.children.first)
    end

    def parse_str sexp
      StrLit.new(sexp.children.first)
    end

    def parse_irange sexp
      lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
      IRange.new(lhs,rhs)
    end

    def parse_lvar sexp
      LVar.new(sexp.children.first)
    end

    def parse_assign sexp,locality
      puts "parse_assign"
      lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
      Assign.new(lhs,rhs)
    end

    def parse_if sexp
      puts "parse_if"
      cond,body,else_=sexp.children.collect{|e| to_object(e)}
      If.new(cond,body,else_)
    end

    def parse_while sexp
      puts "parse_while"
      cond,body=sexp.children.collect{|e| to_object(e)}
      While.new(cond,body)
    end

    def parse_for sexp
      puts "parse_for"
      idx,range,body=sexp.children.collect{|e| to_object(e)}
      For.new(idx,range,body)
    end

    def parse_case sexp
      puts "parse_case"
      pp sexp
      elems=sexp.children.collect{|e| to_object(e)}
      expr=elems.shift
      whens=elems.select{|e| e.is_a? MTS::When}
      else_=elems.pop
      Case.new(expr,whens,else_)
    end

    def parse_when sexp
      puts "parse_when"
      expr,body=sexp.children.collect{|e| to_object(e)}
      When.new(expr,body)
    end

    def parse_send sexp
      caller,method,args=*sexp.children.collect{|e| to_object(e)}
      MCall.new(caller,method,args)
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
      Const.new
    end

    def parse_sym sexp
      Sym.new sexp.children.first
    end

    def parse_dstr sexp
      elements=*sexp.children.collect{|e| to_object(e)}
      Dstr.new(elements)
    end
  end #class
end
