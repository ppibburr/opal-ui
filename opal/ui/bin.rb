module PBR
  module OpalUI
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
  end
end
