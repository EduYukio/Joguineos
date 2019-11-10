local Util = require 'common.class' ()

function Util:_init(stage)
  self.stage = stage
  self.lifebars = self.stage.lifebars
  self.stats = self.stage.stats
  self.ui_select = self.stage.ui_select
end

function Util:apply_damage(target, damage)
  target.hp = target.hp - damage

  local hp_percentage = target.hp / target.max_hp
  self.lifebars:x_scale(target, hp_percentage)

  if target.hp <= 0 then
    if target.category == "castle" then
      self.stage.game_over = true
    end
    self.stage.existence:remove_unit(target)
  end
end

function Util:add_gold(value)
  self.stage.gold = self.stage.gold + value
  self.stats.gold = self.stage.gold
  self.ui_select.gold = self.stage.gold
end

return Util