-- luacheck: globals love

function love.conf(t)
  t.window.title = "EP2 - MAC0346"
  t.window.width = 1280
  t.window.height = 720

  t.modules.joystick = false
  t.modules.keyboard = false
  t.modules.physics = false
  t.modules.system = false
  t.modules.audio = false
  t.modules.mouse = false
  t.modules.sound = false
  t.modules.touch = false
  t.modules.video = false
end