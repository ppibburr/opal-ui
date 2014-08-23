module PBR
  module OpalUI
    # A Clickable, Focusable, Activatable Widget
    class Button < Widget
      include Focus
      include Activate
      include Iconable
      include Widget::HasLabelProperty
      
      CONTENT_CLASS = Label
      
      css "
    .pbr-opalui-button {
      flex-flow:row nowrap;
      -webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
      background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #f9f9f9), color-stop(1, #e9e9e9) );
      background-color:#f9f9f9;
      overflow:hidden;
      -webkit-border-top-left-radius:6px;
      -webkit-border-top-right-radius:6px;
      -webkit-border-bottom-right-radius:6px;
      -webkit-border-bottom-left-radius:6px;
  ;
      text-indent:0;
      border:1px solid #B8B6B6;
      color:#666666;
      font-family:Arial;
      font-size:15px;
      font-style:normal;
      text-decoration:none;
      text-shadow:1px 1px 0px #ffffff;
      min-height:1.5em;
      padding:0.2em;
    }
    .pbr-opalui-button:hover {
      background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #e9e9e9), color-stop(1, #f9f9f9) );
      background-color:#e9e9e9;
    }.pbr-opalui-button:active {
      background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #d9d9d9), color-stop(1, #e9e9e9) );
      background-color:#e9e9e9;
    }    
    .pbr-opalui-button .pbr-opalui-iconable-icon {
      flex: 0 0 auto;      
    }    
    .pbr-opalui-button .pbr-opalui-iconable-content {
      align-self:center;
      flex: 0 0 auto;
      padding-left:3px;
      padding-right:3px;      
    }
    
    .pbr-opalui-button .pbr-opalui-iconable-content span {
          vertical-align:middle;
          display:table-cell;
    }  
    .pbr-opalui-button .pbr-opalui-iconable-icon-left {
      order: 1;
    }
    .pbr-opalui-button .pbr-opalui-iconable-icon-right {
      order: 2;     
    }  
    .pbr-opalui-button .pbr-opalui-iconable-content-left {
      order: 2;
    }
    .pbr-opalui-button .pbr-opalui-iconable-content-right {
      order: 1;
    }     
    .pbr-opalui-button .pbr-opalui-button-padding-left {
      order: 0;
      flex:1 1 auto;
    }
    .pbr-opalui-button .pbr-opalui-button-padding-right {
      order: 3;
      flex:1 1 auto;
    }
    "
    
      def label_widget
        content
      end
      
      def init
        super
        
        pad = $document.create_element "DIV"
        pad.append_to element
        pad.add_class "pbr-opalui-button-padding"
        pad.add_class "pbr-opalui-button-padding-left"         
        
        pad = $document.create_element "DIV"
        pad.append_to element
        pad.add_class "pbr-opalui-button-padding"   
        pad.add_class "pbr-opalui-button-padding-right"  
      end
    end

    # A List of Items
    class List < Container
      class Cell < Widget
        include Focus
        include Activate
        include Item
        include Widget::HasTextPropery
        
        css do
          rule ".pbr-opalui-list-cell" do
            flex "0 0 1em !important"
          end
        end
        
        private
        def on_activate &b
          super
        end
      end
      
      include HasItems
      
      css do
        rule ".pbr-opalui-list" do
          overflow :auto
        end
      end
      
      def init
        super
        
        element.on :keypress do |e|
          if (e.code == 38)
            select_pior()
            next false;
          elsif (e.code == 40)
            select_next()
          end
            
          next true;
        end
      end
      
      def items &b
        children &b
      end  
      
      def add opts
        if !opts.is_a?(Hash)
          opts = {value: opts}
        end
        
        super c=Cell.new(opts)
        append_item(c)
        
        self
      end
    end
    
    # A singleline editable text Widget
    class Entry < Widget
      include Focus
      include Activate
      include Iconable
      include Widget::HasTextPropery
      include Editable
    end

    # A multiline editable text Widget
    class TextView < Widget
      include Focus
      include Widget::HasTextPropery
      include Editable  
      include Widget::Scrollable
    end
  end
end
