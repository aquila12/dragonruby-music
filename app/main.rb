require 'lib/button.rb'

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
