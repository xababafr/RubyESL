require 'pp'
require 'erb'

module NMTS


  class DotGenerator

    def initialize
      puts "dot generation".center(80,'=')
      @deps=""
      @aspect={}
      @visited=[]
    end

    def generate ast
      puts "==> recursive walk on the AST"
      apply ast
      puts "==> partitions to visually distinguish between terminals and non-terminals"
      h_tokens,h_non_terminals=partition_term_vs_nonterm(@aspect)
      puts "==> preparing dot declarations"
      prng = Random.new(12345)
      @decl_tokens       =h_tokens.collect{|k,v| "#{k} [label=\"#{v}\##{prng.rand(10000000)}\",fontcolor=\"red\",color=\"red\"]"}.join("\n\t")
      @decl_non_terminals=h_non_terminals.collect{|k,v|
        kname=v.class.to_s.split('::').last
        "#{k} [label=\"#{kname}\"]"
      }.join("\n\t")
      dir=__dir__
      puts "==> calling ERB template located at #{dir}"
      renderer = ERB.new(IO.read("#{dir}/dot.erb"))
      filename="#{dir}/ast.dot"
      File.open(filename,'w') {|f| f.puts renderer.result(binding)}
      puts "==> dot file generated : #{filename}"
      puts "    to run : dot -Tpng #{filename} -o result.png ; eog result.png"
    end

    def apply ast
      @visited << ast
      ast.instance_variables.each do |v|
        var=ast.instance_variable_get(v)
        unless @visited.include? var
          if var.class== Array
            tab=var
            tab.each_with_index do |e,idx|
              label=v.to_s+"["+idx.to_s+"]"
              emit(id(ast),id(e),label)
              apply(e)
            end
          else
            if var
              emit(id(ast),id(var),v.to_s)
              if var.class < Ast
                apply(var)
              end
            end
          end
        end
      end
    end

    def id obj
      id=obj.class.to_s+"_"+obj.object_id.to_s
      id.gsub!("::",'__')
      id.gsub!("%",'?')
      @aspect[id]=obj
      return id
    end

    def emit(source,sink,label)
      @deps += "#{source} -> #{sink} [label=\"#{label[1..-1]}\"]\n"
    end

    # def partition_term_vs_nonterm h
    #   h.partition { |k, v| v.class==Token }.map{|a| Hash[a] }
    # end

    def partition_term_vs_nonterm h
      h.partition { |k, v| !(v.class < Ast) }.map{|a| Hash[a] }
    end

  end


end
