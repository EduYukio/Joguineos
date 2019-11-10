
local Vec = require 'common.vec'

local UI_Related = require 'common.class' ()

function UI_Related:_init(stage)
  self.stage = stage
  self.ui_select = self.stage.ui_select
  self.ui_info = self.stage.ui_info
  self.atlas = self.stage.atlas
  self.cursor = self.stage.cursor
end

function UI_Related:add_ui_sprites()
  for _, v in pairs(self.ui_select.sprites) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end

  for _, v in pairs(self.ui_info.monsters_info) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end
end

function UI_Related:highlight_hovered_box()
  local mouse_pos = Vec(love.mouse.getPosition())
  self.ui_select.hovered_box = nil
  self.ui_info.hovered_box = nil

  for i, box in ipairs(self.ui_select.boxes) do
    if box:is_inside(mouse_pos) then
      self.ui_select.hovered_box = box
      self.ui_info.hovered_box = box
      self.ui_info.hovered_appearance = self.ui_select.sprites[i].appearance
      self.ui_info.hovered_category = self.ui_select.sprites[i].category
      return
    end
  end
end

function UI_Related:select_tower(appearance, index)
  self.stage.selected_tower = appearance
  self.cursor.selected_tower_appearance = self.selected_tower
  if index then
    self.ui_select.selected_box = self.ui_select.boxes[index]
  else
    self.ui_select.selected_box = nil
  end
end

return UI_Related