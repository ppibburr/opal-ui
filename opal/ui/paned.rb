class PBR::OpalUI
  # Container that allows its children to grow/shrink in contrast to each other via a drag handle
  class Paned < Container
    style do
      rule ".pbr-opalui-paned-first-child" do
        order 0
        flex [1,1,:auto]
      end
      
      rule ".pbr-opalui-paned-second-child" do
        order 2
        flex [1,1,:auto]
      end      
    end
    
    # @api private
    # Grab to resize children
    class Handle < Widget
      include Drag
    
      style do
        order 1
        flex [0, 1, 8.px]
        min height:8.px
        style "-webkit-user-select", :none
        cursor "col-resize"
        background "-webkit-linear-gradient(left, rgba(0,0,0,0.65) 0%,rgba(0,0,0,0) 100%)"    
      end
      
      def drag_start *o
        super
        
        @dragging[:height_a] = drag_target.children[0].element.style!.height.to_i
        @dragging[:height_b] = drag_target.children[1].element.style!.height.to_i 
        @dragging[:width_a] = drag_target.children[0].element.style!.width.to_i
        @dragging[:width_b] = drag_target.children[1].element.style!.width.to_i                
      end
      
      def do_drag x,y
        amt = drag_target.class::AXIS == :y ? y : x
        dir = drag_target.class::AXIS == :y ? 'height' : 'width'

        a = (@dragging["#{dir}_a"] + amt)
        b = (@dragging["#{dir}_b"] - amt)   
        
        drag_target.children[0].element.style["flex-basis"] = 0.px
        drag_target.children[1].element.style["flex-basis"] = 0.px
        
        w = b+a
        bb = b/w.to_f
        aa = a/w.to_f
        
        drag_target.children[0].element.style[:'flex-grow'] = aa
        drag_target.children[1].element.style[:'flex-grow'] = bb     
      end
    end
    
    def init *o
      super
      
      h = Handle.new()
      h.element.append_to element
      
      h.init_drag self
    end
  
    def add1 w,&b
      w.element.add_class "pbr-opalui-paned-first-child"
          
      add(w,&b)  
    end
    
    def add2 w,&b
      w.element.add_class "pbr-opalui-paned-second-child"
    
      add(w,&b)
    end
    
    private :add
  end
  
  # A Paned Container displaying it's children horizontaly
  class HPaned < Paned
    style do
      flex flow: [:row, :nowrap]
    end
    
    AXIS = :x
  end
  
  # A Paned Container displaying it's children verticaly
  class VPaned < Paned
    AXIS = :y
  end  
end
