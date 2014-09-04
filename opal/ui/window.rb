module PBR
  module OpalUI
    # A Window
    class Window < Bin
      include Widget::HasIconProperty
      
      style do
        position :absolute
        resize :both, "!important"
        width :initial
        height :initial
        display :flex
        
        rule ".#{PBR::OpalUI::Window.class_name}-outer" do
          display :flex
          flex [1, 1, :auto]
          flex flow:[:column, :nowrap]
        end
        
        rule ".#{PBR::OpalUI::Window.class_name}-inner" do
          display :flex
          flex [1, 1, :auto]
          flex flow:[:column, :nowrap]          
        end        
        
        rule ".pbr-opalui-window-resize" do
            min width:5.px
            min height:5.px                    
        end
        
        [:top,:middle,:bottom].each_with_index do |q,i|
          rule ".pbr-opalui-window-outer-#{q}" do |_|
            _.display :flex
            _.min height:5.px
            _.flex flow:[:row, :nowrap]
            _.flex i == 1 ? [1,1,:auto] : [0,0,:auto]
          end
        end
        
        [:e,:ne,:w,:nw,:se,:sw].each do |q|
          rule ".pbr-opalui-window-#{q}-resize" do |_|
            _.cursor "#{q}-resize"
            _.flex [0,0,:auto] 
          end
        end
        
        [:n,:s].each do |q|
          rule ".pbr-opalui-window-#{q}-resize" do |_|
            _.cursor "#{q}-resize"
            _.flex [1,1,:auto] 
          end
        end        
        
        rule "&.pbr-opalui-window-maximize" do
          top 0, "!important"
          left 0, "!important"
          min height:"100%"
          max height: "100%"
          min width:"100%"
          max width: "100%" 
          border 0         
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
          parent = opts[:parent]
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
        
        title_bar.on :dblclick do
          toggle_maximize()
        end
        
        title_bar.init_drag self
      
        a = []
        
        top    = [$document.create_element("div"),$document.create_element("div"),$document.create_element("div")]
        bottom = [$document.create_element("div"),$document.create_element("div"),$document.create_element("div")] 
        middle = [$document.create_element("div"),$document.create_element("div"),$document.create_element("div")]
        
        @a = outer = middle[1]
        
        title_bar.element.append_to outer   
        outer.add_class "#{self.class.class_name}-outer"
      
        @container_element = $document.create_element("div")
        container_element.append_to outer
        container_element.add_class "#{self.class.class_name}-inner"
      
        a = [:top,:middle,:bottom]
        [h_top    = $document.create_element("div"),
        @h = h_middle = $document.create_element("div"),
        h_bottom = $document.create_element("div")].each_with_index do |e,i|
         e.append_to element
         e.add_class "pbr-opalui-window-outer-#{a[i]}"
        end
        
        top.each    do |e| e.append_to h_top    end
        middle.each do |e| e.append_to h_middle end
        bottom.each do |e| e.append_to h_bottom end
        
        a=[
          top,
          [middle[0], middle[2]],
          bottom
        ].flatten
        a.each do |e| e.add_class "pbr-opalui-window-resize" end
        
        [:nw,:n,:ne,:e,:w,:sw,:s,:se].each_with_index do |q,i| a[i].add_class "pbr-opalui-window-#{q}-resize" end
      end
      
      # Toggles between maximized and prior size
      # @return [void]
      def toggle_maximize
        maximize(!maximize())
      end
      
      # !@method maximize(*val)
      # Sets the Window to maximized or gets Boolean: true if maximized 
      # @param val [Boolean] pass to set, omit to retrieve
      # @return [Window|Boolean]
      
      #
      #
      #
      #
      
      #
      #
      #
      #
      get_set_chain :maximize do
        proc do |t,k,val,_|
          t == :set ? element.send(val == true ? :add_class : :remove_class, "pbr-opalui-window-maximize") : !!element.class_names.index("pbr-opalui-window-maximize")
        end
      end
      
      get_set_chain :width, :height do |t,k,_|
        proc do |t,k,val,_|
          if t == :set
            k == :width ? @a.style[k] = val : @h.style[k] = (val.to_i + 26).px
          else
            container_element.style![k]
          end
        end
      end
      
      # !@method title(*val)
      # Sets or gets the Window's titlebar title text
      # @param val [String] pass to set, omit to retrieve
      # @return [Window|String]
      
      #
      #
      #
      #
      
      #
      #
      #
      #      
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
