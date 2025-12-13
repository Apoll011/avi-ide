-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local common = require "core.common"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- SETTINGS CONFIG VIEW - Simple Grid Display
--------------------------------------------------------------------------------
local SettingsView = View:extend()

function SettingsView:new(doc)
  SettingsView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = { settings = {} }
  
  -- Load initial data
  self:load_data()
  
  core.log("SettingsView initialized with " .. self:count_settings() .. " settings")
end

function SettingsView:count_settings()
  local count = 0
  for _ in pairs(self.data.settings or {}) do
    count = count + 1
  end
  return count
end

function SettingsView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      if not self.data.settings then
        self.data.settings = {}
      end
      
      -- Debug: log structure
      core.log("Loaded data structure:")
      for key, value in pairs(self.data) do
        core.log("  " .. key .. " = " .. type(value))
        if key == "settings" and type(value) == "table" then
          for setting_key, setting_value in pairs(value) do
            core.log("    " .. setting_key .. " = " .. type(setting_value))
          end
        end
      end
      
      core.log("Loaded " .. self:count_settings() .. " settings")
    else
      core.log("Failed to parse YAML: " .. tostring(result))
      self.data = { settings = {} }
    end
  end
end

function SettingsView:get_all_settings()
  local all_settings = {}
  
  for key, setting in pairs(self.data.settings or {}) do
    if setting and type(setting) == "table" then
      table.insert(all_settings, {key = key, setting = setting})
    end
  end
  
  -- Sort by key
  table.sort(all_settings, function(a, b) return a.key < b.key end)
  
  return all_settings
end

function SettingsView:get_name()
  return "Settings Configuration"
end

function SettingsView:get_scrollable_size()
  local count = self:count_settings()
  local cards_per_row = 2
  local rows = math.ceil(count / cards_per_row)
  return (rows * 200) + 300
end

function SettingsView:try_close(do_close)
  do_close()
end

function SettingsView:update()
  SettingsView.super.update(self)
end

function SettingsView:draw_slider_visual(x, y, width, value, min_val, max_val)
  local height = 6
  local track_color = style.divider
  local fill_color = style.accent
  
  -- Track
  renderer.draw_rect(x, y, width, height, track_color)
  
  -- Fill
  local normalized = (value - min_val) / (max_val - min_val)
  local fill_width = width * normalized
  renderer.draw_rect(x, y, fill_width, height, fill_color)
  
  -- Thumb
  local thumb_x = x + fill_width - 4
  local thumb_y = y - 4
  renderer.draw_rect(thumb_x, thumb_y, 8, 14, style.background)
  renderer.draw_rect(thumb_x, thumb_y, 8, 14, fill_color)
end

function SettingsView:draw_toggle_visual(x, y, enabled)
  local width = 40
  local height = 20
  local bg_color = enabled and style.accent or style.divider
  local thumb_color = style.background
  
  -- Background track
  renderer.draw_rect(x, y, width, height, bg_color)
  
  -- Thumb
  local thumb_x = enabled and (x + width - 18) or (x + 2)
  renderer.draw_rect(thumb_x, y + 2, 16, 16, thumb_color)
end

function SettingsView:draw_dropdown_visual(x, y, width, selected_value, options)
  local height = 28
  
  -- Background
  renderer.draw_rect(x, y, width, height, style.background2)
  
  -- Border
  renderer.draw_rect(x, y, width, 1, style.divider)
  renderer.draw_rect(x, y, 1, height, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, height, style.divider)
  renderer.draw_rect(x, y + height - 1, width, 1, style.divider)
  
  -- Selected value
  local text_x = x + 8
  local text_y = y + 6
  renderer.draw_text(style.font, tostring(selected_value), text_x, text_y, style.text)
  
  -- Arrow indicator
  local arrow_x = x + width - 20
  renderer.draw_text(style.font, "▼", arrow_x, text_y, style.dim)
end

