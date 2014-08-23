module PBR
  module OpalUI
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
  end
end
