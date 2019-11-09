local path = "assets/audios/"
local a = love.audio

local buy_upgrade = a.newSource(path .. "buy_upgrade.wav", "static")
local castle_take_hit = a.newSource(path .. "castle_take_hit.wav", "static")
local fail = a.newSource(path .. "fail.wav", "static")
local generate_gold = a.newSource(path .. "generate_gold.wav", "static")
local monster_dying = a.newSource(path .. "monster_dying.wav", "static")
local select_menu = a.newSource(path .. "select_menu.wav", "static")

fail:setVolume(0.6)
generate_gold:setVolume(0.4)

return {
  buy_upgrade = buy_upgrade,
  castle_take_hit = castle_take_hit,
  fail = fail,
  generate_gold = generate_gold,
  monster_dying = monster_dying,
  select_menu = select_menu,
}