function SettingsView:draw_text_field_visual(x, y, width, value, ui_type)
  local height = 28
  
  -- Background
  local bg = style.background2
  if ui_type == "password" then
    bg = style.line_highlight
  end
  renderer.draw_rect(x, y, width, height, bg)
  
  -- Border with accent for password fields
  local border_color = ui_type == "password" and style.accent or style.divider
  renderer.draw_rect(x, y, width, 1, border_color)
  renderer.draw_rect(x, y, 1, height, border_color)
  renderer.draw_rect(x + width - 1, y, 1, height, border_color)
  renderer.draw_rect(x, y + height - 1, width, 1, border_color)
  
  -- Value text
  local display_value = value
  if ui_type == "password" and value and #value > 0 then
    display_value = string.rep("•", #value)
  end
  
  local text_x = x + 8
  local text_y = y + 6
  local text_color = (value == "" or not value) and style.dim or style.text
  renderer.draw_text(style.font, tostring(display_value), text_x, text_y, text_color)
end

function SettingsView:draw_list_visual(x, y, width, items)
  local item_height = 24
  local total_height = #items * item_height
  
  -- Container
  renderer.draw_rect(x, y, width, total_height, style.background2)
  renderer.draw_rect(x, y, width, 1, style.divider)
  renderer.draw_rect(x, y + total_height - 1, width, 1, style.divider)
  
  -- Items
  for i, item in ipairs(items) do
    local item_y = y + ((i - 1) * item_height)
    
    -- Item background (alternating)
    if i % 2 == 0 then
      renderer.draw_rect(x, item_y, width, item_height, style.line_highlight)
    end
    
    -- Bullet
    renderer.draw_text(style.font, "•", x + 8, item_y + 4, style.accent)
    
    -- Item text
    renderer.draw_text(style.font, tostring(item), x + 20, item_y + 4, style.text)
    
    -- Divider between items
    if i < #items then
      renderer.draw_rect(x, item_y + item_height - 1, width, 1, style.divider)
    end
  end
end

function SettingsView:draw_setting_card(x, y, width, height, key, setting)
  -- Safety check
  if not key or not setting then
    return
  end
  
  -- Card background
  renderer.draw_rect(x, y, width, height, style.background2)
  
  -- Card top accent border
  renderer.draw_rect(x, y, width, 3, style.accent)
  
  -- Card borders
  renderer.draw_rect(x, y, 1, height, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, height, style.divider)
  renderer.draw_rect(x, y + height - 1, width, 1, style.divider)
  
  local content_x = x + 15
  local content_y = y + 15
  local content_width = width - 30
  
  -- Setting key/name
  renderer.draw_text(style.font, tostring(key), content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 3
  
  -- Type badge
  if setting.vtype then
    local badge_text = tostring(setting.vtype)
    local badge_width = style.font:get_width(badge_text) + 12
    renderer.draw_rect(content_x, content_y, badge_width, 18, style.divider)
    renderer.draw_text(style.font, badge_text, content_x + 6, content_y + 2, style.dim)
    content_y = content_y + 24
  end
  
  -- Description
  if setting.description then
    local desc_lines = {}
    local words = {}
    for word in tostring(setting.description):gmatch("%S+") do
      table.insert(words, word)
    end
    
    local line = ""
    for _, word in ipairs(words) do
      local test_line = line == "" and word or (line .. " " .. word)
      if style.font:get_width(test_line) > content_width then
        if #desc_lines < 2 then
          table.insert(desc_lines, line)
          line = word
        else
          line = line .. "..."
          break
        end
      else
        line = test_line
      end
    end
    
    if line ~= "" and #desc_lines < 2 then
      table.insert(desc_lines, line)
    end
    
    for _, desc_line in ipairs(desc_lines) do
      renderer.draw_text(style.font, desc_line, content_x, content_y, style.dim)
      content_y = content_y + style.font:get_height() + 2
    end
    
    content_y = content_y + 8
  end
  
  -- Divider
  renderer.draw_rect(content_x, content_y, content_width, 1, style.divider)
  content_y = content_y + 10
  
  -- Value display based on type
  local value = setting.value
  local ui_type = setting.ui
  
  if ui_type == "slider" then
    local min_val = setting.min or 0
    local max_val = setting.max or 100
    
    -- Value label
    local value_text = string.format("Value: %s", tostring(value))
    renderer.draw_text(style.font, value_text, content_x, content_y, style.text)
    content_y = content_y + style.font:get_height() + 6
    
    -- Slider visual
    local num_value = tonumber(value) or 0
    self:draw_slider_visual(content_x, content_y, content_width - 20, num_value, min_val, max_val)
    
  elseif ui_type == "toggle" then
    local status_text = value and "Enabled" or "Disabled"
    renderer.draw_text(style.font, status_text, content_x, content_y, style.text)
    self:draw_toggle_visual(content_x + 80, content_y - 2, value)
    
  elseif ui_type == "dropdown" then
    renderer.draw_text(style.font, "Selected:", content_x, content_y, style.dim)
    content_y = content_y + style.font:get_height() + 4
    self:draw_dropdown_visual(content_x, content_y, content_width - 20, value, setting.enum_ or {})
    
  elseif ui_type == "text" or ui_type == "password" then
    renderer.draw_text(style.font, "Value:", content_x, content_y, style.dim)
    content_y = content_y + style.font:get_height() + 4
    self:draw_text_field_visual(content_x, content_y, content_width - 20, tostring(value or ""), ui_type)
    
  elseif setting.vtype == "list" and type(value) == "table" then
    renderer.draw_text(style.font, string.format("%d items:", #value), content_x, content_y, style.dim)
    content_y = content_y + style.font:get_height() + 4
    
    -- Show first few items
    local max_items = 3
    for i = 1, math.min(#value, max_items) do
      renderer.draw_text(style.font, "• " .. tostring(value[i]), content_x + 4, content_y, style.text)
      content_y = content_y + style.font:get_height() + 2
    end
    
    if #value > max_items then
      renderer.draw_text(style.font, "... and " .. (#value - max_items) .. " more", content_x + 4, content_y, style.dim)
    end
    
  elseif setting.vtype == "boolean" then
    local status_text = value and "Yes" or "No"
    local status_color = value and style.accent or style.dim
    renderer.draw_text(style.font, "Value: " .. status_text, content_x, content_y, status_color)
    
  else
    -- Default: show value as text
    renderer.draw_text(style.font, "Value: " .. tostring(value or ""), content_x, content_y, style.text)
  end
end

function SettingsView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Header
  local title_font = style.big_font or style.font
  renderer.draw_text(title_font, "Settings Configuration", x, y, style.accent)
  y = y + title_font:get_height() + 5
  
  local count = self:count_settings()
  local subtitle = string.format("%d setting%s", count, count == 1 and "" or "s")
  renderer.draw_text(style.font, subtitle, x, y, style.dim)
  y = y + style.font:get_height() + 30
  
  -- Divider
  renderer.draw_rect(x, y, w, 2, style.accent)
  y = y + 30
  
  if count == 0 then
    local empty_msg = "No settings defined"
    local empty_x = x + (w - style.font:get_width(empty_msg)) / 2
    renderer.draw_text(style.font, empty_msg, empty_x, y + 40, style.dim)
  else
    local card_width = (w - 20) / 2
    local card_height = 180
    local gap = 20
    
    local all_settings = self:get_all_settings()
    
    -- Draw cards in simple grid
    for i, item in ipairs(all_settings) do
      local card_index = i - 1
      local col = card_index % 2
      local row = math.floor(card_index / 2)
      
      local card_x = x + (col * (card_width + gap))
      local card_y = y + (row * (card_height + gap))
      
      self:draw_setting_card(card_x, card_y, card_width, card_height, item.key, item.setting)
    end
  end
  
  self:draw_scrollbar()
end

--------------------------------------------------------------------------------
-- COMMAND REGISTRATION
--------------------------------------------------------------------------------
local RootView = require 'core.rootview'
local open_doc = RootView.open_doc

function RootView:open_doc(doc)
  local path = doc.filename or doc.abs_filename or ""

  if path:match("%.config$") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = SettingsView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  SettingsView = SettingsView
}