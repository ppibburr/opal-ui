opal-ui
=======

GUI ToolKit inpsired by Gtk for use with opal and opal-browser

Example (Standard)
===
```ruby
screen = UI::Screen.create.bg_image = "url(http://images4.alphacoders.com/214/214394.jpg)"

w = ::UI::Window.new
w.title = "Opal UI: demo"
w.append_to screen
w.add v = ::UI::VBox.new

v.pack_start ::UI::ToggleButton.new, false,false,0
v.pack_start ::UI::TextView.new, true, true, 0
v.pack_start h=::UI::HBox.new, false, false, 0

h.pack_start b1=::UI::Button.new, true,false,0
h.pack_start b2=::UI::Button.new, true,false,0
h.pack_start b3=::UI::Button.new, true,false,0

b1.label = "A Button"
b2.label = "A Button"
b3.label = "A Button"
```

Example: 'dsl' inspired from `shoes`
===
```ruby
::UI::Screen.create("body").app(:title => "Opal UI: demo.rb") do 
  stack do
    toggle(:expand => false, :fill => false)
    
    text(:name=>:text)

    entry(:expand => false,
          :fill => false).image.modify(:src=>"http://google.com/favicon.ico",
                                               :size=>[24,24])

    flow(:expand => false, :fill => false) do
      3.times do
        button(:label=>"A Button")
      end
    end
  end
end

```
