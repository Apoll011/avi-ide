-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- MANIFEST VIEW - Skill Overview
--------------------------------------------------------------------------------
local ManifestView = View:extend()

function ManifestView:new(doc)
  ManifestView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = {}
  self:load_data()
  core.log("ManifestView initialized for skill: " .. tostring(self.data.name))
end

function ManifestView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      core.log("Loaded manifest: " .. tostring(result.name))
    else
      core.log("Failed to parse YAML")
      self.data = {}
    end
  end
end

function ManifestView:get_name()
  return tostring(self.data.name or "Skill Manifest")
end

function ManifestView:get_scrollable_size()
  local base = 700
  local capabilities = self.data.capabilities and #self.data.capabilities or 0
  local permissions = self.data.permissions and #self.data.permissions or 0
  return base + (capabilities * 35) + (permissions * 35)
end

function ManifestView:try_close(do_close)
  do_close()
end

function ManifestView:update()
  ManifestView.super.update(self)
end

function ManifestView:draw_info_card(x, y, width, height, label, value)
  -- Card background
  renderer.draw_rect(x, y, width, height, style.background2)
  
  -- Top accent border
  renderer.draw_rect(x, y, width, 3, style.accent)
  
  -- Borders
  renderer.draw_rect(x, y, 1, height, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, height, style.divider)
  renderer.draw_rect(x, y + height - 1, width, 1, style.divider)
  
  local content_x = x + 15
  local content_y = y + 12
  
  -- Label
  renderer.draw_text(style.font, label, content_x, content_y, style.dim)
  content_y = content_y + style.font:get_height() + 4
  
  -- Value
  local display_value = tostring(value or "N/A")
  renderer.draw_text(style.font, display_value, content_x, content_y, style.text)
end

function ManifestView:draw_list_section(x, y, width, title, items)
  if not items or #items == 0 then
    return y
  end
  
  local item_height = 35
  local total_height = 80 + (#items * item_height)
  
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
 
  local title_text = string.format("%s (%d)", title, #items)
  renderer.draw_text(style.font, title_text, content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 15
  
  -- Reset content_x
  content_x = x + 20
  
  -- Divider
  renderer.draw_rect(content_x, content_y, width - 40, 1, style.divider)
  content_y = content_y + 15
  
  -- Draw each item
  for i, item in ipairs(items) do
    local item_y = content_y + ((i - 1) * item_height)
    
    -- Alternating background
    if i % 2 == 0 then
      renderer.draw_rect(x + 10, item_y, width - 20, item_height, style.line_highlight)
    end
    
    -- Bullet point
    renderer.draw_text(style.font, "•", content_x + 5, item_y + 8, style.accent)
    
    -- Item text
    renderer.draw_text(style.font, tostring(item), content_x + 20, item_y + 8, style.text)
  end
  
  return y + total_height
end

function ManifestView:draw_description_section(x, y, width, description)
  if not description or description == "" then
    return y
  end
  
  -- Calculate height based on text wrapping
  local line_height = style.font:get_height() + 4
  local max_width = width - 40
  local lines = {}
  local words = {}
  
  for word in tostring(description):gmatch("%S+") do
    table.insert(words, word)
  end
  
  local line = ""
  for _, word in ipairs(words) do
    local test_line = line == "" and word or (line .. " " .. word)
    if style.font:get_width(test_line) > max_width then
      table.insert(lines, line)
      line = word
    else
      line = test_line
    end
  end
  
  if line ~= "" then
    table.insert(lines, line)
  end
  
  local total_height = 60 + (#lines * line_height)
  
  -- Section background
  renderer.draw_rect(x, y, width, total_height, style.background2)
  
  -- Left accent bar
  renderer.draw_rect(x, y, 4, total_height, style.accent)
  
  -- Borders
  renderer.draw_rect(x, y, width, 1, style.divider)
  renderer.draw_rect(x + width - 1, y, 1, total_height, style.divider)
  renderer.draw_rect(x, y + total_height - 1, width, 1, style.divider)
  
  local content_x = x + 20
  local content_y = y + 15
  
  -- Label
  renderer.draw_text(style.font, "Description", content_x, content_y, style.dim)
  content_y = content_y + style.font:get_height() + 10
  
  -- Description text
  for _, desc_line in ipairs(lines) do
    renderer.draw_text(style.font, desc_line, content_x, content_y, style.text)
    content_y = content_y + line_height
  end
  
  return y + total_height
end

function ManifestView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Hero section with skill name
  local hero_height = 120
  renderer.draw_rect(x, y, w, hero_height, style.line_highlight)
  renderer.draw_rect(x, y, w, 5, style.accent)
  
  local hero_y = y + 10
  local title_font = style.big_font or style.font
  
  -- Skill name
  local skill_name = tostring(self.data.name or "Unknown Skill")
  renderer.draw_text(title_font, skill_name, x + 20, hero_y, style.accent)
  hero_y = hero_y + title_font:get_height() + 8
  
  -- Version and author
  local version = tostring(self.data.version or "1.0.0")
  local author = tostring(self.data.author or "Unknown")
  local subtitle = string.format("v%s • by %s", version, author)
  renderer.draw_text(style.font, subtitle, x + 20, hero_y, style.dim)
  
  y = y + hero_height + 30
  
  -- Description section
  if self.data.description then
    y = self:draw_description_section(x, y, w, self.data.description)
    y = y + 20
  end
  
  -- Info cards row (ID, Entry point)
  local card_height = 80
  local card_width = (w - 20) / 2
  local gap = 20
  
  -- ID Card
  self:draw_info_card(x, y, card_width, card_height, "Skill ID", self.data.id)
  
  -- Entry Point Card
  self:draw_info_card(x + card_width + gap, y, card_width, card_height, 
                      "Entry point", self.data.entry)
  
  y = y + card_height + 20
  
  -- Capabilities section
  if self.data.capabilities then
    y = self:draw_list_section(x, y, w, "Capabilities", self.data.capabilities)
    y = y + 20
  end
  
  -- Permissions section
  if self.data.permissions then
    y = self:draw_list_section(x, y, w, "Permissions", self.data.permissions)
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

  if path:match("manifest%.yaml$") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = ManifestView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  ManifestView = ManifestView
}