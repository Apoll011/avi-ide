-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local common = require "core.common"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- LANG FILE VIEW - Creative Card Display
--------------------------------------------------------------------------------
local LangView = View:extend()

function LangView:new(doc)
  LangView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = { code = "", lang = {} }
  
  -- Load initial data
  self:load_data()
  
  core.log("LangView initialized with " .. self:count_strings() .. " translations")
end

function LangView:count_strings()
  local count = 0
  for _ in pairs(self.data.lang or {}) do
    count = count + 1
  end
  return count
end

function LangView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      if not self.data.lang then
        self.data.lang = {}
      end
      core.log("Loaded " .. self:count_strings() .. " translations for: " .. (self.data.code or "unknown"))
    else
      core.log("Failed to parse YAML")
      self.data = { code = "", lang = {} }
    end
  end
end

function LangView:get_sorted_keys()
  local keys = {}
  for k in pairs(self.data.lang or {}) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
end

function LangView:get_name()
  return "Language: " .. (self.data.code or "Unknown")
end

function LangView:get_scrollable_size()
  local count = self:count_strings()
  local cards_per_row = 2
  local rows = math.ceil(count / cards_per_row)
  return (rows * 160) + 250
end

function LangView:try_close(do_close)
  do_close()
end

function LangView:update()
  LangView.super.update(self)
end

function LangView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Draw elegant header
  local title_font = style.big_font or style.font
  local code = self.data.code or "unknown"
  local title = string.format("Language: %s", code:upper())
  renderer.draw_text(title_font, title, x, y, style.accent)
  y = y + title_font:get_height() + 5
  
  -- Draw language code badge
  local badge_text = code
  local badge_width = style.font:get_width(badge_text) + 20
  local badge_x = x
  local badge_y = y
  renderer.draw_rect(badge_x, badge_y, badge_width, 28, style.accent)
  renderer.draw_text(style.font, badge_text, badge_x + 10, badge_y + 6, style.background)
  
  -- Draw count
  local count = self:count_strings()
  local count_text = string.format("%d translation string%s", count, count == 1 and "" or "s")
  renderer.draw_text(style.font, count_text, badge_x + badge_width + 20, badge_y + 6, style.dim)
  y = y + 50
  
  -- Draw decorative line
  renderer.draw_rect(x, y, w, 2, style.accent)
  y = y + 30
  
  -- Draw translation cards in a grid
  if count == 0 then
    local empty_msg = "No translation strings defined"
    local empty_x = x + (w - style.font:get_width(empty_msg)) / 2
    renderer.draw_text(style.font, empty_msg, empty_x, y + 40, style.dim)
  else
    local card_width = (w - 20) / 2
    local card_height = 140
    local gap = 20
    
    local keys = self:get_sorted_keys()
    for i, key in ipairs(keys) do
      local col = (i - 1) % 2
      local row = math.floor((i - 1) / 2)
      
      local card_x = x + (col * (card_width + gap))
      local card_y = y + (row * (card_height + gap))
      
      -- Draw card background
      renderer.draw_rect(card_x, card_y, card_width, card_height, style.background2)
      
      -- Draw card border
      renderer.draw_rect(card_x, card_y, card_width, 2, style.accent)
      renderer.draw_rect(card_x, card_y, 2, card_height, style.divider)
      renderer.draw_rect(card_x + card_width - 2, card_y, 2, card_height, style.divider)
      renderer.draw_rect(card_x, card_y + card_height - 2, card_width, 2, style.divider)
      
      -- Card content
      local content_x = card_x + 15
      local content_y = card_y + 15
      
      -- Draw key with icon
      renderer.draw_text(style.font, key, content_x, content_y, style.text)
      content_y = content_y + style.font:get_height() + 10
      
      -- Draw divider
      renderer.draw_rect(content_x, content_y, card_width - 30, 1, style.divider)
      content_y = content_y + 12
      
      -- Draw value with word wrap
      local value = tostring(self.data.lang[key] or "")
      local max_width = card_width - 30
      local words = {}
      for word in value:gmatch("%S+") do
        table.insert(words, word)
      end
      
      local line = ""
      local line_count = 0
      local max_lines = 3
      
      for _, word in ipairs(words) do
        local test_line = line == "" and word or (line .. " " .. word)
        if style.font:get_width(test_line) > max_width then
          if line_count < max_lines then
            renderer.draw_text(style.font, line, content_x, content_y, style.dim)
            content_y = content_y + style.font:get_height() + 3
            line_count = line_count + 1
            line = word
          else
            line = line .. "..."
            break
          end
        else
          line = test_line
        end
      end
      
      if line ~= "" and line_count < max_lines then
        renderer.draw_text(style.font, line, content_x, content_y, style.dim)
      end
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

  if path:match("%.lang$") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = LangView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  LangView = LangView
}