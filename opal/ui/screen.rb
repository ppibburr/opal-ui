module PBR::OpalUI
  # Emulate to an extent the concept of a `root window` in X11
  class Screen
    extend PBR::GetSetChain
  
    CSS("
      .pbr-opalui-screen {
        background-image: -webkit-gradient(
          linear,
          left top,
          left bottom,
          color-stop(0, #CD5AB7),
          color-stop(1, #75C8F5)
        );
        overflow: hidden;
        display: inline;
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
        [:height, :'min-height', :'max-height', :width, :"min-width", :"max-width"].each do |prop|
          target.style[prop] = "100vh"
        end      
      end
      
      target.add_class "pbr-opalui-screen"
      
      @element = target
      
      if opts[0].is_a?(Hash)
        opts[0].each_pair do |k,v|
          send(:"#{k}=", v) if respond_to?(:"#{k}=")
        end
      end
    end
    
    # A Screen that has `document.body` as its element.  
    # @param opts [Hash] passed to `Screen#apply(opts={})`
    # @return [Screen]
    def self.default! opts={}
      e = $document.body
      screen = e.class_names.index("pbr-opalui-screen") ? wrap(e) : create()
      screen.apply(opts)
      
      return screen
    end
    
    # @param target [Browser::DOM::Element|String] the element to wrap, or the first match to selector string   
    # 
    # @return [::PBR::OpalUI::Screen] the newly created instance
    def self.create(target=$document.body, *opts)
      if target.is_a?(String)
        target = $document.css(target)[0]
        raise "No element matches `#{target}`" unless target
      end
      
      new(target, *opts)
    end
    
    # Clears the background before applying values
    # @param o [Array|String|Hash] passed to `Screen#background(*o)`
    # @return [self]
    def background!(*o)
      background("0")
      background(*o)
      
      return self
    end
    
    # !@method width(*val)
    # Set or retrieve the width
    # @param val [Integer] the width, pass to set, omit to retrieve
    # @return [self]
    
    # !@method width=(val)
    # Sets the width
    # @param val [Integer] the width
    # @return [Integer] +val+
    
    # !@method set_width(val)
    # Sets the width
    # @param val [Integer] the width
    # @return [void]
    
    # !@method get_width()
    # Gets the width
    # @return [Integer] the width

    # !@method height(*val)
    # Set or retrieve the height
    # @param val [Integer] the height, pass to set, omit to retrieve
    # @return [self]
    
    # !@method height=(val)
    # Sets the height
    # @param val [Integer] the height
    # @return [Integer] +val+
    
    # !@method set_height(val)
    # Sets the height
    # @param val [Integer] the height
    # @return [void]
    
    # !@method get_height()
    # Gets the height
    # @return [Integer] the height
    get_set_chain :width, :height do |t,_|
      t == :set ? element.style : element.style!
    end
    
    get_set_chain :background do |t,k,_|
      proc do |t,k,*o|
      v = o[0]
      
      if t == :set
        if v.is_a?(Hash)
          v.each_pair do |key, val|
            element.style[:"background-#{key}"] = val
          end
        elsif v.is_a?(Array)
          element.style[:background] = v.map do |q| q.to_s end.join(" ")
        elsif v.is_a?(String)
          element.style[:background] = v
        else
          raise "Unsupported set from #{v.class}"
        end
        
        return v
      else
        if o.empty?
          return element.style[:background]
        else
          return(o.map do |q| element.style[:"background-#{q}"] end)
        end
      end
      end
    end
    
    # Focuses (raises) the ::UI::Window +window+
    #
    # @param window [::UI::Window] the window to activate
    #
    # @return [::UI::Screen] self
    def activate(window)
      element.css(".pbr-opalui-window").each do |w|
        if window.element == w
          w.add_class ".pbr-opalui-window-active"
        else
          w.remove_class ".pbr-opalui-window-active"
        end
      end
      
      return self
    end
    
    # Sets properties from Hash
    # @param opts [Hash]
    # @return [self]
    def apply opts={}
      raise "Argument must be `Hash`" unless opts.is_a?(Hash)
      
      opts.each_pair do |k,v|
        send(:"#{k}=", v) if respond_to?(:"#{k}=")
      end
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
