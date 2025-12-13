-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- ENTITY VIEW - Single Entity Display
--------------------------------------------------------------------------------
local EntityView = View:extend()

function EntityView:new(doc)
  EntityView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = {}
  self:load_data()
  core.log("EntityView initialized for entity: " .. tostring(self.data.name))
end

function EntityView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      core.log("Loaded entity: " .. tostring(result.name))
    else
      core.log("Failed to parse YAML")
      self.data = {}
    end
  end
end

function EntityView:get_name()
  return "Entity: " .. tostring(self.data.name or "Unknown")
end

function EntityView:get_scrollable_size()
  local base = 500
  local values_count = self.data.values and #self.data.values or 0
  return base + (values_count * 50)
end

function EntityView:try_close(do_close)
  do_close()
end

function EntityView:update()
  EntityView.super.update(self)
end

function EntityView:draw_info_section(x, y, width, label, value, value_color)
  local height = 60
  
  -- Section background
  renderer.draw_rect(x, y, width, height, style.background2)
  
  -- Left accent bar
  renderer.draw_rect(x, y, 4, height, style.accent)
  
  -- Borders
  renderer.draw_rect(x, y, width, 1, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, height, style.divider)
  renderer.draw_rect(x, y + height - 1, width, 1, style.divider)
  
  local content_x = x + 20
  local content_y = y + 12
  
  -- Label
  renderer.draw_text(style.font, label, content_x, content_y, style.dim)
  content_y = content_y + style.font:get_height() + 4
  
  -- Value
  local display_value = tostring(value)
  value_color = value_color or style.text
  renderer.draw_text(style.font, display_value, content_x, content_y, value_color)
  
  return y + height
end

function EntityView:draw_values_section(x, y, width, values)
  if not values or #values == 0 then
    return y
  end
  
  local max_item_height = 50
  local total_height = 80 -- Start with header space
  
  -- Calculate total height needed
  for _, value in ipairs(values) do
    if type(value) == "table" then
      total_height = total_height + math.max(max_item_height, 30 + (#value * 20))
    else
      total_height = total_height + max_item_height
    end
  end
  
  -- Section background
  renderer.draw_rect(x, y, width, total_height, style.background2)
  
  -- Top accent border
  renderer.draw_rect(x, y, width, 3, style.accent)
  
  -- Borders
  renderer.draw_rect(x, y, 1, total_height, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, total_height, style.divider)
  renderer.draw_rect(x, y + total_height - 1, width, 1, style.divider)
  
  local content_x = x + 20
  local content_y = y + 20
  
  -- Section title
  local title = string.format("VALUES (%d)", #values)
  renderer.draw_text(style.font, title, content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 15
  
  -- Divider
  renderer.draw_rect(content_x, content_y, width - 40, 1, style.divider)
  content_y = content_y + 15
  
  -- Draw each value
  for i, value in ipairs(values) do
    local item_start_y = content_y
    
    -- Value number badge
    local badge_text = tostring(i)
    local badge_width = 30
    renderer.draw_rect(content_x, content_y + 5, badge_width, 22, style.accent)
    local badge_text_x = content_x + (badge_width - style.font:get_width(badge_text)) / 2
    renderer.draw_text(style.font, badge_text, badge_text_x, content_y + 8, style.background)
    
    if type(value) == "table" then
      -- Main value (first item)
      renderer.draw_text(style.font, tostring(value[1]), content_x + 40, content_y + 8, style.text)
      content_y = content_y + 30
      
      -- Synonyms section
      if #value > 1 then
        local syn_x = content_x + 50
        
        -- "Synonyms:" label
        renderer.draw_text(style.font, "Synonyms:", syn_x, content_y, style.dim)
        content_y = content_y + style.font:get_height() + 5
        
        -- Draw each synonym
        for j = 2, #value do
          -- Synonym bullet and text
          renderer.draw_text(style.font, "•", syn_x + 10, content_y, style.accent)
          renderer.draw_text(style.font, tostring(value[j]), syn_x + 25, content_y, style.dim)
          content_y = content_y + style.font:get_height() + 3
        end
        
        content_y = content_y + 5
      else
        content_y = content_y + 10
      end
    else
      -- Simple value
      renderer.draw_text(style.font, tostring(value), content_x + 40, content_y + 8, style.text)
      content_y = content_y + 40
    end
    
    -- Divider between items (except last)
    if i < #values then
      renderer.draw_rect(content_x, content_y, width - 40, 1, style.divider)
      content_y = content_y + 10
    end
  end
  
  return y + total_height
end

function EntityView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Hero section with entity name
  local hero_height = 100
  renderer.draw_rect(x, y, w, hero_height, style.line_highlight)
  renderer.draw_rect(x, y, w, 4, style.accent)
  
  local hero_y = y + 25
  local title_font = style.big_font or style.font
  local entity_name = tostring(self.data.name or "Unknown Entity")
  renderer.draw_text(title_font, entity_name, x + 20, hero_y, style.accent)
  
  hero_y = hero_y + title_font:get_height() + 5
  local entity_type = tostring(self.data.type or "entity")
  renderer.draw_text(style.font, "Type: " .. entity_type, x + 20, hero_y, style.dim)
  
  y = y + hero_height + 30
  
  -- Info grid - three columns for additional properties
  local col_width = (w - 40) / 3
  local col1_x = x
  local col2_x = x + col_width + 20
  local col3_x = x + (col_width * 2) + 40
  
  -- Row 1
  local row1_y = y
  
  -- Extensible status
  local extensible = self.data.automatically_extensible
  local ext_text = extensible and "Yes" or "No"
  local ext_color = extensible and style.accent or style.dim
  self:draw_info_section(col1_x, row1_y, col_width, "AUTO EXTENSIBLE", ext_text, ext_color)
  
  -- Use synonyms
  local use_syn = self.data.use_synonyms
  local syn_text = use_syn and "Yes" or "No"
  local syn_color = use_syn and style.accent or style.dim
  self:draw_info_section(col2_x, row1_y, col_width, "USE SYNONYMS", syn_text, syn_color)
  
  -- Matching strictness
  local strictness = self.data.matching_strictness or 1.0
  local strictness_text = string.format("%.1f", strictness)
  self:draw_info_section(col3_x, row1_y, col_width, "MATCHING STRICTNESS", strictness_text, style.accent)
  
  y = row1_y + 80
  
  -- Values section (full width)
  if self.data.values then
    y = self:draw_values_section(x, y, w, self.data.values)
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

  if path:match("%.entity$") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = EntityView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  EntityView = EntityView
}