module PBR
  module OpalUI
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
  end
end
