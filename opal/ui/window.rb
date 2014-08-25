module PBR
  module OpalUI
    # A Window
    class Window < Bin
      include Widget::HasIconProperty
      
      style do
        position :absolute
        resize :both
        
        rule ".#{PBR::OpalUI::Window.class_name}-inner" do
          display :flex
          flex [1, 1, :auto]
        end
      end
      
      class Titlebar < Widget
        include Widget::HasLabelProperty
        include Widget::HasIconProperty
        include Iconable
        include Drag
        
        CONTENT_CLASS = Label
          
        style do
          min height:1.5.em
          flex [0,1,:auto]
          user select: :none
          style "-webkit-user-select", :none
          flex flow:[:row, :nowrap]

          rule ".#{PBR::OpalUI::Label.class_name} span" do
            vertical align: :middle
            style "align-self", :center
          end
        end
      end
      
      # @param parent [Browser::DOM::Element] the element to attach to, or nil to use `doceemnt.body`
      def initialize(parent = nil,*opts)
        if parent.is_a?(Hash)
          opts = parent
          parent = nil
        end
      
        super(*opts)
        
        if parent and parent.is_a? Browser::DOM::Element
          element.append_to parent
        elsif !parent
          element.append_to $document.body
        end
      end
      
      def init *o
        super
        
        title_bar = Titlebar.new
        title_bar.element.append_to self.element        
        
        title_bar.init_drag self
        
        @container_element = $document.create_element("div")
        container_element.append_to element
        container_element.add_class "#{self.class.class_name}-inner"
      end
            
      get_set_chain :title do
        [title_bar.content, :text, :"text="]
      end
      
      private
      def title_bar
        Titlebar.wrap(element.css(".#{self.class::Titlebar.class_name}")[0])
      end      
      
      def icon_widget
        title_bar.icon()
      end
    end
  end
end
