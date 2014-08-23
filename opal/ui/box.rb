module PBR
  module OpalUI
    # Box layout. Gtk+ style and flexbox. Laysout children along its major axis
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

      def add w,&b
        super
        pad_child c=children.last, c.element.style[:"padding-#{self.class.get_padding_type[0]}"].to_i-spacing() 
        return self       
      end
      
      # Adds a child with specified flex and padding
      #
      # @example
      #   box = HBox.new
      #   
      #   # the left child grows to one half the right childs width
      #   box.pack_flex child, 1, 5
      #   box.pack_flex child, 2, 5
      #
      #      
      # @param w [Widget] child to add
      # @param amt [Integer] amount of flex
      # @param pad [Integer] amount of padding in addition to `#get_spacing`
      #
      # @return [Box] self
      def pack_flex w, amt=1, pad=0,&b
        add w, &b
        
        w.element.style.flex = "#{amt} 1 auto"
        
        pad_child w, pad
        
        return self
      end

      # Adds a child with specified rules for sizing
      #
      # @example
      #   # Child `left` exands and fills one half of the width
      #   # Child `right` is centered in one half of the width
      #   pack_start left, true, true, 0
      #   pack_start right, true, false, 0
      #
      # @param w [Widget] child to add
      # @param expand [Boolean] true to take up freespace
      # @param fill [Boolean] true to fill the freespace. Only valid if +expand+ is true
      # @param pad [Integer] amount of padding in addition to `#get_spacing`
      #
      # @return [Box] self
      def pack_start w, expand=false, fill=false, pad=0, &b      
        if expand and !fill
          pad = $document.create_element("DIV")
          pad.add_class "pbr-opalui-box-padding"
          pad.append_to element
          
          add w, &b
          
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
      
      # @!method spacing(*val)
      # Set or Retrieve the padding amount between children.
      # @param val [Integer] pass to set the padding, omit to retrieve the padding
      # @return [Widget|Integer]
      
      # @!method spacing=(val)
      # Sets the padding amount between children.  If the child is the first and/or last child the padding is also applied between the child and the edge of the Box
      # @param val [Integer] the amount of padding
      # @return [Integer] +val+
      
      # @!method get_spacing()
      # Gets the padding amount between children.
      # @return [Integer]
      
      # @!method set_spacing(val)
      # Sets the padding amount between children.  If the child is the first and/or last child the padding is also applied between the child and the edge of the Box
      # @param val [Integer] the amount of padding
      # @return [void]  
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

    # A Box that laysout children along the Vertical axis
    class VBox < Container
      include Box
      
      set_padding_type PADDING_VERTICAL
      
      style do
        flex flow: [:column, :nowrap]
      end
    end

    # A Box that laysout children along the Horizontal axis
    class HBox < Container
      include Box
      
      set_padding_type PADDING_HORIZONTAL
      
      style do
        flex flow: [:row, :nowrap]
      end
    end
  end
end
