module PBR
  # Skeleton for exposing a common, simple GUI interface
  module UI
    module BoxLayoutProperty
      FILL    = :fill
      EXPAND  = :expand
      PADDING = :padding
    end
    
    module WidgetWithIconProperty
      ICON_THEME    = :theme
      ICON_POSITION = :icon_position
    end
    
    module IconLocation
      RIGHT  = :right
      LEFT   = :left
      TOP    = :top
      BOTTOM = :bottom
    end
    
    module KeyEventType
      PRESS   = :press
      RELEASE = :release
    end
    
    class GenericEvent
      def initialize widget, data = nil
        @widget = widget
        @data   = data
      end
      
      def data
        @data
      end
      
      # Prevent default handlers
      #
      #
      def veto
      
      end
      
      # Prevent propagation
      #
      #
      def stop
      
      end
    end
    
    class KeyEvent < GenericEvent
      def data
        keyval
      end
    
      # @return [Integer]
      def keyval
      end
      
      # @return [Symbol] :key_press or :key_release
      def type
      end
      
      # @return [Integer] mask of modifiers present
      def state
      end
      
      # @return [Boolean] true if the Ctrl key is pressed
      def ctrl?
      end
      
      # @return [Boolean] true if the Shift key is pressed      
      def shift?
      end
      
      # @return [Boolean] true if the Alt key is pressed      
      def alt?
      end
    end    
    
    class MouseEvent < GenericEvent
      def button
      end
      
      def type
      end
      
      def data
        [x,y]
      end
      
      def x
      end
      
      def y
      end
    end
    
    class MotionEvent < GenericEvent
      def data
        [x,y]
      end
    
      def x
      end
      
      def y
      end
    end    
    
    module MenuItemType
      TEXT    = :text
      ICON    = :icon
      CHECKED = :check
    end    
    
    module IconSize
      MENU        = 'menu'
      BUTTON      = 'button'
      TOOLBAR     = 'toolbar'
      TOOLBAR_BIG = 'toolbar_big'
      LARGE       = 'large'
    end
    
    module ChoosePathAction
      OPEN          = :open
      SAVE          = :save
      FOLDER        = :folder
    end    
  
    # Implemented by a 'frontend'
    module Backend
      def register app
        app.define({:backend => self})     
      end
      
      # Initializes the backend library: ie, Gtk::init()
      def init
      
      end
      
      # Runs the Backend's 'main loop': ie, Gtk::main
      def main

      end
      
      # Exits the Backend's 'main loop': ie, Gtk::main_quit
      def quit

      end
    end
    
    class App
      def self.define config = {}
        @config = config
      end
      
      def self.backend
        @config[:backend]
      end
      
      def self.config
        @config
      end
      
      def self.inherited cls
        cls.singleton_class.define_method :inherited do |c|
          c.define cls.config 
        end
      end
    
      attr_reader :toplevel
      def initialize opts = {}
        opts[:toplevel] ||= :window
        
        raise "`:toplevel` option must be `Symbol`" unless opts[:toplevel].is_a?(Symbol)
        raise "Invalid value: #{opts[:toplevel]}; for option: :toplevel" unless respond_to?(opts[:toplevel]) 
        
        @toplevel = send(opts[:toplevel], opts)
        
        toplevel.on_delete do
          !at_exit()
        end
      end

      private
      
      def at_exit
        if !@on_quit_cb or !@on_quit_cb.call()
          self.class.backend.quit
        
          # never reaches here
          return true
        end
        
        return false
      end
    
      def append_widget widget, opts = {}
        if @build_mode
          if ivar = opts.delete(:id)
            instance_variable_set("@#{ivar}", widget)
          end
        end
      
        if opts[:scrolled]
          old  = widget
          
          q_opts = {:expand=>opts[:expand], :fill=>opts[:fill], :padding=>opts[:padding]}
          
          opts.delete(:expand)
          opts.delete(:fill)
          opts.delete(:padding)
          
          widget = scrolled(q_opts)
          widget.add old
          
          
          
          if @build_mode
            return
          end
        end      
      
        if @build_mode          
          if opts[:center]
            old  = widget
            
            q_opts = {:expand=>opts[:expand], :fill=>opts[:fill], :padding=>opts[:padding]}
            
            opts.delete(:expand)
            opts.delete(:fill)
            opts.delete(:padding)
            
            
            if @buildee.is_a?(PBR::UI::Stack)
              widget = flow(q_opts)
            end
            
            if @buildee.is_a?(PBR::UI::Flow)
              widget = stack(q_opts)
            end            
            
            build widget do
              append_widget(old, {:expand=>true, :fill=>false})             
            end
            
            if @build_mode
              return
            end
          end
        
          if @buildee.is_a?(PBR::UI::Box)
            layout = [opts[:expand] == nil ? true : !!opts[:expand], opts[:fill] == nil ? true : !!opts[:fill], opts[:padding] == nil ? 0 : opts[:padding]]
            @buildee.add widget, *layout
          else
            @buildee.add widget
          end
        end
      end      
      
      def widgets
        @widgets ||= {}
      end
      
      def create_widget type, opts = {}
        @last = widget = self.class.backend::const_get(type).new(opts) 
        
        if opts[:name]
          widgets[opts[:name]] = widget
        end
        
        widget.send :set_application, self
        
        return widget     
      end
      
      def create_append type, opts={}
        widget = create_widget(type, opts)
        
        append_widget(widget, opts)
        
        return widget
      end
      
      def create_append_build type, opts={}, &b
        widget = create_append(type, opts)
        
        if b
          build(widget, &b)
        end
        
        return widget   
      end
      
      public
      
      def last
        @last
      end
      
      def this
        @buildee
      end
      
      # Quits the 'main' loop.
      def quit
        self.class.backend.quit
      end
      
      # Allows for 'Builder' style
      #
      # @param [Container] buildee the current container being appended to, defaults to 'toplevel'
      # @param b [Proc]  instance_exec(&b) is performed
      #
      # @return [::Object] the result of performing +b+
      def build buildee = toplevel, &b
        pm                = @build_mode
        @build_mode       = true
        pb                = @buildee
        @buildee          = buildee
        
        r = instance_exec @buildee,&b
      
        @build_mode = pm
        @buildee    = pb
      
        return r
      end
      
      # Adds a listener to perform when the user attempts to exit the application
      #
      # @yieldreturn [Boolean] true to prevent exiting, false to allow
      def on_quit &b
        @on_quit_cb = b
      end
    
      # Create a [Window]
      #
      # @param [Hash] opts options, where options maybe any property name and its value
      # @param [Proc] b when a block is passed App#build() is performed with this [Window] as 'root' container
      #
      # @return [PBR::UI::Window]
      def window opts = {}, &b
        create_append_build :Window, opts, &b
      end
      
      # Create a [PBR::UI::Button]
      #
      # @param [Hash] opts options, where options maybe any property name and its value as well as any PBR::UI::WidgetWithIconProperty
      # @param [Proc] b when a block is passed App#build() is performed with this [Button] as 'root' container
      #
      # @return [PBR::UI::Button]      
      def button opts = {}, &b
        create_append_build :Button, opts, &b
      end

      # Create a [Notebook]
      #
      # @param [Hash] opts options, where options maybe any property name and its value
      # @param [Proc] b when a block is passed App#build() is performed with this [Notebook] as 'root' container
      #
      # @return [PBR::UI::Notebook]      
      def notebook opts={}, &b
        create_append_build :Notebook, opts, &b
      end
      
      # Create the proper descendant of [PBR::UI::Book::Page] for the [Book] type
      #
      # @param [Hash] opts options, where options maybe any property name and its value
      # @param [Proc] b when a block is passed App#build() is performed with this [PBR::UI::Book::Page] as 'root' container
      #
      # @return [PBR::UI::Book::Page]      
      def page opts={}, &b
        type = nil
        
        if @buildee.is_a?(PBR::UI::Book)
          type = @buildee.class
        else
          type = opts[:type]
        end
        
        raise "No Page Type resolved!" unless type
      
        book = @buildee.is_a?(PBR::UI::Book) ? @buildee : opts[:book]
      
        flw = type::Page.new(book, opts)
        
        append_widget(flw, opts)
        
        if b
          build(flw, &b)
        end
        
        flw
      end      
      
      # Create a [Flow]
      #
      # @param [Hash] opts options, where options maybe any property name and its value
      # @param [Proc] b when a block is passed App#build() is performed with this [Flow] as 'root' container, as well, widget creation methods accept any PBR::UI::BoxLayoutProperty
      #
      # @return [PBR::UI::Flow]      
      def flow opts={}, &b
        create_append_build :Flow, opts, &b
      end
      
      # Create a [Stack]
      #
      # @param [Hash] opts options, where options maybe any property name and its value
      # @param [Proc] b when a block is passed App#build() is performed with this [Stack] as 'root' container
      #
      # @return [PBR::UI::Stack]       
      def stack opts={}, &b
        create_append_build :Stack, opts, &b
      end   
      
      # Create a ScrolledView
      #
      # @return [PBR::UI::ScrolledView]
      def scrolled opts={}, &b
        create_append_build :ScrolledView, opts, &b
      end         
      
      # Creates a Menubar
      #
      # @return [PBR::UI::Menubar]
      def menubar opts={}, &b
        create_append_build :Menubar, opts, &b
      end      
      
      # Create a MenuItem
      #
      # @param [Hash] opts options, where options maybe any property name and its value as well as any PBR::UI::WidgetWithIconProperty
      #
      # @return [PBR::UI::MenuItem]
      def menu_item opts={}, &b
        create_append_build :MenuItem, opts, &b
      end 
      
      # Create a Menu
      #
      # @return [PBR::UI::Menu]
      def menu opts={}, &b
        create_append_build :Menu, opts, &b
      end           
      
      # Create a Toolbar
      #
      # @return [PBR::UI::Toolbar]
      def toolbar opts={}, &b
        create_append_build :Toolbar, opts, &b
      end       
      
      # Create a ToolItem
      #
      # @param [Hash] opts options, where options maybe any property name and its value as well as any PBR::UI::WidgetWithIconProperty
      #
      # @return [PBR::UI::ToolItem]
      def tool_item opts={}, &b
        create_append_build :ToolItem, opts, &b
      end       
         
      # Create a ToolButton
      #
      # @return [PBR::UI::ToolButton]
      def tool_button opts={}, &b
        create_append_build :ToolButton, opts, &b
      end       
         
      # Create a SeparatorToolItem
      #
      # @return [PBR::UI::SeparatorToolItem]               
      def tool_separator opts={}, &b
        create_append :SeparatorToolItem, opts
      end      
      
      
      def html opts={}, &b
        create_append :HtmlView, opts
      end
      
      # TODO: Gtk specific
      def web_view opts={}, &b
        create_append :WebView, opts
      end
      
      # Create a Entry widget
      #
      # @param [Hash] opts options, where options maybe any property name and its value as well as any PBR::UI::WidgetWithIconProperty
      #
      # @return [PBR::UI::Entry]
      def entry opts={}, &b
        create_append :Entry, opts
      end 
      
      # Creates a widget rendering an image on screen
      #
      # @param [Hash] opts options, where options maybe any property name and its value as well as PBR::UI::WidgetWithIconProperty::THEME
      #
      # @return [PBR::UI::Image]
      def image opts={}, &b
        create_append :Image, opts
      end 
      
      def hrule opts={}, &b
        create_append :HRule, opts
      end  
      
      def vrule opts={}, &b
        create_append :VRule, opts
      end              
      
      # Creates a Spinner
      #
      # @return [PBR::UI::Spinner]
      def spinner opts={}, &b
        create_append :Spinner, opts
      end       
      
      # Creates a ListBox
      #
      # @return [PBR::UI::ListBox]
      def list_box opts={}, &b
        create_append :ListBox, opts
      end 
      
      # Creates a ListView
      #
      # @return [PBR::UI::ListView]
      def list_view opts={}, &b
        create_append :ListView, opts
      end       
      
      # Creates a TextView
      #
      # @return [PBR::UI::TextView]
      def text opts={}, &b
        create_append :TextView, opts
      end             
      
      # Create a Label
      #
      # @return [PBR::UI::Label]
      def label opts={}, &b
        create_append :Label, opts
      end                                
      
      # Display the main window
      def display
        
      end
      
      # @return [void]
      def alert title="", body="", value="" 
      end       
      
      # @return [Boolean]
      def confirm title="", body=""
      end       
      
      # @return [String] or nil
      def prompt title="", body="", value="" 
      end 
      
      # A 'FileChooser' Dialog
      #
      # @param [Hash] opts
      #
      # @option opts [Symbol] :type A member of PBR::UI::ChoosePathAction
      # @option opts [String] :title The Dialog's title
      # @option opts [Symbol] :path Specify a default path
      # @option opts [Symbol] :name Suggest a filename when +type+ is PBR::UI::ChoosePathAction::SAVE
      # @option opts [Symbol] :folder Set the current folder                        
      #
      # @return [String] the path or nil if cancelled
      def prompt_path opts={:type=>:open}
      end    
    
      # Called around the time of 'main'
      def on_run &b
      
      end
    
      # Setup an [App] and call +b+ then run the application
      #
      # @param [String] title the application's main [Window]'s title
      # @param [Hash] opts options, where options may be any of [Window]'s properties with values
      #
      # @yieldparam [App] self
      def self.run(opts = {}, &b)
        backend.init
        
        ins = new(opts)
        b.call(ins)
        ins.display
        
        backend.main
      end
    end
  
    # UI entry class
    class Widget   
      def self.native_class
        @native_class
      end
    
      def self.define native_class, config = {:constructor => :new, :defaults => {}}
        setup native_class, config
      end
      
      def self.setup native_class, config
        @native_class = native_class
        @config = config
      end
      
      attr_reader :native
      
      # @param [Hash] opts where an option may be any setter method, ie, 'tooltip=' would be :tooltip=>'value' 
      def initialize opts={},&b
        @native = self.class.constructor(self,opts,&b)
        
        modify opts
      end
      
      # Modify's widgets properties from values in +opts+
      #
      # @param opts [Hash] options
      # @return [PBR::UI::Widget] self
      def modify opts={}
        opts.each_key do |k|
          if (k.to_s.split("_")[0] == "on") and !respond_to?(:"#{k}=")
            send k do |*o|
              @_application.send opts[k], *o
            end
            next
          end
          
          send :"#{k}=", opts[k] if respond_to?(:"#{k}=")
        end
        
        return self
      end
      
      def sensitive= bool
      end
      
      def sensitive?
      end
      
      # Sets the text to display after the user hovers the mouse over for a length of time
      #
      # @param txt [String] the text to display
      def tooltip= txt
        
      end
      
      # Displays the widget
      def show

      end
      
      # Displays the widget and all its descendants
      def show_all
      
      end
      
      # Hides the widget
      def hide
      
      end
      
      # @return [Array<Integer>] representing [width, height] repsectively
      def size
      
      end
      
      # @param b [Proc] the callback to call on key-press
      #
      # @yieldparam [PBR::UI::KeyEvent] e
      #
      # @yieldreturn [Boolean] true to prevent continuation, otherwise false      
      def on_key_down &b
      
      end
      
      # @param b [Proc] the callback to call on key-release
      #
      # @yieldparam [PBR::UI::KeyEvent] e
      #
      # @yieldreturn [Boolean] true to prevent continuation, otherwise false
      def on_key_up &b
      
      end
     
      # Called when a mouse button is pressed on a widget
      #
      # @yieldparam [PBR::UI::MouseEvent] e an event object      
      def on_mouse_down &b
      
      end
      
      # Called when a mouse button is released on a widget
      #
      # @yieldparam [PBR::UI::MouseEvent] e an event object
      def on_mouse_up &b
      
      end
      
      # @yieldparam [PBR::UI::MouseEvent] e an event object      
      def on_double_click &b
      end
      
      # Called when the mouse moves in a widgets region
      #
      # @yieldparam [PBR::UI::MotionEvent] e an event object
      def on_motion &b
      
      end
      
      # Callback for when a widget gains focus
      #
      # @param b [Proc] the callback to call on focus      
      def on_focus &b
      
      end
      
      # Callback for when a widget looses focus
      #
      # @param b [Proc] the callback to call on blur
      def on_blur &b
      
      end
      
      def on_mouse_enter &b
      end
      
      def on_mouse_leave &b
      end
          
      # Creates the underlying native 'widget'      
      def self.constructor wrapper, *o, &b
      
      end
      
      # @return [PBR::UI::Container] containing the widget
      def container
        @_container
      end
      
      private
      def set_container container
        @_container = container
      end
      
      def set_application app
        @_application = app
      end
    end
    
    module Container
      # Add a widget to a [Container]
      #
      # @param widget [PBR::UI::Widget]
      def add widget
        widget.send :set_container, self
      end
      
      # Remove a widget from a [Container]
      #
      # @param widget [PBR::UI::Widget]      
      def remove widget
      
      end
    end
    
    # Toplevel Window which may contain other widgets
    class Window < Widget
      include Container
      
      def initialize opts={},&b
        super
        if opts[:size]
          self.default_size = opts[:size]
        end
      end
    
      # The size the [Window] should initialy be
      #
      # @param [Array<Integer>] size the size, [width, height]
      def default_size= size 
      
      end
    
      # Sets the [Window]'s title
      #
      # @param [String] title
      def title= title
        
      end
      
      # @return [String] the title
      def title
      
      end
      
      # Resize the window
      #
      # @param [Array<Integer>] size [width, height]
      def size= size

      end      
      
      # Adds a handler for when the user attempts to exit the window
      #
      # @yieldreturn [Boolean] true to prevent exiting, false to allow
      def on_delete &b
      
      end
    end
    
    class Button < PBR::UI::Widget
      # @return [String] the label text    
      def label
      
      end
      
      # Sets the [Button]'s label
      #
      # @param [String] txt the label text
      def label= txt
        
      end
      
      # Adds a handler for 'click' events
      def on_click &b
      
      end
    end
    
    # Base class of BoxLayout Container's.
    class Box < Widget
      include Container
      
      # Adds a [Widget]
      #
      # @param [Widget] widget the [Widget] to add
      # @param [Boolean] expand when true the widget can react to the +fill+ parameter
      # @param [Boolean] fill when true, if expand is true, then the widget will grow to fill the allotted space. When false, the widget will center in the allotted space
      # @param [Integer] pad the amount of padding to place ahead and after the widget
      def add widget, expand=true, fill=true, pad = 0
        
      end
    end
    
    # A Box that will layout it's children horizontally. The X-axis shall be refered to as the major-axis
    class Flow < PBR::UI::Box
    end
    
    # A Box that will layout it's children vertically. The Y-axis shall be refered to as the major-axis    
    class Stack < PBR::UI::Box
    end 
    
    
    # A Widget that displays a string of text
    class Label < Widget
      # The current text value
      #
      # @return [String]
      def text
      
      end
      
      # Set the text to display
      #
      # @param txt [String]
      def text= txt
      
      end
    end
    
    # A Widget that renders a list of items
    class ListBox < Widget
      # @param a [Array<String>] the items to display
      def items= a
      
      end
      
      # @yieldparam item [String] the label at +index+
      # @yieldparam index [Integer] the index
      #
      # @return [Array<String>] the items
      def items &b
      end
      
      # @yieldparam idx [Integer] the index
      # @return [Array<Integr>] the indices
      def indices &b
      end
      
      # @return [Integer] the current selection
      def selection
      end
      
      # Sets the selected item
      #
      # @param i [Integer] the item to select
      def select i
      end
   
      # Activates an item
      #
      # @param i [Integer] the item to activate
      def select i
      end      
      
      # Select the next item
      def select_next; end
      
      # Select the previous item
      def select_before; end
      
      # Callback for when an item is activated
      def on_item_activate &b; end
      
      # Callback for when an item is selected
      def on_item_selected &b; end
    end
    
    class ListView < ListBox
      class Item
        attr_reader :native
        
        def label
        end
        
        def label= txt
        end
      end
      
      class TextItem < Item
      end
      
      class RadioItem < Item
        def value
        end
        
        def value= bool
        end
      end
    
      def item(idx)   
      end
      
      def add val,*o     
      end
    
      def items &b
      end
    end
    
    class ComboBox < Widget
      def choices= v
        @choices = v
      end
      
      def choices
        @choices
      end
      
      def value
        
      end
      
      def value= i
        
      end
    end
    
    # A Widget the allows numeric input via keyboard as well as the mouse
    class Spinner < Widget
      # @return [Float] the value
      def value; end
      
      # Sets the +value+
      #
      # @param val [Float] the value to set. Must be between #min and #max
      def value= val; end
      
      # @return [Float] the minimum value
      def min; end
      
      # @return [Float] the maximum value
      def max; end
      
      def min= min; end
      def max= max; end
      
      # @return [Float]
      def step; end
      
      # @param amt [Float] the amount to increment by when the adjustment arrows are pressed
      def step= amt; end
      
      def digits; end
      
      # @param digits [Integer] the amount of decimal places
      def digits= amt; end
      
      # Set the callback for when value-changed
      #
      # @yieldparam v [Float] the value
      def on_change &b 
      end
    end
    
    class Rule < Widget;
    end
    
    # A Widget displaying a horizontal line
    class HRule < Rule
    end
    
    # A Widget displaying a vertical line    
    class VRule < Rule
    end
    
    class Scale < Widget
    end
    
    class HScale < Scale
    end
    
    class VScale < Scale
    end
    
    class Toolbar < Widget
      include Container
    end
    
    class ToolItem < Widget
      include Container
    end
    
    class SeparatorToolItem < ToolItem    
    end
    
    class ToolButton < ToolItem
      # Retrieve the image widget
      #
      # @return [PBR::UI::Image]
      def image
      
      end
      
      # @return [String] the label text
      def label
      
      end
      
      # Sets the label text
      # @param txt [String]
      def label= txt; end
      
      def on_click &b
      
      end
    end
    
    module MenuShell
      include Container
      
      # @param [Hash] opts
      #
      # @option opts [Symbol] :type Member of PBR::UI::MenuItemType
      # @option opts [String] :label The item text
      # @option opts [String] :theme The item icon
      # 
      # @yieldparam [PBR::UI::Widget] widget
      #
      # @return [PBR::UI::MenuItem]
      def item opt={}, &b
      
      end    
    end
    
    # A Menubar
    class Menubar < Widget
      include MenuShell
    end
    
    # A Menu
    class Menu < Widget
      include MenuShell   
    end
    
    # A MenuItem
    class MenuItem < Widget
      include Container
      
      def checked?; end
      def checked= bool; end
      def image *o; end
      
      # @return [PBR::UI::Menu]
      def menu &b
      end
      
      # @param txt [String] the label
      def label= txt
      end
      
      def label
      end
      
      # Callback for when the item is activated
      #
      #
      def on_activate &b
      end
    end
    
    # A widget the allows a single-line of editable text
    class Entry < Widget
      # Sets the text value
      #
      # @param txt [String]
      def text= txt
      
      end
      
      # @return [String] the text value
      def text
      
      end
     
      # @param b [Proc] called when the user presses the enter key
      def on_activate &b
      
      end
    end
    
    class Frame < Widget
      include Container
    end
    
    # A Widget the allows for scrolling of its child
    class ScrolledView < Widget
      include Container
    end
    
    class TextView < Widget
      def text
      
      end
      
      def text= txt
      
      end
      
      def src= src
    
      end
      
      def undo
      
      end
      
      def redo
      
      end
      
      def cut
      
      end
      
      def copy
      
      end
      
      def paste
      
      end
      
      def delete
      
      end    
      
      def bold
      
      end
      
      def underline
      
      end
      
      def italic
      
      end
      
      def strikethrough
      
      end
      
      def indent
      
      end
      
      def outdent
      
      end
      
      def unmodified= bool
      end
    
      def modified?
      end      
    
      def on_modify &b
        @on_modify_cb = b
      end
      
      def on_unmodify &b
        @on_unmodify_cb = b
      end      
      
      def on_toggle_modify &b
        @on_toggle_modify_cb = b
      end
      
      def on_source_load &b
        @source_loaded_cb = b
      end
      
      private
      def source_loaded
        @source_loaded_cb.call(self) if @source_loaded_cb
      end
      
      def unmodified
        evt = PBR::UI::Gtk::GenericEvent.new(self)
      
        cb = @on_toggle_modify_cb
        cb.call(evt) if cb      
      
        cb = @on_unmodify_cb
        cb.call(evt) if cb
      end      
      
      def modified
        evt = PBR::UI::Gtk::GenericEvent.new(self)
              
        cb = @on_toggle_modify_cb
        cb.call(evt) if cb      
      
        cb = @on_modify_cb
        cb.call(evt) if cb
      end
    end
    
    # Widget rendering a image to the screen
    class Image < Widget
      def src
        @src
      end
      
      def theme= theme
      end
      
      def theme
      end
      
      def file
        @file
      end
    
      # Sets the contents from a URI
      #
      # @param src [String] an URI
      def src= src
        @file = nil
        @src  = src
      end
      
      # Sets the contents from a path
      #
      # @param file [String] the path
      def file= file
        @src  = nil
        @file = file
      end
      
      # @param size [Array<Integer>] [width, height]
      def size= size
      
      end
      
      # @return [Array<Integer>] [width, height]
      def size
        
      end
      
      # @return [Integer] the width
      def width
        size[0]
      end
      
      # @return [Integer] the height    
      def height
        size[1]
      end
      
      # Sets the height
      #
      # @param h [Integer]
      def height= h
        size= [width, h]
      end
      
      # Sets the width
      #
      # @param w [Integer]
      def width= w
        size= [w, height]
      end     
      
      def on_source_load &b
        @on_src_load_cb = b
      end
      
      private
      def source_loaded
        if cb=@init_src_cb
          cb.call(self)
          
          @init_src_cb = nil
        end
      
        if cb=@on_src_load_cb
          cb.call(self)
        end
      end
    end
    
    # A Widget that allows paging of multiple views
    class Book < Widget
      include Container
      
      # A page of a Book
      class Page < Widget
        include Container
        
        attr_reader :book
        def initialize book, opts={}
          @book = book
          super opts
        end
      end
      
      # The current page
      def page; end
      
      # sets the current page to display
      def page= i;end
      
      # @param b [Proc] Callback called when page has changed
      def on_page_changed &b
      
      end
      
      # @param b [Proc] Callback called when user has attempted to close the page
      # 
      # @yieldreturn [Boolean] true to prevent closing, false otherwise    
      def on_close &b
        @on_close_cb = b
      end
      
      private
      
      def nice_child widget
        unless widget.is_a?(self.class::Page)
          pg = self.class::Page.new(self)
          pg.add widget
      
        else
          pg = widget
        end  
        
        return pg    
      end
      
      def closed_button_pressed pg
        if cb=@on_close_cb
          unless cb.call(pg)
            remove(pg)
          end
        else
          remove(pg)
        end
      end  
    end
    
    # A Book implementation where a row of 'tabs' allow the user to select the page to display
    class Notebook < Book
      class Page < Book::Page
        # Sets the 'tab' label
        #
        # @param txt [String] the label
        def label= txt; end
        
        # @return [String] the label
        def label; end
        
        # @param opts [Hash, nil] when hash, image#modify(opts) is performed
        #
        # @return [::Object] a PBR::UI::Image when no value is passed
        def image opts=nil
        
        end
      end
    end
    
    class Canvas < Widget
    end
    
    # A Widget that renders HTML code
    class HtmlView < Widget
      # @param html [String] html code
      def load html
      end
      
      # @param html [String] html code      
      def html= html
      end
    end
    
    class WebView < Widget
      
    end
  end
end
