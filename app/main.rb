class Button
  def initialize(definition, &handler)
    @props = definition
    @hover = false
    @event = handler
  end

  def hexcolour(c)
    raise ArgumentError unless c.start_with? '#'
    color = c[1..-1]
    output = case color.length
    when 3 then color.chars.map { |c| c.to_i(16) * 0x11 }
    when 6 then color.chars.each_cons(2).map { |c| c.join.to_i(16) }
    else raise ArgumentError
    end

    Hash[%i[r g b].zip(output)]
  end

  def rect
    @props.select { |k,v| %i[x y w h].include? k }
  end

  def backdrop
    rect.merge hexcolour(@hover ? @props[:hover] : @props[:fill])
  end

  def border
    rect.merge hexcolour(@props[:line])
  end

  def label
    {
      x: @props[:x] + @props[:w] / 2,
      y: @props[:y] + @props[:h] / 2 + 10,
      text: @props[:text],
      alignment_enum: 1
    }
  end

  def mouse_over?(mouse)
    x = mouse.x - @props[:x]
    y = mouse.y - @props[:y]
    (0...@props[:w]).include?(x) && (0...@props[:h]).include?(y)
  end

  def update(source)
    @hover = mouse_over? source.mouse
    @event.call if source.mouse.click && mouse_over?(source.mouse.click)
  end

  def render(target)
    target.solids << backdrop
    target.borders << border
    target.labels << label
  end
end

def init_buttons(args)
  start = { x: 400, y: 370, w: 480, h: 150, text: "Start", line: '#000', fill: '#fff', hover: '#9f9' }
  stop = { x: 400, y: 200, w: 480, h: 150, text: "Stop", line: '#000', fill: '#fff', hover: '#f99' }

  [
    Button.new(start) { args.outputs.sounds << 'bgm/urban-sunrise.ogg' },
    Button.new(stop) { $gtk.stop_music }
  ]
end

def tick(args)
  @buttons ||= init_buttons(args)
  @buttons.each { |b| b.update(args.inputs) }

  args.outputs.labels << [640, 650, "If you want to start it, press START.", 0, 1]
  args.outputs.labels << [640, 620, "You can work out the rest of the controls for yourself.", 0, 1]
  @buttons.each { |b| b.render(args.outputs) }
end
