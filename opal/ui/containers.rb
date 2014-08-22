module PBR
  module OpalUI
    # A Widget whom may contain child(ren)
    class Container < Widget
      style do
        display :flex
        flex flow: [:column, :nowrap]
        
        rule ".pbr-opalui-container-child" do
          flex [1,1,:auto]
        end        
      end

      # Adds a child Widget
      #
      # @param w [Widget] the child to add
      # @return [Container] self
      def add w,&b
        w.element.append_to container_element
        
        bool = false
        
        self.class.ancestors.reverse.each do |q|
          bool = true if q == Container
          next unless q.is_a?(Widget::Interface)  
          
          next unless bool
          
          w.element.add_class q.class_name+"-child"
        end

        b.call(w) if b

        return self
      end
      
      # @return [Array<Widget>] children
      def children &b
        a = []
        
        container_element.css(".#{self.class.class_name}-child").each do |c|
          w = Widget.wrap c
          yield w if b
          a << w
        end
        
        a
      end
      
      # Iterate over children
      #
      # @yieldparam c [Widget] child
      #
      # @return [Container] self
      def iter &b
        children &b
        
        return self
      end
      
      private
      def container_element
        @container_element || element
      end      
    end

    # A Container that may only contain ONE child
    class Bin < Container
      def add w
        raise "`Bin##{self}` Already has child" unless children.length < 1
        
        super
      end
      
      def child
        children[0]
      end
    end

    # A Bin with a border around it with a label
    class Frame < Bin
      include Widget::HasLabelProperty
      
      css "
       .pbr-opalui-frame-top-left {
         flex:1 1 auto;
         display:inline-block;
         position:relative;
         top:-4px;
         left:-1px;         
        }
        
       .pbr-opalui-frame-top-right {
         flex:1 1 auto;
         display:inline-block;
         position:relative;
         top:-4px;
         left:1px;           
        }        
        
        .pbr-opalui-frame-label {
          position:relative;    
          top:calc(-0.75em);
          display:inline-block;
          margin-left:3px;
          margin-right:3px;
        }
        
        .pbr-opalui-frame-inner {
          display:flex;
          flex:1 1 auto;
          position:relative;
          top:-0.5em;
          padding:2px;
        }        
        
        .pbr-opalui-frame {            
            display:flex;
            flex-flow:column nowrap;
            padding-top:0.25em;
            margin-top:0.5em;
            overflow:initial;
        }
        
        .pbr-opalui-frame-top {
            display:flex;
            flex-flow:row nowrap;
        }
