module GetSetChain
  def get_set_chain *o , &b
    o.each do |k|
      delagate = nil
      handler  = nil
      
      if b
        q = instance_exec(k, &b)
        
        if q.is_a?(Proc)
          handler = q
        else
          if delagate.is_a?(Array)
            delagate = q.shift
          
          else
            delagate = q
            
            q = [k, :"#{k}="]
          end
        end
      end

      define_method :"get_#{k}" do
        if delagate
          next delagate.send(q[0])
        elsif handler
          next instance_exec(:get, k, &handler)
        else
          instance_variable_get("@#{k}")
        end
      end
      
      define_method :"set_#{k}" do |val|
        if delagate
          next delagate.send(q[1], val)
        elsif handler
          next instance_exec(:set, k, val, &handler)
        else
          instance_variable_set("@#{k}", val)
        end
        
        next true      
      end
      
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

class Widget
  module Interface
    def self.extended cls
      kls.send :extend, GetSetChain
    end
    
    def class_name
      @class_name ||= self.to_s.downcase.split("::").join("-")
    end
    
    def css &b
      CSS(&b).append_to $document.head
    end
  end

  extend Interface
  
  css do
    rule ".widget" do
      border: [1.px, :solid, :black]
    end
  end
  
  attr_reader :element
  def initialize
    @element = $document.create_element(self.class.tag_name.to_s.upcase)
    
    self.class.ancestors.find_all do |q| q.is_a?(Interface) end.reverse.each do |q|
      element.add_class q.class_name
    end
  end
  
  def self.tag_name
    self::TAG_NAME
  end
  
  def rener_icon src
    element.inner_html = ""
    img = Image.new(src)
    img.append_to element
    
    return img
  end
  
  def render_html html
    element.inner_html = html
  end
  
  get_set_chain :height, :width, :top, :left, :color do
    next element.style
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
end

class Label < Widget
  get_set_chain :text do
    [element, :inner_text, :"inner_text="]
  end
end


class Image < Widget
  get_set_chain :src do
    element
  end
end

class Container < Widget
  def add w
    w.element.append_to element
  end
end

class Bin < Container

end

class Frame < Bin

end

class Window < Bin

end

module Box
  include Widget::Interface
end

class VBox < Container
  include Box
end

class HBox < Container
  include Box
end

class Button < Bin
  include Activate
end

class List < Widget
  include Activate
end

class Entry < Widget
  include Activate
end

class TextView < Widget

end


Widget.new().element.append_to $document.body
