module PBR::UI::Opal
  extend PBR::UI::Backend
  
  ###
  def self.init
  end
    
  def self.main
  end
    
  def self.quit
  end
  ###
  
  class App < PBR::UI::App
    PBR::UI::Opal.register self
    def initialize opts={}
      screen = opts[:screen] ||= ::UI::Screen.create()

      super(opts)
      
      toplevel.native.append_to screen
    end
  
    def display

    end
    
    def on_run &b

    end

    # Create a [PBR::UI::Opal::ToggleButton]
    #
    # @param [Hash] opts options
    # @param [Proc] b when a block is passed App#build() is performed with this [Button] as 'root' container
    #
    # @return [PBR::UI::Opal::ToggleButton]      
    def toggle opts = {}, &b
      create_append_build :ToggleButton, opts, &b
    end
    
    def alert title = "", body=""
      alert body
    end
    
    def confirm title = "", body=""
      confirm body
    end
    
    def prompt title = "", body="", value=""
      prompt body, value
    end  
    
    def prompt_path opts={}
      raise "NotSupported"
    end
  end

  module Event
    def veto
      @veto = true
    end
    
    def stop
      @stop = true
    end
    
    def veto?
      !!@veto
    end
    
    def stop?
      !!@stop
    end
  end
  
  module EventClass
    def connect(widget, event, data = nil, &b)

    end
    
    def create widget, data, *o
      i=new(widget, data)    
    end
  end

  class GenericEvent < PBR::UI::GenericEvent
    include PBR::UI::Opal::Event
    extend  PBR::UI::Opal::EventClass  
  end
  
  class BookPageEvent < PBR::UI::GenericEvent
    include PBR::UI::Opal::Event
    extend  PBR::UI::Opal::EventClass  
    
    def self.create widget, data=nil, pg=nil, n=nil, *o
      new(widget, n)
    end      
  end

  class KeyEvent < PBR::UI::KeyEvent
    include PBR::UI::Opal::Event
    extend  PBR::UI::Opal::EventClass
    
    def initialize event, *o
      super(*o)
      
      @native = event
    end
    
    def state
      raise "NotImplemented"
    end
    
    def type
      raise "NotImplemented"
    end

    def keyval
      raise "NotImplemented"
    end
    
    def press?
      case type
      when PBR::UI::EventType::KEY_PRESS
        return true
      end
      
      return false
    end
    
    def release?
      case type
      when PBR::UI::EventType::KEY_RELEASE
        return true
      end
      
      return false
    end    
    
    def ctrl?
      raise "NotImplemented"
    end
    
    def alt?
      raise "NotImplemented"
    end
    
    def shift?
      raise "NotImplemented"
    end   
    
    def modifiers?
      state != 0
    end     
   
    def self.create widget, data=nil, *o
      raise "NotImplemented"
    end    
  end
  
  class MouseEvent < PBR::UI::MouseEvent
    include PBR::UI::Opal::Event
    extend  PBR::UI::Opal::EventClass
    
    attr_reader :native
    def initialize native, *o
      super *o
    
      @native = native
    end
    
    def type
      raise "NotImplemented"
    end
    
    def button
      raise "NotImplemented"
    end
    
    def x
      raise "NotImplemented"
    end
    
    def y
      raise "NotImplemented"
    end
    
    def self.create widget, data=nil, *o
      raise "NotImplemented"
    end             
  end

  class MotionEvent < PBR::UI::MotionEvent
    include PBR::UI::Opal::Event
    extend  PBR::UI::Opal::EventClass
    
    attr_reader :native
    def initialize native, *o
      super *o
    
      @native = native
    end
    
    def x
      raise "NotImplemented"
    end
    
    def y
      raise "NotImplemented"
    end
    
    def self.create widget, data=nil, *o
      raise "NotImplemented"
    end           
  end

  module Widget
    def self.included cls
      def cls.wrap native
        ins = allocate
        ins.instance_variable_set "@native", native
        return ins
      end
    end
    
    def sensitive?
      raise "NotImplemented"
    end
    
    def sensitive= bool
      raise "NotImplemented"
    end
  
    def tooltip= txt
      raise "NotImplemented"
    end
    
    def show
      raise "NotImplemented"
    end
    
    def show_all
      raise "NotImplemented"
    end
    
    def hide
      raise "NotImplemented"
    end
    
    def size
      raise "NotImplemented"
    end
    
    def on_key_up &b
      PBR::UI::Opal::KeyEvent.connect(self, "key-release-event", &b)
    end
    
    def on_key_down &b
      PBR::UI::Opal::KeyEvent.connect(self, "key-press-event", &b)
    end 
    
    def on_mouse_down &b
      PBR::UI::Opal::MouseEvent.connect(self, "button-press-event", &b)
    end
    
    def on_mouse_up &b
      PBR::UI::Opal::MouseEvent.connect(self, "button-release-event", &b)
    end
    
    def on_double_click &b
      raise "NotImplemented"
    end
    
    def on_motion &b
      raise "NotImplemented"
    end
    
    def on_focus &b
      raise "NotImplemented"
    end
    
    def on_blur &b
      raise "NotImplemented"
    end   
    
    def on_mouse_enter &b
      raise "NotImplemented"
    end
    
    def on_mouse_leave &b
      raise "NotImplemented"
    end
  end

  module Container
    def add widget
      widget.send :set_container, self
    
      native.add widget.native
    end
    
    def remove widget
      raise "NotImplemented: `Container#remove`"
    end
  end

  module Iconable
    def image *o
      if o.empty?
        return PBR::UI::Opal::Image.wrap(native.icon)
      end
      
      image().modify o[0]
    end  
  
    def icon_position= pos
      case pos
      when PBR::UI::IconLocation::RIGHT
        native.icon_pos=pos  
      when PBR::UI::IconLocation::LEFT
        native.icon_pos=pos
      else
        raise "Invalid icon_position: `#{pos}`"
      end    
    end
  end

  class Window < PBR::UI::Window
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
      
    define UI::Opal::Window
    
    def self.constructor wrapper, *o, &b
      ::UI::Window.new()
    end
    
    def pos_x= x
      native.pos_x = x
    end
    
    def pos_y= y
      native.pos_y = y
    end
    
    def position= *o
      native.position= *o
    end    
    
    def default_size= size
      self.size = size
    end
    
    def title= title
      native.title = title
    end
    
    def title
      native.title
    end
    
    def size
      raise "NotImplemented"
    end
    
    def size= size
      native.size = size
    end
    
    def on_delete &b
      PBR::UI::Opal::GenericEvent.connect self,"delete-event", &b
    end
  end
  
  module Box
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
          
    def add widget, expand=true, fill=true, pad=0
      native.pack_start widget.native, expand, fill, pad
    end
  end
  
  class Flow < PBR::UI::Flow
    include PBR::UI::Opal::Box
    
    def self.constructor wrapped, opts={},&b
      same_major_size = !!opts[:same_major_size]
      spacing         = opts[:spacing] ||= 0  
            
      ::UI::HBox.new #same_major_size, spacing
    end
  end
  
  module Rule
    include PBR::UI::Opal::Widget
  end
  
  class HRule < PBR::UI::HRule
    include Rule
    
    def self.constructor *o
      ::UI::HSeparator.new
    end
  end
  
  class VRule < PBR::UI::VRule
    include Rule
    
    def self.constructor *o
      ::UI::VSeparator.new
    end    
  end  
  
  module MenuShell
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container    
    
    def add widget
      raise "NotImplemented"
    end
    
    def item opts={} , &b
      raise "NotImplemented"
    end
  end
  
  class Menubar < PBR::UI::Menubar
    include PBR::UI::Opal::MenuShell
    
    def self.constructor *o
      ::UI::MenuBar.new
    end
    
    def item opts={}, &b
      raise "NotImplemented"
    end
  end
  
  class Menu < PBR::UI::Menu
    include PBR::UI::Opal::MenuShell
    
    def self.constructor *o
      m = ::UI::Menu.new
      m.set_reserve_toggle_size raise("NotImplemented")
      m
    end    
  end

  class MenuItem < PBR::UI::MenuItem
    include Widget
    include Container
  
    def self.constructor wrapper, opts, *o ,&b
      case opts[:type]
      when PBR::UI::MenuItemType::TEXT
        i=::UI::MenuItem.new
      when PBR::UI::MenuItemType::ICON
        i=::UI::MenuItem.new
      when PBR::UI::MenuItemType::CHECKED
        i=::UI::CheckMenuItem.new
      end
      
      raise "NotImplemented"
      
      i
    end
    
    def initialize opts={}
      @type = opts[:type] ||= PBR::UI::MenuItemType::TEXT
      
      super opts
      raise "NotImplemented"
    end
    
    def image *o
      raise "NotImplemented"
    end
    
    def checked= bool
      raise "NotImplemented"
    end
    
    def checked?
      raise "NotImplemented"
    end
    
    def label 
      raise "NotImplemented"
    end
    
    def label= txt
      raise "NotImplemented"
    end
    
    def add widget
      raise "NotImplemented"
    end
    
    def on_activate &b
      raise "NotImplemented"
    end
    
    def menu &b
      raise "NotImplemented"
    end
  end
   
  class Stack < PBR::UI::Stack
    include PBR::UI::Opal::Box
    
    def self.constructor wrapped, opts={},&b
      same_major_size = !!opts[:same_major_size]
      spacing         = opts[:spacing] ||= 0  
            
      ::UI::VBox.new # same_major_size, spacing
    end
  end  
  
  class Button < PBR::UI::Button
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
    
    def self.constructor *o
      n = ::UI::Button.new
    end
    
    def initialize opts={}
      label = opts.delete :label
      theme = opts.delete :theme
      
      super opts
      
      self.label = label if label
      raise "NotImplemented: Button#theme" if theme
    end
    
    include PBR::UI::Opal::Iconable
    
    def label
      native.label
    end
    
    def label= txt
      native.label = txt
    end
    
    def on_click &b
      PBR::UI::Opal::GenericEvent.connect(self, "clicked", &b)
    end
  end
  
  module PBR::UI::Opal::ListCtrl
    def select_next
      raise "NotImplemented"
    end
    
    def select i
      raise "NotImplemented"
    end
    
    def select_before
      raise "NotImplemented"    
    end
    
    def items= a
      a.map do |v|
        native.add v
      end
      
      a
    end    
    
    def selection
      raise "NotImplemented"
    end
    
    def on_item_activate &b
      @on_item_activate_cb = b
    end
    
    def on_item_selected &b
      @on_item_selected_cb = b
    end
    
    # @yieldparam idx [Integer] the index
    # @return [Array<Integer>] the indices
    def indices &b
      c = 0
      a = []
      
      native.send(:items).length.times do
        b.call(c) if b       
        a << c
        c+=1        
      end
      
      return a
    end        
  end
  
  class ListBox < PBR::UI::ListBox
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::ListCtrl
    
    def self.constructor *o
      ::UI::List.new
    end    
    
    # @yieldparam item [String] the label at +index+
    # @yieldparam index [Integer] the index
    #
    # @return [Array<String>] the items
    def items &b
      c = 0
      a = []
      
      native.send(:items).length.times do
        item = native.send(:item, c)
        b.call(item.label, c) if b        
        c+=1
        a << item.label
      end
      
      return a
    end
  end
  
  class ListView < PBR::UI::ListView
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::ListCtrl
    
    
    def self.constructor *o
      ::UI::List.new
    end    
    
    class Item
      attr_reader :native
      def label
        native.label
      end
      
      def label= txt
        native.label= txt
      end
    
      private
      def self.wrap n
        ins = self.new
        ins.instance_variable_set("@native", n)
        ins
      end
    end
    
    class TextItem < Item
    end
    
    class RadioItem < Item
      def value
        native.value
      end
      
      def value= bool
        native.value = bool
      end
    end

    def item(idx)
      n = native.item(idx)
      
      type = [:TextItem, :RadioItem, :Item].find do |t|
        n.is_a?(::UI::List.const_get(t))
      end
      
      w = self.class.const_get(type).wrap(n)    
    end
    
    def add val,*o
      l = [:TextItem, :RadioItem, :Item]
    
      if o[0] and o[0].is_a?(Hash) and ic=o[0][:item_class]
        idx=l.map do |k|
            PBR::UI::ListView.const_get(k)
        end.index(ic)
        
        if idx  
          o[0][:item_class] = ::UI::List.const_get(l[idx])
        end
      end
    
      item = native.add val,*o
      
      type = l.find do |t|
        item.is_a?(::UI::List.const_get(t))
      end
      
      w = self.class.const_get(type).wrap(item)      
    end
  
    def items &b
      indices.map do |i|
        n = native.item(i)
      
        type = [:TextItem, :RadioItem, :Item].find do |t|
          n.is_a? ::UI::List.const_get(t)
        end
      
        w = self.class.const_get(type).wrap(n)
      
        b.call(w,i) if b
      
        w
      end
    end
  end
  
  class Spinner < PBR::UI::Spinner
    include PBR::UI::Opal::Widget
    
    def self.constructor *o
      raise "NotImplemented"
    end
    
    def step= amt
      raise "NotImplemented"
    end
    
    def min= val
      raise "NotImplemented"
    end
    
    def max= val
      raise "NotImplemented"
    end    
    
    def min
      raise "NotImplemented"
    end
    
    def max
       raise "NotImplemented"
    end    
    
    def digits= amt
      raise "NotImplemented"
    end
    
    def digits
      raise "NotImplemented"
    end
    
    def value= val
      raise "NotImplemented"
    end
    
    def value
      raise "NotImplemented"
    end
    
    def on_change &b
      PBR::UI::Opal::GenericEvent.connect(self, 'value-changed', :value, &b)
    end
    
    def on_activate &b
      PBR::UI::Opal::GenericEvent.connect(self, 'activate', :value, &b)
    end
  end
  
  class ScrolledView < PBR::UI::ScrolledView
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
        
    def self.constructor *o
      ::UI::ScrolledWindow.new
    end
  end
  
  class Label < PBR::UI::Label
    include PBR::UI::Opal::Widget
    
    def self.constructor wrapped, opts={}, &b
      align = opts[:align] ||= :left
      
      n=::UI::Label.new
      n.align=align
      n
    end
    
    def align= pos
      native.align=pos
    end
    
    def text= txt
      native.text=txt
    end
    
    def text
      native.text
    end
  end  
  
  class Entry < PBR::UI::Entry
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Iconable
    
    def self.constructor wrapped, opts={}, &b
      ::UI::Entry.new
    end
    
    def initialize opts={}
      icon_pos = opts.delete(:icon_position)
      theme    = opts.delete(:theme)
      
      super
      
      if theme
        raise "NotImplemented: `Image#theme=`"
        icon_pos ||= PBR::UI::IconLocation::LEFT      
      else
      end
      
      modify :icon_position=>icon_pos if icon_pos
    end

    def text
      native.text
    end
    
    def text= txt
      native.text= txt
    end
    
    def on_activate &b
      PBR::UI::Opal::GenericEvent.connect(self, 'activate', :text, &b)
    end
  end
  
  class Toolbar < PBR::UI::Toolbar
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
  
    def self.constructor *o
      n = ::UI::Toolbar.new
      n
    end
    
    def add widget
      raise "NotImplemented"
    end
  end
  
  class ToolItem < PBR::UI::ToolItem
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
    
    def self.constructor *o
      ::UI::ToolItem.new()
    end    
  end

  class SeparatorToolItem < PBR::UI::SeparatorToolItem
    include PBR::UI::Opal::Widget
    
    def self.constructor *o
      n=::UI::SeparatorToolItem.new()
    end  
  end
  
  class ToolButton < PBR::UI::ToolButton
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
    
    def self.constructor *o
      n=::UI::ToolButton.new()
    end
    
    def initialize opts={}
      i_opts = {:size=>[24,24]}
      
      i_opts[:file]  = opts.delete(:file) if opts[:file]
      i_opts[:src]   = opts.delete(:src) if opts[:src]
      i_opts[:size]  = opts.delete(:size) if opts[:size]      
      i_opts[:theme] = opts.delete(:theme) if opts[:theme]   
      i_opts.delete(:size) if i_opts[:theme]
      
      super opts
      
      @image = PBR::UI::Opal::Image.new(i_opts)
      
      raise "NotImplemented"
    end
    
    def image o=nil
      unless o
        return @image
      end
      
      if o.is_a?(Hash)
        @image.modify(o)
      end
      
      return true
    end
    
    def label
      raise "NotImplemented"   
    end
    
    def label= txt
      raise "NotImplemented"
    end
    
    def on_click &b
      PBR::UI::Opal::GenericEvent.connect(self, 'clicked', &b)
    end
  end  
  
  def self.get_icon_theme widget
    name, size = raise "NotImplemented"
    prepend = case size
    when ::UI::IconSize::MENU
      PBR::UI::IconSize::MENU
    when ::UI::IconSize::BUTTON
      PBR::UI::IconSize::BUTTON
    when ::UI::IconSize::SMALL_TOOLBAR
      PBR::UI::IconSize::TOOLBAR
    when ::UI::IconSize::LARGE_TOOLBAR
      PBR::UI::IconSize::TOOLBAR_BIG
    when ::UI::IconSize::DIALOG
      PBR::UI::IconSize::LARGE                     
    end
    
    return prepend+"-"+name  
  end
  
  def self.icon_from_theme theme
    raw  = theme.split("-")
    size = raw.shift
    name = raw.join("-")
    
    native_size = case size
    when PBR::UI::IconSize::MENU
      ::UI::IconSize::MENU
    when PBR::UI::IconSize::LARGE
      ::UI::IconSize::DIALOG
    when PBR::UI::IconSize::TOOLBAR
      ::UI::IconSize::SMALL_TOOLBAR
    when PBR::UI::IconSize::TOOLBAR_BIG
      ::UI::IconSize::LARGE_TOOLBAR
    when PBR::UI::IconSize::BUTTON
      ::UI::IconSize::BUTTON                 
    end
    
    return name, native_size    
  end
  
  class Image < PBR::UI::Image
    include PBR::UI::Opal::Widget
    
    def self.constructor *o,&b
      ::UI::Image.new
    end
    
    def initialize opts={}
      o = opts
      opts = {}
      
      super opts
      
      unless o[:theme]
        raise "NotImplemented"
      else
        self.theme = o[:theme]
      end
      
      o.each_pair do |k,v|
        send :"#{k}=", v
      end
    end
    
    def theme
      PBR::UI::Opal::get_icon_theme self
    end
    
    def theme= theme
      name, size = PBR::UI::Opal::icon_from_theme(theme)
      raise "NotImplemented"
    end
    
    def src= src
      native.src = src
    end
    
    def file= file
      raise "NotImplemented"
      
      self
    end
    
    def size= size
      native.size=size
      size
    end
    
    def size
      raise "NotImplemented"
    end
    
    def width
      raise "NotImplemented"
    end
    
    def height
      raise "NotImplemented"
    end
    
    def height= h
      native.height=h
    end
    
    def width= w
      native.width = w
    end    
  end
  
  module Book
    include PBR::UI::Opal::Widget
    include PBR::UI::Opal::Container
      
    module Page
      include PBR::UI::Opal::Widget
      include PBR::UI::Opal::Container
        
      def self.included q
        def q.constructor wrapped, opts={}, &b
          raise "NotImplemented"
        end
      end
    end
    
    def self.included q
      def q.constructor *o,&b
        ::UI::Notebook.new
      end
    end
    
    def add widget
      pg = nice_child(widget)
      
      native.append_page(pg.native, pg.send(:get_tab))
      
      return pg
    end
    
    def page
      raise "NotImplemented"
    end
    
    def page= pg
      raise "NotImplemented"
    end
    
    def on_page_changed &b
      native.signal_connect('switch-page') do |pg,n,*o|
        evt = PBR::UI::Opal::GenericEvent.new self, n
        b.call evt
        
        if evt.veto?
          raise "NotImplemented"
          next false
        end
        
        next !!evt.stop?
      end
    end    
  end
  
  class Notebook < PBR::UI::Notebook
    include PBR::UI::Opal::Book
    
    class Page < PBR::UI::Notebook::Page
      include PBR::UI::Opal::Book::Page
    
      class Tab < PBR::UI::Opal::Flow
        attr_reader :label,:close,:image
        def initialize opts={}
          super
        end
      end
      
      def initialize book, opts={}
        l = opts[:label]
        opts.delete(:label)
        
        super book,opts
      end
      
      def label= txt

      end
      
      def image opts=nil

      end
    end 
  end
  
  class ComboBox < PBR::UI::ComboBox
    include PBR::UI::Opal::Widget
    
    def self.constructor wrapped, opts={}, &b
      ::UI::ComboBox.new
    end  
  end
  
  class TextView < PBR::UI::TextView
    include PBR::UI::Opal::Widget
  
    def self.constructor wrapper, *o
      ::UI::TextView.new
    end
    
    def initialize opts={}
      super(opts)
    end
    
    def text
      native.text
    end
    
    def text= txt
      native.text = txt
    end
    
    def undo
      cmd :undo
    end
    
    def redo
      cmd :redo
    end
    
    def font_size= size
      cmd :FontSize, size
    end
    
    def cut
      cmd :cut
    end
    
    def copy
      cmd :copy
    end
    
    def paste
      cmd :paste
    end
    
    def delete
      cmd :delete
    end    
    
    def bold
      cmd :bold 
    end
    
    def underline
      cmd :underline
    end
    
    def italic
      cmd :italic
    end
    
    def strikethrough
      cmd :strikethrough
    end
    
    def indent
      cmd :indent
    end
    
    def outdent
      cmd :outdent
    end
    
    def selection
      raise "NotImplemented"
      native.execute_script("t = document.getSelection(); document.getElementById('selection').innerText=t;")
      document.get_element_by_id('selection').get_inner_text
    end    
    
    def insert pos, txt
      raise "NotImplemented"
      set_caret pos
      code = "
