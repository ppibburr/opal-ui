module PBR
  module OpalUI
    class Container < Widget
      style do
        display :flex
        flex flow: [:column, :nowrap]
        
        rule ".pbr-opalui-container-child" do
          flex [1,1,:auto]
        end        
      end

      def container_element
        @container_element || element
      end

      def add w
        w.element.append_to container_element
        
        bool = false
        
        self.class.ancestors.reverse.each do |q|
          bool = true if q == Container      
          
          next unless bool
          
          w.element.add_class q.class_name+"-child"
        end

        return self
      end
      
      def children &b
        a = []
        
        container_element.css(".pbr-opalui-container-child").each do |c|
          w = Widget.wrap c
          yield w if b
          a << w
        end
        
        a
      end
      
      def iter &b
        children &b
        
        return self
      end
    end

    class Bin < Container
      def add w
        raise "`Bin##{self}` Already has child" unless children.length < 1
        
        super
      end
    end

    class Frame < Bin
      css "
       .pbr-opalui-frame-top-left {
         flex:1 1 auto;
         display:inline-block;
         position:relative;
         top:-4px;
         left:-1px;         
        }
        
       .pbr-opalui-frame-top-right {
         flex:1 1 auto;
         display:inline-block;
         position:relative;
         top:-4px;
         left:1px;           
        }        
        
        .pbr-opalui-frame-label {
          position:relative;    
          top:calc(-0.75em);
          display:inline-block;
          margin-left:3px;
          margin-right:3px;
        }
        
        .pbr-opalui-frame-inner {
          display:flex;
          flex:1 1 auto;
          position:relative;
          top:-0.5em;
          padding:2px;
        }        
        
        .pbr-opalui-frame {            
            display:flex;
            flex-flow:column nowrap;
            padding-top:0.25em;
            margin-top:0.5em;
            overflow:initial;
        }
        
        .pbr-opalui-frame-top {
            display:flex;
            flex-flow:row nowrap;
        }
"      
            
      def init
        super
        
        element.inner_html = "
          <div class=pbr-opalui-frame-top>
            <span class=pbr-opalui-frame-top-left></span>
            <div class=pbr-opalui-frame-label></div>
            <span class=pbr-opalui-frame-top-right></span>
          </div>
          <div class=pbr-opalui-frame-inner></div>
        "
      end
      
      def container_element
        element.css(".pbr-opalui-frame-inner")[0]
      end
      
      get_set_chain :label do
        [element.css(".pbr-opalui-frame-label")[0], :inner_text, :"inner_text="]
      end
    end

    class Window < Bin
      style do
        position :absolute
        resize :both
      end
      
      def initialize(parent = nil,*opts)
        super(*opts)
        if parent and parent.is_a? Browser::DOM::Element
          element.append_to parent
        elsif !parent
          element.append_to $document.body
        end
      end
    end

    module Box
      extend Widget::Interface

      style do
        display :flex;
    
        rule ".pbr-opalui-box-child" do
          flex [0, 1, :auto]
        end
        
        rule ".pbr-opalui-box-child-fill" do
          flex [1, 1, :auto, "!important"]
        end
        
        rule ".pbr-opalui-box-padding" do
          flex [0.5, 1, :auto]
        end
      end

      def add w
        super
        pad_child c=children.last, c.element.style[:"padding-#{self.class.get_padding_type[0]}"].to_i-spacing() 
        self       
      end
      
      def pack_flex w, amt=1, pad=0
        add w
        
        w.element.style.flex = "#{amt} 1 auto"
        
        pad_child w, pad
        
        self
      end

      def pack_start w, expand=false, fill=false, pad=0      
        if expand and !fill
          pad = $document.create_element("DIV")
          pad.add_class "pbr-opalui-box-padding"
          pad.append_to element
          
          add w
          
          pad = $document.create_element("DIV")
          pad.add_class "pbr-opalui-box-padding"
          pad.append_to element
        
        elsif !expand
          add w
        
        elsif expand and fill
          w.element.add_class "pbr-opalui-box-child-fill"        
          add w    
        end
        
        pad_child(w,pad)
        
        return self
      end
      
      get_set_chain :spacing do
        proc do |t,k,val,*o|
          case t
          when :get
            @spacing ||= 0
          else
            old = get_spacing
            @spacing = val
            
            t=self.class.get_padding_type
            
            iter do |c|
              amt = (c.element.style[:"margin-#{t[0]}"].to_i - old) + val
              
              pad_child c,amt
            end            
            
            next val
          end
        end
      end
 
      private
      def pad_child c,amt
        amt = spacing()+amt
        t=self.class.get_padding_type
        lc = children.last.element
        c.element.style[:"margin-#{t[0]}"] = amt.px
        c.element.style[:"margin-#{t[1]}"] = c.element == lc ? amt.px : 0.px      
      end
 
      PADDING_HORIZONTAL = [:left, :right]
      PADDING_VERTICAL   = [:top, :bototm]
      
      def self.included q
        def q.get_padding_type
          @padding_type ||= PADDING_VERTICAL
        end
        
         def q.set_padding_type type
          @padding_type = type
        end       
      end
    end

    class VBox < Container
      include Box
      
      set_padding_type PADDING_VERTICAL
      
      style do
        flex flow: [:column, :nowrap]
      end
    end

    class HBox < Container
      include Box
      
      set_padding_type PADDING_HORIZONTAL
      
      style do
        flex flow: [:row, :nowrap]
      end
    end
  end
end
