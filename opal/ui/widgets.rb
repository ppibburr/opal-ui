module PBR
  module OpalUI    
    # A Widget that displays text
    class Label < Widget
      include Widget::HasTextPropery
      
      # @example
      #   Label.new(:text=>"FooBar")
      def initialize *o
        super
        
        $document.create_element("SPAN").append_to element
      end
      
      private
      def text_element
        element.css("span")[0]
      end
    end

    # A Widget that displays an image
    class Image < Widget
      TAG_NAME = "IMG"
      
      #!@method initialize(opts={})
      # @example
      #  Image.new(:src=>"images/foo.png"
      
      # !@method src(*val)
      # Sets or retieves the Image's url
      # @param val [String] pass to set the url, omit to retrieve
      # @return [Widget|String]
      
      # !@method set_src(val)
      # Sets the Image's url
      # @param val [String] the url to set
      # @return [void]
      
      # !@method get_src()
      # Retrieves the Image's url
      # @return [String] the url
      
      # !@method src=(val)
      # Sets the Image's url
      # @param val [String] the url to set
      # @return [String] +val+         
      get_set_chain :src do |t,k,*o|
        if :get == t
          element[:src] 
        else
          proc do |t,k,val,*a|
            element[:src] = val
          end
        end
      end
    end
  end
end

module PBR
  module OpalUI
    # Widgets implementing focus availibility
    module Focus
      extend Widget::Interface
      def initialize *o
        super
        
        element[:tabindex] = "0"
      
        on :focus do
          $document.css(".pbr-opalui-widget-has-focus").each do |c|
            c.remove_class "pbr-opalui-widget-has-focus"
          end
          element.add_class "pbr-opalui-widget-has-focus" 
          
          @on_focus_cb.call          if @on_focus_cb
        end
      end
      
      def focus()
        `#@element.native.focus();`
      end
      
      def focused?
        !!element.class_names.index("pbr-oplaui-widget-has-focus")
      end
      
      def on_focus &b
        @on_focus_cb = b
      end
    end

    # Widgets that `activate` to the `ENTER` key
    module Activate
      extend Widget::Interface
      include Focus
      
      def initialize *o
        super
        
        element.on :keypress do |e|
          if (e.code == 13)
              activate()
              next false;
          end
            
          next true;
        end
      end
      
      # Activate the Widget
      #
      # @return [Activate] self
      def activate
        if !focused?
          focus()
        end
        
        element.add_class "pbr-opalui-active-activated"    
        
        @on_activate_cb.call(self) if @on_activate_cb
        
        return self
      end
      
      # Sets the `on_activate` handler
      def on_activate(&b)
        @on_activate_cb = b
      end
    end

    # Widgets implementing may have an icon rendered to the left or right
    module Iconable
      extend Widget::Interface
      
      style do
        display :flex
        flex flow: [:column, :nowrap]
     
        rule ".pbr-opalui-iconable-icon-left" do
          order 0
        end   
      end
      
      def init *o,&b
        super
        
        img = Image.new
        img.element.append_to element
        img.element.add_class "pbr-opalui-iconable-icon"

        content = self.class::CONTENT_CLASS.new()
        content.element.append_to element
        content.element.add_class "pbr-opalui-iconable-content"    
        
        icon_pos(:left)
      end
      
      def icon_widget
        Image.wrap element.css(".pbr-opalui-iconable-icon")[0]
      end
      
      # The content widget
      # @return [Widget]
      def content
        self.class::CONTENT_CLASS.wrap element.css(".pbr-opalui-iconable-content")[0]
      end
      
      # @!method icon_pos(*val)
      # Set or Retrieve the Widgets icon location: :left or :right
      # @param val [Symbol] pass to set the icon location, omit to retrieve the icon location
      # @return [Widget|Symbol]
      
      # @!method icon_pos=(val)
      # Sets the Widgets icon location
      # @param val [Symbol] the location of the icon
      # @return [Symbol] +val+
      
      # @!method get_icon_pos()
      # Gets the Widget's icon location
      # @return [Symbol]
      
      # @!method set_icon_pos(val)
      # Sets the Widgets icon location
      # @param val [Symbol] the location of the icon
      # @return [void]    
      get_set_chain :icon_pos do
        proc do |t, k, val|
          case t
          when :get
            @icon_pos
          else
            raise "Bad position for icon #{val}" unless [:left, :right].index(val)
          
            icon.element.add_class "pbr-opalui-iconable-icon-#{val}"
            content.element.add_class "pbr-opalui-iconable-content-#{val}"
            
            @icon_pos = val
          end
        end
      end
    end
    
    # May be focused, may be activated, may be selected 
    module Item
      extend Widget::Interface
      include Activate

      style do
        white space: :nowrap;
      end

      def init *o
        super
        
        on_focus do
          select
        end
      end

      # Selects the item
      #
      # @return [Item] self
      def select
        focus() unless focused?
      
        element.add_class "pbr-opalui-item-selected"
      
        @on_select_cb.call(self) if @on_select_cb
      
        return self
      end
    
      # @return [Boolean] true if selected
      def selected?
        element.class_names.index("pbr-opalui-item-selected")
      end
      
      # Sets the `on_select` handler
      def on_select &b
        @on_select_cb = b
      end
    end

    # Manages multiple items
    module HasItems
      extend Widget::Interface
 
      get_set_chain :item do 
        proc do |t,k,val,*o|
          t == :set ? activate(val) : items[val]
        end
      end

      def on_item_activate &b
        @on_item_activated_cb = b
      end
      
      def on_item_select &b
        @on_item_selected_cb = b
      end
      
      # @return [Array<Item>] items
      def items &b
        raise "NotImplemented"
      end
      
      def append_item i
        manage_item(i)
      end
      
      # Activate an Item
      #
      # @param i [Integer] index of the item to activate
      #
      # @return [HasItems] self
      def activate i
        items[i].activate
        
        return self
      end
      
      # Selects an Item
      #
      # @param i [Integer] index of the item to select
      #
      # @return [HasItems] self
      def select i
        items[i].select
        
        return self
      end
      
      # @return [Integer] index of the active item
      def active
        act = items.find do |i|
          i.element.class_names.index("pbr-opalui-active-activated")
        end
        
        items.index(act)
      end
      
      # @return [Array<Integer>] indices of the selected item(s)      
      def selection
        sel = items.find_all do |i|
          i.element.class_names.index("pbr-opalui-item-selected")
        end.map do |s| s.element end
      
        sel.map do |i|
          items.map do |i| i.element end.index(i)
        end
      end
      
      private
      def select_prior
        i = selection[0]-1
        
        return if i < 0
        
        items[i].select
      end
      
      def select_next
        i = selection[0]+1
        
        return if i >= items.length
        
        items[i].select  
      end
      
      def manage_item i
        i.on_select do
          items.each do |c|
            next if c.element == i.element
            c.element.remove_class "pbr-opalui-item-selected"
          end

          @on_item_selected_cb.call(self, i) if @on_item_selected_cb
        end
        
        i.on_activate do |w|
          items.each do |c|
            next if c.element == i.element
            c.element.remove_class "pbr-opalui-active-activated"
          end
              
          @on_item_activated_cb.call(self, w) if @on_item_activated_cb
        end
      end
    end
  end
end
