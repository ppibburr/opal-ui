module PBR
  module OpalUI
    class Theme
      extend PBR::OpalUI::Styler
    end
  
    class DefaultTheme < Theme
      module Helper  
        def self.border defn, opts={}
          defn.border radius: opts.fetch(:radius,3.px)
          defn.border color: opts.fetch(:color, "#a9a9a9")
          defn.border style: opts.fetch(:style, :solid)
          defn.border width: opts.fetch(:width,1.px)
        end
      end
        
      style PBR::OpalUI::Window do
        Helper.border(self, color: "#B6A5A5")
        background color: "#D6D6CE"
        resize! :both  
      end
        
      style PBR::OpalUI::Frame do
        Helper.border(self)
        
        border top: 0

        
        rule ".pbr-opalui-frame-top-left" do
            Helper.border(self)
            border bottom: 0;
            border left: 0;
            border right: 0;
            border :"top-right-radius" => 0.px;
        end
        
        rule ".pbr-opalui-frame-top-right" do
            Helper.border(self)        
            border bottom: 0;
            border left: 0;
            border right: 0;
            border :"top-left-radius" => 0.px;            
        end        
        
        rule ".pbr-opalui-frame-inner" do

        end
      end
        
      style PBR::OpalUI::Entry do
        Helper.border(self)  
        padding left: 1.px
        background color: :white
      end
        
      style PBR::OpalUI::TextView do
        Helper.border(self)
        background color: :white  
      end
        
      style PBR::OpalUI::Label do
      
      end         

      style PBR::OpalUI::List::Cell do
        font family: :monospace
        padding left: 1.px
      end

      style PBR::OpalUI::List do    
        Helper.border(self)
        background color: :white

        rule ".pbr-opalui-item-selected" do
          background color: "#14839C"
          color :white
        end
        
        rule ".pbr-opalui-active-activated" do
          border [1.px, :dashed, :grey]
        end    
        
        rule ".pbr-opalui-list-cell:nth-child(odd)" do
          border bottom: [1.px, :solid, "#cecece"]
        end
        
        rule ".pbr-opalui-list-cell:nth-child(even)" do
          border bottom: [1.px, :solid, "#cecece"]
        end        
      end 
     
      style PBR::OpalUI::Widget do
        resize! :none
        color "#7A3333"
      end         
    end
  end
end