function pasteHtmlAtCaret(html) {
    var sel, range;
    if (window.getSelection) {
        // IE9 and non-IE
        sel = window.getSelection();
        if (sel.getRangeAt && sel.rangeCount) {
            range = sel.getRangeAt(0);
            range.deleteContents();

            // Range.createContextualFragment() would be useful here but is
            // only relatively recently standardized and is not supported in
            // some browsers (IE9, for one)
            var el = document.createElement(\"div\");
            el.innerHTML = html;
            var frag = document.createDocumentFragment(), node, lastNode;
            while ( (node = el.firstChild) ) {
                lastNode = frag.appendChild(node);
            }
" + "
            range.insertNode(frag);

            // Preserve the selection
            if (lastNode) {
                range = range.cloneRange();
                range.setStartAfter(lastNode);
                range.collapse(true);
                sel.removeAllRanges();
                sel.addRange(range);
            }
        }
    } else if (document.selection && document.selection.type != \"Control\") {
        // IE < 9
        document.selection.createRange().pasteHTML(html);
    }
}
" + <<EOC
pasteHtmlAtCaret("#{txt}");
EOC

      native.execute_script code
    end
    
    def prepend txt
      insert 0, txt
    end
    
    def append_txt
    
    end
    
    def unmodified= bool
      raise "NotImplemented"
      if bool
        @_debounce = false
        @save = internal.get_inner_html
      end
    end
    
    def modified?
      check_modify
    end
    
    def src= src
      PBR::http_request src do |resp|
        self.text = resp.body
        source_loaded
      end
    end
  end
  
  class ToggleButton < PBR::UI::Widget
    include PBR::UI::Opal::Widget
    def self.constructor opts={}
      ::UI::ToggleButton.new
    end
    
    def on?
      native.on?
    end
    
    def off?
      native.off?
    end
  end
end
