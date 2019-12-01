
local p = require 'database.properties'
local SOUNDS_DB = require 'database.sounds'

local conditions = {
  "poisoned", "energized", "sticky", "crit_ensured", "charmed", "empowered"
}

local colors = {
  "pure_black", "light_blue", "dark_blue", "dark_red", "pink", "orange"
}

local Condition = require 'common.class' ()

function Condition:_init(stage)
  self.stage = stage
  self.turn = self.stage.turn
  self.players = self.stage.players
  self.p_systems = self.stage.p_systems
  self.monsters = self.stage.monsters
  self.atlas = self.stage.atlas
  self.lives = self.stage.lives
  self.rules = self.stage.rules
  self.animation = self.stage.animation
end

function Condition:check_unit(unit, condition, color, index)
  if unit[condition] then
    if self.turn - unit[condition].turn ==
       self.p_systems:get_lifetime(unit, color) then
      unit[condition] = false
    end
    if condition == "poisoned" then
      local victory = self:take_poison_dmg(unit, index)
      if victory then
        self.animation:setup_delay_animation(2.5, "Victory")
        return true
      end
    end
    return false
  end
end

function Condition:check_all_monsters()
  local died_from_poison
  for index, monster in pairs(self.monsters) do
    for j, condition in ipairs(conditions) do
      died_from_poison = self:check_unit(monster, condition, colors[j], index)
    end
  end
  return died_from_poison
end

function Condition:check_all_players()
  for index, player in pairs(self.players) do
    for j, condition in ipairs(conditions) do
      self:check_unit(player, condition, colors[j], index)
    end
  end
end

function Condition:take_poison_dmg(monster, index)
  SOUNDS_DB.unit_take_hit:play()
  monster.hp = monster.hp - p.poison_dmg
  local spr = self.atlas:get(monster)
  self.lives:upgrade_life(spr, monster.hp)

  local died = self.rules:remove_if_dead(monster, self.atlas,
                    self.monsters, index, self.lives)
  local msg = monster.name .. " took " .. tostring(p.poison_dmg) ..
              " damage from poison."

  if died then
    msg = msg .. "\nIt died from bandejao's mighty fish..."
  end
  self.stage:view():get('message'):set(msg)

  if #self.monsters == 0 then
    SOUNDS_DB.fanfare:play()
    return "Victory"
  end
end

return Condition