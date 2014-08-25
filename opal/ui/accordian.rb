module PBR
  module OpalUI
    # A Container, HasItems, that expands ONE child add a time
    class Accordian < Container
      include HasItems 
      
      style do
        display :flex       
        
        rule ".pbr-opalui-accordian-item.pbr-opalui-item-selected" do
          flex [1,1,:auto, "!important"]
      
          rule ".pbr-opalui-accordian-item-inner" do
            max height: :inherit
          end
        end   
      
        rule ".pbr-opalui-accordian-item" do
          flex [0,1,:auto]
          rule ".pbr-opalui-accordian-item-inner" do
            max height: 0.px
          end          
        end                          
      end
      
      # An Accordian Item
      class Item < Bin
        include PBR::OpalUI::Focus
        include PBR::OpalUI::Activate
        include PBR::OpalUI::Item
        include Widget::HasLabelProperty
        include Widget::HasIconProperty        
        
        style do
          flex [0, 0, :auto]
          
          rule ".#{Item.class_name}-inner" do
            display :flex
            flex [1, 1, :auto]
          end
        end
      
        # An Accordian Item Header
        class Header < Widget
          style do
            display :flex
            flex [0, 1, :auto]
            height 1.1.em
            flex flow: [:row, :nowrap]
            padding 3.px
            
            rule ".pbr-opalui-iconable-icon" do
              height 1.1.em
              max height: 1.1.em
            end
          end
          
          include Widget::HasIconProperty
          include Iconable
          include Widget::HasLabelProperty
          
          CONTENT_CLASS = Label
        
          def label_widget
            content
          end
        end
        
        def init *o
          super
          header = Header.new
          header.element.append_to element

          
          w = Widget.new
          w.element.add_class "pbr-opalui-accordian-item-inner"
          w.element.append_to element
          
          element.style.apply do
            transition [:all, 2.s]
          end
        end
        
        # @return [PBR::OpalUI::Accordian::Item::Header] the items Header
        def header
          Header.wrap element.css(".pbr-opalui-accordian-item-header")[0]
        end
        
        private
        def container_element
          element.css(".pbr-opalui-accordian-item-inner")[0]
        end        
        
        def label_widget
          header.label_widget
        end
        
        def icon_widget
          header.icon_widget
        end
      end
      
      def item *o
        # Delay the event. Helps with initial page load
        # Delay the setting a very tiny amount
      
        if !o.empty?
          after 0.1 do |_|
            set_item o[0]
          end
          
          self
        else
          super
        end
      end
      
      # Appends an Item
      #
      # @param opts [Hash] options
      #
      # @option child [PBR::OpalUI::Widget] adds +child+ to the Item
      # @option label [String] passed to `Item#header().label(label)`
      # @option icon  [Sting] url of image, passed to `Item#header().icon(icon)`
      #
      # @param b [Proc] called with the appended item as an argument
      #
      # @yieldparam c [PBR::OpalUI::Accordian::Item] the appended item
      # 
      # @return [PBR::OpalUI::Accordian] self
      def append(opts={}, &b)
        item = self.class::Item.new
        
        if w = opts.delete(:child)
          item.add(w)
        end
        
        item.apply(opts)
        
        append_item item
        
        add item, &b
        
        item.select if children.length == 1
      
        return self
      end 
      
      # Gets the items
      #
      # @param b [Proc] pass to iter over the children
      # @yieldparam c [PBR::OpalUI::Accordian::Item] the child
      #
      # @return [Array<PBR::OpalUI::Accordian::Item>] list of items
      def items &b
        children.map do |c|
          c = Item.wrap(c.element)
          b.call c if b
          c
        end
      end       
      
      private :add
    end
  end
end
