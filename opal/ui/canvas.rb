module UI
  # Wraps Browser::Canvas
  #
  #
  class Canvas < Widget
    register :name=>"canvas"
    
    attr_reader :element, :style, :text

    def initialize(tag="CANVAS", wrap=nil, init=nil)
      super tag,wrap,init
      
      if (wrap and init) or tag
        @canvas = Browser::Canvas.new(element)
      else
        raise "NotImplemented: wrap initialized CANVAS"
      end
      
      @text = @canvas.text
      @style = @canvas.style
    end

    def width
      @canvas.width
    end

    def height
      @canvas.height
    end

    def load(path)
      @canvas.load path
    end

    def data(x = nil, y = nil, width = nil, height = nil)
      @canvas.data x, y, width, height
    end

    def pattern(image, type = :repeat)
      @canvas.pattern image, type
    end

    def gradient(*args, &block)
      @canvas.gradient *args, &block
    end

    def clear(x = nil, y = nil, width = nil, height = nil)
      @canvas.clear x,y, width, height
    end

    def begin
      @canvas.begin
    end

    def close
      @canvas.close
      
      return self
    end

    def save
      @canvas.save
      
      return self
    end

    def restore
      @canvas.restore
      
      return self
    end

    def move_to(x, y)
      @canvas.move_to x,y
    end

    alias move move_to

    def line_to(x, y)
      @canvas.line_to x,y
    end

    def line(x1, y1, x2, y2)
      @canvas.line x1, y1, x2, y2
    end

    def rect(x, y, width, height)
      @canvas.rect x, y, widht, height 
      
      return self
    end

    def arc(x, y, radius, angle, clockwise = false)
      @canvas.arc x, y, radius, angle, clockwise
      
      return self
    end

    def quadratic_curve_to(cp1x, cp1y, x, y)
      @canva.quadratic_curve_to cp1x, cp1y, x, y
      
      return self    
    end

    def bezier_curve_to(cp1x, cp1y, cp2x, cp2y, x, y)
      @canvas.bezier_curve_to(cp1x, cp1y, cp2x, cp2y, x, y)
      
      return self
    end

    def curve_to(*args)
      @canvas.curve_to(*args)
      
      return self
    end

    def draw_image(image, *args)
      @canvas.draw_image(image, *args)
      
      return self
    end

    def translate(x, y, &block)
      @canvas.translate(x, y, &block)
     
      return self
    end

    def rotate(angle, &block)
      @canvas.rotate(angle, &block)
      
      return self
    end

    def scale(x, y, &block)
      @canvas.scale x, y, &block
      
      return self
    end

    def transform(m11, m12, m21, m22, dx, dy, &block)
      @canvas.transform(m11, m12, m21, m22, dx, dy, &block)
      
      return self
    end

    def path(&block)
      @canvas.path &block
      
      return self
    end

    def fill(&block)
      @canvas.fill &block
      
      return self
    end

    def stroke(&block)
      @canvas.stroke &block
      
      return self
    end

    def clip(&block)
      @canvas.clip &block
      
      return self
    end

    def point_in_path?(x, y)
      @canvas.point_in_path?(x, y)
    end

    def to_data(type = undefined)
      @canvas.to_data(type)
    end
  end
end
