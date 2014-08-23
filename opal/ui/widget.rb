class Module
  alias is_a_? is_a?
  def is_a? mod
    is_a_?(mod) || ancestors.find do |q| q.singleton_class.ancestors.index(mod) end || !!singleton_class.ancestors.index(mod)
  end
end

module PBR;
  module GetSetChain  
    # Defines setters, getters C Style, Ruby Style and JQuery Style
    def get_set_chain *o , &b
      dispatch = proc do |t, k, cb|
        delagate = nil
        handler  = nil
        
        if cb
          q = instance_exec(t, k, &cb)
          
          if q.is_a?(Proc)
            handler = q
          else
            if q.is_a?(Array)
              delagate = q.shift
            
            else
              delagate = q
              
              q = [k, :"#{k}="]
            end
          end
        end
        
        next delagate,handler,q
      end    
      
      o.each do |k|
        define_method :"get_#{k}" do
          delagate, handler, q = instance_exec(:get, k, b, &dispatch)

          if delagate
            next delagate.send(q[0])
          elsif handler
            next instance_exec(:get, k, &handler)
          else
            instance_variable_get("@#{k}")
          end
        end
        
        define_method :"set_#{k}" do |val|
          delagate, handler, q = instance_exec(:set, k, b, &dispatch)

          if delagate
            next delagate.send(q[1], val)
          elsif handler
            next instance_exec(:set, k, val, &handler)
          else
            instance_variable_set("@#{k}", val)
          end
          
          next true      
        end
        
        alias_method :"#{k}=", :"set_#{k}"
        
        define_method k do |*a|
          if a.empty?
            next send(:"get_#{k}")
          end
          
          send(:"set_#{k}", *a)
          
          next self
        end
      end
    end
  end
end

