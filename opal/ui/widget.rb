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
      dispatch = proc do |k, cb|
        delagate = nil
        handler  = nil
        
        if cb
          q = instance_exec(k, &cb)
          
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
          delagate, handler, q = instance_exec(k, b, &dispatch)

          if delagate
            next delagate.send(q[0])
          elsif handler
            next instance_exec(:get, k, &handler)
          else
            instance_variable_get("@#{k}")
          end
        end
        
        define_method :"set_#{k}" do |val|
          delagate, handler, q = instance_exec(k, b, &dispatch)

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
      
      attr_reader :element
      def initialize options = {}
        @element = $document.create_element(self.class.tag_name.to_s.upcase)

        self.class.ancestors.find_all do |q| q.is_a?(Interface) end.reverse.each do |q|
          element.add_class q.class_name
        end
        
        init()
        
        apply(options)
      end
      
      # @return [String] the tag of the element to wrap
      def self.tag_name
        self::TAG_NAME
      end
      
      # Renders an Image
      #
      # @return [Image] the resulting Image
      def rener_icon src
        element.inner_html = ""
        img = Image.new(src)
        img.append_to element
        
        return img
      end
      
      # Sets the inner_html
      def render_html html
        element.inner_html = html
      end
      
      get_set_chain :height, :width, :top, :left, :color do
        next element.style
      end
      
      get_set_chain :tooltip do
        [element, :title, :"title="]
      end
      
      get_set_chain :size,:position do |k|
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
      def on e, &b
        element.on(e, &b)
      end
      
      # Removes an event listener
      #
      # @param what [Browser::DOM::Event::Callback] handler
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
