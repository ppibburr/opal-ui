module UI
  module Drag
    attr_accessor :drag_target;
    
    # set the dragging state and add the `mousedown` event listener
    #
    # @param target [::UI::Widget] the widget to drag
    #
    # @return [::UI::Widget] self
    def init_drag(target=self)
      @dragging = false
      @drag_target = target
      
      on :mousedown do |e|
        drag_start e    
      
        # have the body listen for `mouseup` to stop dragging
        @mouse_up_cb = $document.body.on :mouseup do |e|
          drag_stop
        end       
    
        # have the body listen for `mousemove`
        @mouse_move_cb = $document.body.on :mousemove  do |evt| 
          next unless @dragging
          
          evt = evt || window.event;

          x = evt.client.x.to_i        
          y = evt.client.y.to_i       

          nx = x - @dragging[:diff_x]     
          ny = y - @dragging[:diff_y]

          do_drag(nx,ny); 
        end 
      end
      
      return self
    end

    # Called on `mousedown`
    #
    # @param evt [Browser::DOM::Event] the event
    def drag_start evt 
      evt = evt || window.event;

      x = evt.client.x.to_i 
      y = evt.client.y.to_i  

      top = drag_target.element.style[:top].to_i    
      left = drag_target.element.style[:left].to_i;  
      

      @dragging = {
        :diff_x => x - left, 
        :diff_y => y - top
      }    
    end

    # Stop dragging. release the listeners attached to `$document.body`
    def drag_stop     
      @dragging = false
      $document.body.off @mouse_up_cb
      $document.body.off @mouse_move_cb
    end

    # Move the target
    #
    # @param x [Integer]
    # @param y [Integer]
    def do_drag(x, y)   
      drag_target.element.style.left = "#{x}px";
      drag_target.element.style.top = "#{y}px";
    end
  end
end