module PBR
  # A GUI ToolKit in your Browser
  module OpalUI;
    class Widget
      # Implemented by Widget and widget interfaces
      module Interface
        def self.extended cls
          cls.send :extend, GetSetChain
        end
        
        def style *o, &b
          o = o.reverse.push(self).reverse
          styler = Class.new
          styler.extend Styler
          styler.style *o,&b
          styler.apply
        end        
        
        # @return [String] the resolved css `class_name`
        def class_name
          @class_name ||= self.to_s.downcase.split("::").join("-")
        end
        
        def css *o,&b
          CSS(*o,&b).append_to $document.head
        end
      end

      extend self::Interface
      
      TAG_NAME = "DIV"
      
      style do
        display :flex
        overflow :hidden
         
        focus do
          outline 0
        end
      end
      
      def self.wrap q
        raise "Not a #{self}: #{q}" unless q.class_names.index(class_name) 
      
        ins = allocate
        ins.instance_variable_set "@element", q
        return ins
      end
      
      # A Widget that has an obvious `text` property
      module HasTextPropery
        extend GetSetChain
        
        # !@method text(*val)
        # Sets or retieves the Wisget's text
        # @param val [String] pass to set the text, omit to retieve
        # @return [Widget|String]
        
        # !@method set_text(val)
        # Sets the Widget's text 
        # @param val [String] the text to set
        # @return [void]
        
        # !@method get_text()
        # Retrieves the Widget's text
        # @return [String] the text
        
        # !@method text=(val)
        # Sets the Widget's text 
        # @param val [String] the text to set
        # @return [String] +val+
        get_set_chain :text do
          [text_element, :inner_text, :"inner_text="]
        end
        
        def text_element
          element
        end
      end

      # A Widget that has an obvious `label` property      
      module HasLabelProperty
        extend GetSetChain

        # !@method label(*val)
        # Sets or retieves the Widget's label text or Label Widget
        # @param val [String] pass to set the text, omit to retieve the Label Widget
        # @return [Widget|Label]
        
        # !@method set_label(val)
        # Sets the Widget's Label text 
        # @param val [String] the text to set
        # @return [void]
        
        # !@method get_label()
        # Retrieves the Widget's Label Widget
        # @return [Label] the Label
        
        # !@method label=(val)
        # Sets the Widget's Label text 
        # @param val [String] the text to set
        # @return [String] +val+        
        get_set_chain :label do |t,k,*o|
          :set == t ? [label_widget, :text, :"text="] : Proc.new do label_widget end
        end
        
        private
        def label_widget
          raise "NotImplemented: `label_widget` for #{self.class}"
        end
      end
      
      # A Widget that has an obvious `icon` property      
      module HasIconProperty
        extend GetSetChain
                
        # !@method icon(*val)
        # Sets or retieves the Widget's icon
        # @param val [String] pass to set the image, omit to retieve the Image Widget
        # @return [Widget|Image]
        
        # !@method set_icon(val)
        # Sets the Widget's icon 
        # @param val [String] the url to render
        # @return [void]
        
        # !@method get_icon()
        # Retrieves the Widget's Image Widget
        # @return [Image] the Image
        
        # !@method icon=(val)
        # Sets the Widget's icon
        # @param val [String] the url to render
        # @return [String] +val+                   
        get_set_chain :icon do |t, k, *o|
          :set == t ? [icon_widget, :src, :"src="] : Proc.new do icon_widget end
        end
        
        get_set_chain :icon_size do |t,k,*o|
          :set == t ? Proc.new do |t,k,val,*o| icon_widget.size = val end : Proc.new do icon_widget end
        end
        
        private
        def icon_widget
          raise "NotImplemented: `icon_widget` for #{self.class}"
        end        
      end
      
      # A Widget that has an obvious `text` property and whose contents ared editable      
      module Editable
        extend GetSetChain        
        
        extend Widget::Interface
        
        include HasTextPropery
        
        style do
          display :block
        end
        
        private
        def init *o
          super
          text_element["contenteditable"] = true
        end
      end
      
      # Widgets contents overflow is scrolled
      module Scrollable
        extend Widget::Interface
        
        style do
          overflow :auto
        end
        
        def init *o
          super
          
          scrollable_element.add_class "#{Scrollable.class_name}"
        end
        
        private
        def scrollable_element
          element
        end
      end
      
      attr_reader :element
      
      # @param options [Hash] key/val where keys are setter method names
      # @example
      #    Image.new(:src=>"images/foo.png",
      #              :size=>[24,24])
      def initialize options = {}
        @element = $document.create_element(self.class.tag_name.to_s.upcase)

        self.class.ancestors.find_all do |q| q.is_a?(Interface) end.reverse.each do |q|
          element.add_class q.class_name
        end
        
        init()
        
        apply(options)
      end
      
      # The tag of the element to wrap
      # @return [String]
      def self.tag_name
        self::TAG_NAME
      end
      
      # Renders an Image
      # @param src [String] url of image
      # @return [Image] the resulting Image
      def rener_icon src
        element.inner_html = ""
        img = Image.new(src)
        img.append_to element
        
        return img
      end
      
      # Sets the inner_html
      # @param html [String] innerHTML
      # @return [String] +html+
      def render_html html
        element.inner_html = html
      end
      
      # @!method height(*val)
      # Set or Retrieve the height of the Widget
      # @param val [Integer] pass to set the height, omit to retrieve the height
      # @return [Widget|Integer]
      
      # @!method height=(val)
      # Sets the height of a Widget
      # @param val [Integer] the height to set to
      # @return [Integer] +val+
      
      # @!method get_height()
      # Gets the Widget's height
      # @return [Integer]
      
      # @!method set_height(val)
      # Sets the widget's height
      # @param val [Integer] the height to set to
      # @return [void]
      
    
      
      # @!method width(*val)
      # Set or Retrieve the width of the Widget
      # @param val [Integer] pass to set the width, omit to retrieve the width
      # @return [Widget|Integer]
      
      # @!method width=(val)
      # Sets the width of a Widget
      # @param val [Integer] the width to set to
      # @return [Integer] +val+
      
      # @!method get_width()
      # Gets the Widget's width
      # @return [Integer]
      
      # @!method set_width(val)
      # Sets the widget's width
      # @param val [Integer] the width to set to
      # @return [void]
      
      
      
      # @!method top(*val)
      # Set or Retrieve the Y position of the Widget
      # @param val [Integer] pass to set the point, omit to retrieve the point
      # @return [Widget|Integer]
      
      # @!method top=(val)
      # Sets the Y position of a Widget
      # @param val [Integer] the point to set to
      # @return [Integer] +val+
      
      # @!method get_top()
      # Gets the Widget's Y position
      # @return [Integer]
      
      # @!method set_top(val)
      # Sets the widget's Y position
      # @param val [Integer] the point to set to
      # @return [void]
      
      
      
      # @!method left(*val)
      # Set or Retrieve the X position of the Widget
      # @param val [Integer] pass to set the point, omit to retrieve the point
      # @return [Widget|Integer]
      
      # @!method left=(val)
      # Sets the X position of a Widget
      # @param val [Integer] the point to set to
      # @return [Integer] +val+
      
      # @!method get_left()
      # Gets the Widget's X position
      # @return [Integer]
      
      # @!method set_left(val)
      # Sets the widget's X position
      # @param val [Integer] the point to set to
      # @return [void]               
      
      
      
      # @!method color(*val)
      # Set or Retrieve the foreground color of the Widget
      # @param val [String] pass to set the color, omit to retrieve the color
      # @return [Widget|String]
      
      # @!method color=(val)
      # Sets the color of a Widget
      # @param val [String] the color to set to
      # @return [String] +val+
      
      # @!method get_color()
      # Gets the Widget's color
      # @return [String]
      
      # @!method set_color(val)
      # Sets the widget's color
      # @param val [String] the color to set to
      # @return [void]           
      get_set_chain :height, :width, :top, :left, :color do
        next element.style
      end
      
      # @!method tooltip(*val)
      # Set or Retrieve the tooltip of the Widget
      # @param val [String] pass to set the tooltip, omit to retrieve the tooltip
      # @return [Widget|String]
      
      # @!method tooltip=(val)
      # Sets the tooltip of a Widget
      # @param val [String] the tooltip text to set
      # @return [String] +val+
      
      # @!method get_tooltip()
      # Gets the Widget's tooltip
      # @return [String]
      
      # @!method set_tooltip(val)
      # Sets the widget's tooltip
      # @param val [String] the tooltip text to set
      # @return [void]       
      get_set_chain :tooltip do
        [element, :title, :"title="]
      end
      
      # @!method size(*val)
      # Set or Retrieve the size of the Widget
      # @param val [Array<Integer>] pass to set the size, omit to retrieve the size
      # @return [Widget|Array<Integer>]
      
      # @!method size=(val)
      # Sets the size of a Widget
      # @param val [Array<Integer>] the size to set to
      # @return [Array<Integer>] +val+
      
      # @!method get_size()
      # Gets the Widget's size
      # @return [Array<Integer>]
      
      # @!method set_size(val)
      # Sets the widget's size
      # @param val [Array<Integer>] the size to set to
      # @return [void] 
      
      
      
      # @!method position(*val)
      # Set or Retrieve the X position of the Widget
      # @param val [Array<Integer>] pass to set the point, omit to retrieve the point
      # @return [Widget|Array<Integer>]
      
      # @!method position(val)
      # Sets the X position of a Widget
      # @param val [Array<Integer>] the point to set to
      # @return [Array<Integer>] +val+
      
      # @!method get_position()
      # Gets the Widget's X position
      # @return [Array<Integer>]
      
      # @!method set_position(val)
      # Sets the widget's position
      # @param val [Array<Integer>] the point to set to
      # @return [void]             
      get_set_chain :size,:position do |t,k|
        proc do |t,m,*o|
          case t
          when :set
            q = o[0]
          
            k == :size ? width(q[0]).height(q[1]) : left(q[0]).top(q[1])
          
          else
            k == :size ? [width, height] : [top, left]
          end
        end
      end
      
      # Register event listeners
      # @param e [#to_s] event name
      # @param b [Proc] callback
      # @yield [e,*arguments]
      # @yieldparam e [Browser::Dom::Event]
      # @yieldparam arguments [Array<Object>] event arguments
      # @return [Browser::DOM::Event::Callback]
      def on e, &b
        element.on(e, &b)
      end
      
      # Removes an event listener
      #
      # @param what [Browser::DOM::Event::Callback] handler
      # @return [void]
      def off what
        element.off what
      end
      
      # Sets the `on_keypress` handler
      def on_keypress &b
        on :keypress, &b
      end
      
      # Sets the `on_click` handler
      def on_click &b
        on :click, &b
      end
      
      # Sets properties defined by a Hash
      # Any `setter` method name minus the '=' is allowed as a key, ie `width`
      #
      # @example
      #   img = Image.new()
      #   img.apply(:src=>"images/foo.png",
      #             :size=>[24,24)
      #
      # @param options [Hash] properties to set
      # @return [Widget] self
      def apply(options={})
        options.each_pair do |k,v|
          send(:"#{k}=", v) if respond_to? :"#{k}="
        end
        
        return self      
      end
      
      private
      def init
      
      end
    end
  end
end
