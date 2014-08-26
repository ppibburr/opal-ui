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

      def sensitive *o
        result = super
        
        children do |c|
          c.events_enabled(*o)
        end
        
        return result
      end
      
      def events_enabled *o
        result = super
        
        children do |c|
          c.events_enabled(*o)
        end
        
        return result
      end      

      # Adds a child Widget
      #
      # @param w [Widget] the child to add
      # @return [Container] self
      def add w,&b
        w.element.append_to container_element
        
        if !sensitive() or !events_enabled()
          w.events_enabled(false)
        end
       
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
  end
end
