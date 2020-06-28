class Button
  def initialize(definition, &handler)
    @props = definition
    @colours = @props.slice(:line, :fill, :hover).transform_values { |c| hexcolour(c) }
    @rect = @props.slice(:x, :y, :w, :h)
    @hover = false
    @event = handler
  end

  def hexcolour(hex_string)
    raise unless hex_string.start_with? '#'

    hexes = hex_string[1..-1]

    channels = case hexes.length
    when 3, 4 then hexes.chars.map { |c| c.hex * 0x11 } + [0xff]
    when 6, 8 then hexes.each_slice(2) { |a| a.join.hex } + [0xff]
    else raise
    end

    # Possible extraneous channel is just ignored
    Hash[%i[r g b a].zip(channels)]
  rescue StandardError => e
    raise ArgumentError, "Unable to decode colour #{hex_string} : #{e.message}"
  end

  def backdrop
    @rect.merge @colours[@hover ? :hover : :fill]
  end

  def border
    @rect.merge @colours[:line]
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