"      
      
      private
      def label_widget
        Label.wrap(element.css(".pbr-opalui-frame-label")[0])
      end
            
      def init
        super
        
        element.inner_html = "
          <div class=pbr-opalui-frame-top>
            <span class=pbr-opalui-frame-top-left></span>
            <div class=pbr-opalui-frame-label>#{Label.new().element.inner_html}</div>
            <span class=pbr-opalui-frame-top-right></span>
          </div>
          <div class=pbr-opalui-frame-inner></div>
        "
        l = element.css(".pbr-opalui-frame-label")[0]
        l.add_class "pbr-opalui-widget"
         l.add_class "pbr-opalui-label"       
      end
      
      def container_element
        element.css(".pbr-opalui-frame-inner")[0]
      end           
    end

    # A Window
    class Window < Bin
      style do
        position :absolute
        resize :both
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
    end

    # Box layout. Gtk+ style and flexbox. Laysout children along its major axis
    module Box
      extend Widget::Interface

      style do
        display :flex;
    
        rule ".pbr-opalui-box-child" do
          flex [0, 1, :auto]
        end
        
        rule ".pbr-opalui-box-child-fill" do
          flex [1, 1, :auto, "!important"]
        end
        
        rule ".pbr-opalui-box-padding" do
          flex [0.5, 1, :auto]
        end
      end

      def add w,&b
        super
        pad_child c=children.last, c.element.style[:"padding-#{self.class.get_padding_type[0]}"].to_i-spacing() 
        return self       
      end
      
      # Adds a child with specified flex and padding
      #
      # @example
      #   box = HBox.new
      #   
      #   # the left child grows to one half the right childs width
      #   box.pack_flex child, 1, 5
      #   box.pack_flex child, 2, 5
      #
      #      
      # @param w [Widget] child to add
      # @param amt [Integer] amount of flex
      # @param pad [Integer] amount of padding in addition to `#get_spacing`
      #
      # @return [Box] self
      def pack_flex w, amt=1, pad=0,&b
        add w, &b
        
        w.element.style.flex = "#{amt} 1 auto"
        
        pad_child w, pad
        
        return self
      end

      # Adds a child with specified rules for sizing
      #
      # @example
      #   # Child `left` exands and fills one half of the width
      #   # Child `right` is centered in one half of the width
      #   pack_start left, true, true, 0
      #   pack_start right, true, false, 0
      #
      # @param w [Widget] child to add
      # @param expand [Boolean] true to take up freespace
      # @param fill [Boolean] true to fill the freespace. Only valid if +expand+ is true
      # @param pad [Integer] amount of padding in addition to `#get_spacing`
      #
      # @return [Box] self
      def pack_start w, expand=false, fill=false, pad=0, &b      
        if expand and !fill
          pad = $document.create_element("DIV")
          pad.add_class "pbr-opalui-box-padding"
          pad.append_to element
          
          add w, &b
          
          pad = $document.create_element("DIV")
          pad.add_class "pbr-opalui-box-padding"
          pad.append_to element
        
        elsif !expand
          add w
        
        elsif expand and fill
          w.element.add_class "pbr-opalui-box-child-fill"        
          add w    
        end
        
        pad_child(w,pad)
        
        return self
      end
      
      # @!method spacing(*val)
      # Set or Retrieve the padding amount between children.
      # @param val [Integer] pass to set the padding, omit to retrieve the padding
      # @return [Widget|Integer]
      
      # @!method spacing=(val)
      # Sets the padding amount between children.  If the child is the first and/or last child the padding is also applied between the child and the edge of the Box
      # @param val [Integer] the amount of padding
      # @return [Integer] +val+
      
      # @!method get_spacing()
      # Gets the padding amount between children.
      # @return [Integer]
      
      # @!method set_spacing(val)
      # Sets the padding amount between children.  If the child is the first and/or last child the padding is also applied between the child and the edge of the Box
      # @param val [Integer] the amount of padding
      # @return [void]  
      get_set_chain :spacing do
        proc do |t,k,val,*o|
          case t
          when :get
            @spacing ||= 0
          else
            old = get_spacing
            @spacing = val
            
            t=self.class.get_padding_type
            
            iter do |c|
              amt = (c.element.style[:"margin-#{t[0]}"].to_i - old) + val
              
              pad_child c,amt
            end            
            
            next val
          end
        end
      end
 
      private
      def pad_child c,amt
        amt = spacing()+amt
        t=self.class.get_padding_type
        lc = children.last.element
        c.element.style[:"margin-#{t[0]}"] = amt.px
        c.element.style[:"margin-#{t[1]}"] = c.element == lc ? amt.px : 0.px      
      end
 
      PADDING_HORIZONTAL = [:left, :right]
      PADDING_VERTICAL   = [:top, :bototm]
      
      def self.included q
        def q.get_padding_type
          @padding_type ||= PADDING_VERTICAL
        end
        
         def q.set_padding_type type
          @padding_type = type
        end       
      end
    end

    # A Box that laysout children along the Vertical axis
    class VBox < Container
      include Box
      
      set_padding_type PADDING_VERTICAL
      
      style do
        flex flow: [:column, :nowrap]
      end
    end

    # A Box that laysout children along the Horizontal axis
    class HBox < Container
      include Box
      
      set_padding_type PADDING_HORIZONTAL
      
      style do
        flex flow: [:row, :nowrap]
      end
    end
    
    # A Container, HasItems, that expands ONE child add a time
    class Accordian < Container
      include HasItems 
      
      style do
        display :flex       
        
        rule ".pbr-opalui-item-selected" do
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
            height 1.5.em
            flex flow: [:row, :nowrap]
            padding 3.px
            
            rule ".pbr-opalui-iconable-icon" do
              height 1.5.em
              max height: 1.5.em
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
        children &b
      end       
      
      private :add
    end
  end
end



