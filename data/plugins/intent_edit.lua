-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- INTENT VIEW - Single Intent Display
--------------------------------------------------------------------------------
local IntentView = View:extend()

function IntentView:new(doc)
  IntentView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = {}
  self:load_data()
  core.log("IntentView initialized for intent: " .. tostring(self.data.name))
end

function IntentView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      core.log("Loaded intent: " .. tostring(result.name))
    else
      core.log("Failed to parse YAML")
      self.data = {}
    end
  end
end

function IntentView:get_name()
  return "Intent: " .. tostring(self.data.name or "Unknown")
end

function IntentView:get_scrollable_size()
  local base = 600
  local utterances_count = self.data.utterances and #self.data.utterances or 0
  local slots_count = self.data.slots and #self.data.slots or 0
  return base + (utterances_count * 40) + (slots_count * 70)
end

function IntentView:try_close(do_close)
  do_close()
end

function IntentView:update()
  IntentView.super.update(self)
end

function IntentView:draw_info_section(x, y, width, label, value, value_color)
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

function IntentView:parse_utterance_slots(utterance)
  -- Extract slot annotations like [slot_name](value) or [slot_name:entity](value)
  local slots = {}
  local display_text = utterance
  
  for full_match in utterance:gmatch("%[([^%]]+)%]%(([^%)]+)%)") do
    table.insert(slots, full_match)
  end
  
  return display_text, slots
end

function IntentView:draw_slots_section(x, y, width, slots)
  if not slots or #slots == 0 then
    return y
  end
  
  local slot_height = 70
  local total_height = 80 + (#slots * slot_height)
  
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
  local title = string.format("SLOTS (%d)", #slots)
  renderer.draw_text(style.font, title, content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 15
  
  -- Divider
  renderer.draw_rect(content_x, content_y, width - 40, 1, style.divider)
  content_y = content_y + 15
  
  -- Draw each slot
  for i, slot in ipairs(slots) do
    local slot_y = content_y
    
    -- Slot number badge
    local badge_text = tostring(i)
    local badge_width = 30
    renderer.draw_rect(content_x, slot_y, badge_width, 22, style.accent)
    local badge_text_x = content_x + (badge_width - style.font:get_width(badge_text)) / 2
    renderer.draw_text(style.font, badge_text, badge_text_x, slot_y + 3, style.background)
    
    -- Slot name
    local slot_name = tostring(slot.name or "unknown")
    renderer.draw_text(style.font, slot_name, content_x + 40, slot_y + 3, style.text)
    slot_y = slot_y + 25
    
    -- Entity label and value
    renderer.draw_text(style.font, "Entity:", content_x + 40, slot_y, style.dim)
    local entity_text = tostring(slot.entity or "unknown")
    renderer.draw_text(style.font, entity_text, content_x + 100, slot_y, style.accent)
    
    content_y = content_y + slot_height
    
    -- Divider between slots
    if i < #slots then
      renderer.draw_rect(content_x, content_y - 5, width - 40, 1, style.divider)
    end
  end
  
  return y + total_height
end

function IntentView:draw_utterances_section(x, y, width, utterances)
  if not utterances or #utterances == 0 then
    return y
  end
  
  -- Calculate height needed
  local line_height = style.font:get_height() + 4
  local item_padding = 30
  local total_height = 80
  
  for _, utterance in ipairs(utterances) do
    local utterance_text = tostring(utterance)
    local lines = 1
    local max_width = width - 80
    
    -- Simple line wrapping calculation
    if style.font:get_width(utterance_text) > max_width then
      lines = math.ceil(style.font:get_width(utterance_text) / max_width)
    end
    
    total_height = total_height + (lines * line_height) + item_padding
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
  local title = string.format("UTTERANCES (%d)", #utterances)
  renderer.draw_text(style.font, title, content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 15
  
  -- Divider
  renderer.draw_rect(content_x, content_y, width - 40, 1, style.divider)
  content_y = content_y + 15
  
  -- Draw each utterance
  for i, utterance in ipairs(utterances) do
    local utterance_y = content_y
    
    -- Utterance number badge
    local badge_text = tostring(i)
    local badge_width = 30
    renderer.draw_rect(content_x, utterance_y, badge_width, 22, style.accent)
    local badge_text_x = content_x + (badge_width - style.font:get_width(badge_text)) / 2
    renderer.draw_text(style.font, badge_text, badge_text_x, utterance_y + 3, style.background)
    
    -- Utterance text with slot highlighting
    local utterance_text = tostring(utterance)
    local text_x = content_x + 40
    local text_y = utterance_y + 3
    local max_width = width - 80
    
    -- Simple rendering (could be enhanced to highlight [slot] syntax)
    -- Split by [slot] patterns and render with different colors
    local remaining = utterance_text
    local current_x = text_x
    
    while remaining and #remaining > 0 do
      -- Find next slot annotation
      local before, slot_match, after = remaining:match("^(.-)(%[[^%]]+%]%([^%)]+%))(.*)$")
      
      if not before then
        -- No more slots, render remaining text
        renderer.draw_text(style.font, remaining, current_x, text_y, style.text)
        break
      else
        -- Render text before slot
        if #before > 0 then
          renderer.draw_text(style.font, before, current_x, text_y, style.text)
          current_x = current_x + style.font:get_width(before)
        end
        
        -- Render slot with accent color
        renderer.draw_text(style.font, slot_match, current_x, text_y, style.accent)
        current_x = current_x + style.font:get_width(slot_match)
        
        remaining = after
      end
    end
    
    content_y = content_y + item_padding + line_height
    
    -- Divider between utterances
    if i < #utterances then
      renderer.draw_rect(content_x, content_y - 10, width - 40, 1, style.divider)
    end
  end
  
  return y + total_height
end

function IntentView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Hero section with intent name
  local hero_height = 100
  renderer.draw_rect(x, y, w, hero_height, style.line_highlight)
  renderer.draw_rect(x, y, w, 4, style.accent)
  
  local hero_y = y + 25
  local title_font = style.big_font or style.font
  local intent_name = tostring(self.data.name or "Unknown Intent")
  renderer.draw_text(title_font, intent_name, x + 20, hero_y, style.accent)
  
  hero_y = hero_y + title_font:get_height() + 5
  local intent_type = tostring(self.data.type or "intent")
  renderer.draw_text(style.font, "Type: " .. intent_type, x + 20, hero_y, style.dim)
  
  y = y + hero_height + 30
  
  -- Slots section (if defined)
  if self.data.slots and #self.data.slots > 0 then
    y = self:draw_slots_section(x, y, w, self.data.slots)
    y = y + 20
  end
  
  -- Utterances section
  if self.data.utterances then
    y = self:draw_utterances_section(x, y, w, self.data.utterances)
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

  if path:match("%.intent$") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = IntentView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  IntentView = IntentView
}