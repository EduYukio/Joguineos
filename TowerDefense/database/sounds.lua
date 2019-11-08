local path = "assets/audio/"

local buy_upgrade = love.audio.newSource(path .. "buy_upgrade.wav", "static")
local castle_take_hit = love.audio.newSource(path .. "castle_take_hit.wav", "static")
local fail = love.audio.newSource(path .. "fail.wav", "static")
local generate_gold = love.audio.newSource(path .. "generate_gold.wav", "static")
local monster_dying = love.audio.newSource(path .. "monster_dying.wav", "static")
local select_menu = love.audio.newSource(path .. "select_menu.wav", "static")

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