class PBR::OpalUI::Notebook < PBR::OpalUI::Container
  style do
    rule ".#{PBR::OpalUI::Notebook.class_name}-inner" do
      flex [1, 1, :auto]
      display :flex
    end
  end
  
  class Tab < Widget
    include HasLabelProperty 
    include HasIconProperty
    include Iconable
    include Widget::HasLabelProperty
    include Focus
    include Activate
    include Item
    
    CONTENT_CLASS = Label
    
    style do
      flex [0,1, :auto, "!important"]
      border [1.px, :solid, "#a9a9a9"]
      border radius: {top: {left:8.px}}
      border radius: {top: {right:8.px}}      
      background color:"#c9c9c9" 
      font size: :small
      
      rule "span" do
        padding 0.23.em
      end
                  
      max height: 1.67.em
      height 1.67.em  
      
      rule "&.pbr-opalui-item-selected" do
        flex [0, 1, :auto, "!important"]
        background color:"#e9e9e9" 
        border [1.px, :solid, "#c9c9c9"]        
        border bottom:0
        background "-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #f9f9f9), color-stop(1, #e9e9e9) );"       
      end
    end
    
    def label_widget
      content
    end
    
    get_set_chain :closable
  end
  
  class Page < Bin
    include Focus
    style do
      flex [1, 1, :auto]    
      display :none
      rule "&.pbr-opalui-notebook-page-current" do
        display :flex
      end
    end
  end
  
  class PBR::OpalUI::Notebook::Header < Container
    include HasItems
    
    style do
      flex [0, 1, :auto]
      min height:1.5.em
      flex flow:[:row, :nowrap]   
    
      rule ".pbr-opalui-notebook-header-right" do
        border bottom:[1.px, :solid, "#a9a9a9"]
        flex [1, 1, :auto]
      end
    end
    
    def append_item i, &b
      super i
      add i,&b
    end
    
    def items &b
      children.map do |c|
        i = Tab.wrap(c.element)
        b.call i if b
        i
      end
    end
    
    def init *o
      super
      
      right = Widget.new
      right.element.add_class "pbr-opalui-notebook-header-right"
      right.element.append_to self.element
    end
    
    def add *o, &b
      super
      
      element.css(".pbr-opalui-notebook-header-right")[0].style[:order] = children.length
      
      return self
    end
  end
  
  def init *o
    super
    header = Header.new
    header.element.append_to self.element
    
    header_widget.on_item_select do
      pg = Page.wrap(children[header.selection[0]].element)
    
      children.each do |c|
        c.element.remove_class "pbr-opalui-notebook-page-current"
      end
      
      pg.element.add_class "pbr-opalui-notebook-page-current"
      
      pg.child.element.instance_exec do
        `#@native.focus();`
      end
    end

    inner = Widget.new
    inner.element.add_class "pbr-opalui-notebook-inner"
    
    @container_element = inner.element
    container_element.append_to self.element
  end 
  
  # Adds a Page to the Book
  # @param opts [Hash] options to pass to the returned Page and/or it's Tab
  #
  # @option opts :label [String] the Tab label text
  # @option opts :icon [String] the url of the image
  # #option opts :closable [Boolean] true if a `close button` is to be displayed in the tab
  # 
  # @return [self]
  def append opts={}, &b
    label, icon, closable = opts[:label], opts[:icon], opts[:closable] ||= true
    pg = Page.new(opts)
    tab = Tab.new(:label=>label, :icon=>icon, :closable=>closable)

    header_widget.append_item tab
    
    add pg
    b.call pg,tab if b
    tab.select if n_pages() == 1
        
    return self
  end
  
  # The number of Pages
  # @return [Integer]
  def n_pages
    children.length
  end
  
  # !@method page(*val)
  # Set or Retrieve the current Page
  # @param val [Integer] pass to set the page, omit to revieve the current index
  # @return [self]
  
  # !@method page=(val)
  # Set the current page
  # @param val [Integer] the index to set
  # @return [Integer]
  
  # !@method set_page(val)
  # Set the current page
  # @param val [Integer] the index to set
  # @return [Integer]
  
  # !@method get_page()
  # Retrieve the current page index
  # @return [Integer]
  get_set_chain :page do
    proc do |t,k,val,*o|
      t == :set ? after(0.1) do header_widget.items[val].select end : header_widget.selection[0] 
    end
  end
  
  # Get the tab belonging to a page
  # @param q [Integer|Page] the index of a page or a Page
  # @return [Tab]
  def page_tab(q)
    if q.is_a?(Integer)
      return header_widget.items[q]
    end
    
    if q.is_a?(Page)
      idx = children.map do |c|
        c.element
      end.index(q.element)
      
      return header_widget.items[idx]
    end
    
    return nil
  end
  
  alias :get_n_pages :n_pages
  alias :get_page_tab :page_tab
  
  private :add
  private
  def header_widget
    @header ||= Header.wrap element.css(".pbr-opalui-notebook-header")[0]
  end  
end
