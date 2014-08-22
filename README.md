opal-ui
=======

GUI ToolKit inpsired by Gtk for use with opal and opal-browser

Example (Standard)
===
```ruby
include PBR::OpalUI

DefaultTheme.apply()

Window.new(size:[400,400]).

add(
  Accordian.new.
  
  append(label:"foo", icon:"http://google.com/favicon.ico") do |item|
    item.add TextView.new do |v|
      v.text("
      
      Sample Text
      
      ")
    end
  end.
  
  append(label:"bar") do |item|
    item.add(
      Frame.new(label:"Book Example").
      
      add(Notebook.new) do |nb|
        5.times do |i|
          nb.append(label:"Page #{i}") do |pg, t|
            pg.add TextView.new(text:"Page #{i} content")
          end
        end
        
        nb.page(2)
      end
    )
  end.
  
  item(1)
)

```
