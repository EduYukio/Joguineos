local path = "assets/audios/"
local a = love.audio

local unit_take_hit = a.newSource(path .. "unit_take_hit.wav", "static")
local fail = a.newSource(path .. "fail.wav", "static")
local unit_dying = a.newSource(path .. "unit_dying.wav", "static")
local select_menu = a.newSource(path .. "select_menu.wav", "static")
local cursor_menu = a.newSource(path .. "cursor_menu.wav", "static")
local buff = a.newSource(path .. "buff.wav", "static")
local debuff = a.newSource(path .. "debuff.wav", "static")

fail:setVolume(0.6)

return {
  unit_take_hit = unit_take_hit,
  fail = fail,
  unit_dying = unit_dying,
  select_menu = select_menu,
  cursor_menu = cursor_menu,
  buff = buff,
  debuff = debuff,
}