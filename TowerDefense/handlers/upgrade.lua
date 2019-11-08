local Upgrade = require 'common.class' ()

function Upgrade:_init(stage)
  self.stage = stage
end

function Upgrade:units(appearance)
  if appearance == "castle2" then
    self:upgrade_castle(self.stage.castle)
    return
  end

  if appearance == "archer2" then
    self.stage.ui_select.sprites[1].appearance = appearance
    self:upgrade_towers("Archer", appearance)
  elseif appearance == "knight2" then
    self.stage.ui_select.sprites[2].appearance = appearance
    self:upgrade_towers("Knight", appearance)
  elseif appearance == "mage2" then
    self.stage.ui_select.sprites[3].appearance = appearance
    self:upgrade_towers("Mage", appearance)
  end

  self.stage:add_ui_sprites()
  self:upgrade_selected_tower(appearance)
end

function Upgrade:upgrade_castle(castle)
  self.stage:remove_unit(castle)
  self.stage.castle = self.stage:_create_unit_at('castle2', self.stage.castle_pos)
  castle.p_system:emit(20)
end

function Upgrade:upgrade_towers(tower_name, appearance)
  local position_array = {}
  for tower in pairs(self.stage.towers) do
    if tower.name == tower_name then
      local pos = self.stage.atlas:get(tower).position
      table.insert(position_array, pos)
      self.stage:remove_unit(tower)
    end
  end

  for _, pos in ipairs(position_array) do
    local new_tower = self.stage:_create_unit_at(appearance, pos, true)
    self.stage.towers[new_tower] = true
    new_tower.p_system:emit(20)
  end
end

function Upgrade:upgrade_selected_tower(appearance)
  local curr = self.stage.selected_tower
  if appearance == "archer2" and curr == "archer1" then
    self.stage.selected_tower = "archer2"
  elseif appearance == "knight2" and curr == "knight1" then
    self.stage.selected_tower = "knight2"
  elseif appearance == "mage2" and curr == "mage1" then
    self.stage.selected_tower = "mage2"
  end
end


return Upgrade