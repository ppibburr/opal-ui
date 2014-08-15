module UI
  # Emulate to an extent the concept of a `root window` in X11
  class Screen
    CSS("
      .screen {
        background-image: -webkit-gradient(
          linear,
          left top,
          left bottom,
          color-stop(0, #CD5AB7),
          color-stop(1, #75C8F5)
        );
        background-image: -o-linear-gradient(bottom, #CD5AB7 0%, #75C8F5 100%);
        background-image: -moz-linear-gradient(bottom, #CD5AB7 0%, #75C8F5 100%);
        background-image: -webkit-linear-gradient(bottom, #CD5AB7 0%, #75C8F5 100%);
        background-image: -ms-linear-gradient(bottom, #CD5AB7 0%, #75C8F5 100%);
        background-image: linear-gradient(to bottom, #CD5AB7 0%, #75C8F5 100%);
      }
    ").append_to $document.head
    attr_reader :element
    
    # @param target [Browser::DOM::Element] the element to wrap
    def initialize target = $document.body, *opts
      if target == $document.body
        w = ::UI::Widget.new
        w.append_to $document.body
        
        [:height, :'min-height', :'max-height'].each do |prop|
          w.element.style[prop] = "100vh"
          $document.body.style[prop] = "100vh"
        end      
      else
        w = ::UI::Widget.new nil, target, true
      end
      
      w.element.add_class "root"
      w.element.add_class "screen"      
      
      @element = w.element
      
      if opts[0].is_a?(Hash)
        opts[0].each_pair do |k,v|
          send(:"#{k}=", v) if respond_to?(:"#{k}=")
        end
      end
    end
    
    # @param target [Browser::DOM::Element|String] the element to wrap, or the first match to selector string   
    # 
    # @return [::UI::Screen] the newly created instance
    def self.create(target=$document.body, *opts)
      if target.is_a?(String)
        target = $document.css(target)[0]
        raise "No element matches `#{target}`" unless target
      end
      
      new(target, *opts)
    end
    
    # Sets the mininum height
    # 
    # @param v [Integer|String] value
    # 
    # @return [::UI::Screen] self    
    def min_height= v
      element.style[:'min-height'] = v
    end
    
    # Sets the height    
    # 
    # @param v [Integer|String] value
    # 
    # @return [::UI::Screen] self        
    def height= v
      element.style[:height] = v
    end
    
    # Sets the maximum height    
    # 
    # @param v [Integer|String] value
    # 
    # @return [::UI::Screen] self        
    def max_height= v
      element.style[:'max-height'] = v
    end
    
    # Sets the mininum width    
    # 
    # @param v [Integer|String] value
    # 
    # @return [::UI::Screen] self        
    def min_width= v
      element.style[:'min-width'] = v
    end
    
    # Sets the width    
    # 
    # @param v [Integer|String] value    
    # 
    # @return [::UI::Screen] self    
    def width= v
      element.style[:width] = v
    end
    
    # Sets the maximum width    
    # 
    # @param v [Integer|String] value  
    # 
    # @return [::UI::Screen] self      
    def max_width= v
      element.style[:'max-width'] = v
    end  
    
    # Sets the background image
    #
    # @param img [String] the URL|css-gradient
    # 
    # @return [::UI::Screen] self
    def bg_image= img
      element.style[:"background-image"]=img
      
      return self
    end  
    
    # Focuses (raises) the ::UI::Window +window+
    #
    # @param window [::UI::Window] the window to activate
    #
    # @return [::UI::Screen] self
    def activate(window)
      element.css(".window").each do |w|
        if window.element == w
          w.add_class "window-active"
        else
          w.remove_class "window-active"
        end
      end
      
      return self
    end
    
    def apply *o
      raise "Argument must be `Hash`" unless (opts = o[0]).is_a?(Hash)
      
      PBR.apply_hash(opts, self)
    end
    
    # Builds an application using PBR::UI::App (Opal Backend)
    #
    # @param o [Hash] of options, this method only takes +class+, the rest is passed to the PBR::UI::App
    # @option class [Class] the PBR::UI::App Backend
    #
    # @return [PBR::UI::App]
    def app *o, &b
      if !o.empty?
        raise "Argument must be `Hash`" unless o[0].is_a?(Hash)
      else
        o[0] = {}
      end
      
      o[0][:screen] = self
      o[0][:class] ||= PBR::UI::Opal::App
    
    
      o[0][:class].run(o[0]) do |app|
        app_singleton = class << app; self; end
       
        app_singleton.define_method :screen do
          self
        end
      
        app.build &b
      end
    end
  end
end
