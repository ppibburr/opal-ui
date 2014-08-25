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
      
      rule "&:hover" do
        background "-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #e9e9e9), color-stop(1, #f9f9f9) );"      
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
  
  def sensitive(*o)
    result = super
    
    header_widget.sensitive(*o)
    
    return result
  end
  
  def events_enabled(*o)
    result = super
    
    header_widget.events_enabled(*o)
    
    return result
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
