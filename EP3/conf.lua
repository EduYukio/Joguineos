-- luacheck: globals love

function love.conf(t)
  t.window.title = "EP3-Yukio-MAC0346"
  t.window.width = 1280
  t.window.height = 600

  t.modules.joystick = false
  t.modules.physics = false
  t.modules.system = false
  t.modules.mouse = false
  t.modules.audio = false
  t.modules.sound = false
  t.modules.touch = false
  t.modules.video = false
end