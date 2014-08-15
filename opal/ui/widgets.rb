module PBR
  module OpalUI
    class Label < Widget
      def initialize *o
        super
        
        $document.create_element("SPAN").append_to element
      end
    
      get_set_chain :text do
        [element.css("span")[0], :inner_text, :"inner_text="]
      end
    end


    class Image < Widget
      TAG_NAME = "IMG"
      get_set_chain :src do
        element
      end
    end
  end
end

module PBR
  module OpalUI
    module Focus
      extend Widget::Interface
      def initialize *o
        super
        
        element[:tabindex] = "0"
      end
      
      def focus()
        `#@element.native.focus`
      end
      
      def focused?
        element.css(":focused")[0] == element
      end
    end

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
      
      def activate
        if !focused?
          focus()
        end
        
        element.add_class "pbr-opalui-active-activated"    
        
        @on_activate_cb.call(self) if @on_activate_cb
      end
      
      def on_activate(&b)
        @on_activate_cb = b
      end
    end

    module Iconable
      extend Widget::Interface
      
      style do
        display :flex
        flex flow: [:column, :nowrap]
     
        rule ".pbr-opalui-iconable-icon-left" do
          order 0
        end   
      end
      
      def initialize
        super
        
        img = Image.new
        img.element.append_to element
        img.element.add_class "pbr-opalui-iconable-icon"

        content = self.class::CONTENT_CLASS.new()
        content.element.append_to element
        content.element.add_class "pbr-opalui-iconable-content"    
        
        icon_pos(:left)
      end
      
      get_set_chain :icon do |k,*o|
        proc do |t,k,val|
          case t
          when :get
            Image.wrap element.css(".pbr-opalui-iconable-icon")[0]
          else
            element.css(".pbr-opalui-iconable-icon")[0][:src] = val
          end
        end
      end
      
      def content
        self.class::CONTENT_CLASS.wrap element.css(".pbr-opalui-iconable-content")[0]
      end
      
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
    
    module Item
      extend Widget::Interface
      include Activate

      style do
        white space: :nowrap;
      end

      def initialize *o
        super
        
        element.on :focus do
          select
        end
      end

      def select
        focus() unless focused?
        element.add_class "pbr-opalui-item-selected"
        @on_select_cb.call(self) if @on_select_cb
      end
      
      def selected?
        element.class_names.index("pbr-opalui-item-selected")
      end
      
      def on_select &b
        @on_select_cb = b
      end
    end

    module HasItems
      extend Widget::Interface

      def on_item_activate &b
        @on_item_activated_cb = b
      end
      
      def on_item_select &b
        @on_item_selected_cb = b
      end
      
      def items &b
        raise "NotImplemented"
      end
      
      def append_item i
        manage_item(i)
      end
      
      def activate i
        items[i].activate
      end
      
      def select i
        items[i].select
      end
      
      def active
        act = items.find do |i|
          i.element.class_names.index("pbr-opalui-active-activated")
        end
        
        items.index(act)
      end
      
      def selection
        sel = items.find_all do |i|
          i.element.class_names.index("pbr-opalui-item-selected")
        end
      
        sel.map do |i|
          items.index(i)
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
        i.on :focus do
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
