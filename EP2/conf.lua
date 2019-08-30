-- luacheck: globals love

function love.conf(t)
  t.window.width = 1350
  t.window.height = 720
  t.modules.joystick = false
  t.modules.physics = false
end