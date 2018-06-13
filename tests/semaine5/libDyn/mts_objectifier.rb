require_relative "./mts_objects"

module MTS
  class Objectifier

      attr_accessor :methods_ast, :methods_objects

      def initialize methods_ast_hash
        @methods_ast = methods_ast_hash
        @methods_objects = {}
        @methods_ast.keys.each do |key|
          parse_method @methods_ast[ [key[0],key[1]] ], key
        end
      end

      def parse_body body
        if body.type==:begin
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
        when :float
          return parse_float(sexp)
        when :str
          return parse_str(sexp)
        when :return
          return parse_return(sexp)
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

      def parse_lvar sexp
        LVar.new(sexp.children.first)
      end

      def parse_assign sexp,locality
        lhs,rhs=*sexp.children[0..1].collect{|stmt| to_object(stmt)}
        Assign.new(lhs,rhs)
      end

      def parse_if sexp
        cond,body,else_=sexp.children.collect{|e| to_object(e)}
        If.new(cond,body,else_)
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

      def parse_when sexp
        expr,body=sexp.children.collect{|e| to_object(e)}
        When.new(expr,body)
      end

      def parse_send sexp
        #caller,method,args=*sexp.children.collect{|e| to_object(e)}
        caller,method,args=to_object(sexp.children[0]), to_object(sexp.children[1]), []
        (sexp.children.size-2).times do |i|
          args << to_object(sexp.children[i+2])
        end
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

  end
end
