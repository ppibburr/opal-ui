module PBR
  module OpalUI
    module Styler
      def builder
        unless @builder
          @builder = Paggio::CSS.new do end
          def @builder.rule *o,&b
            super
          end
        end
        
        @builder
      end
    
      def style what, &b
        builder.rule("."+what.class_name) do |r|
          def r.active *a,&k
            return rule(*["&:active"].push(*a),&k)
          end
         
          def r.hover *a,&k
            return rule(*["&:hover"].push(*a),&k)
          end
          
          def r.focus *a,&k
            return rule(*["&:focus"].push(*a),&k)
          end                    
          
          def r.rule *o,&k
            if o.length == 1 and o[0].is_a?(PBR::OpalUI::Widget::Interface)
              o[0] = "."+o[0].class_name
              return super
              
            else
              return super
            end          
          end
          
          def r.method_missing m,*o,&b
            if m.end_with?(?!)
              m = m[0 .. -2]

              if o[0].is_a?(Array)
                o[0] << "!important"
              else
                o << "!important"
              end

              return __send__(m,*o,&b)
            end
            
            super
          end
          
          r.instance_exec &b
        end
      end
      
      def apply
        CSS(Paggio::Formatter.new.format(builder).to_s).append_to $document.head
      end    
    end
  end
end
