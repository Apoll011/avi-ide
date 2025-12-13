-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local yaml = require "core.yaml"
local avi_editor = require "plugins.editor"

--------------------------------------------------------------------------------
-- CONSTDATA VIEW - Card Grid Display
--------------------------------------------------------------------------------
local ConstDataView = View:extend()

function ConstDataView:new(doc)
  ConstDataView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = { constants = {} }
  self:load_data()
  core.log("ConstDataView initialized with " .. self:count_constants() .. " constants")
end

function ConstDataView:count_constants()
  local count = 0
  for _ in pairs(self.data.constants) do
    count = count + 1
  end
  return count
end

function ConstDataView:load_data()
  local text = self.doc:get_text(1, 1, math.huge, math.huge)
  
  if text and #text > 0 then
    local ok, result = pcall(yaml.eval, text)
    if ok and result then
      self.data = result
      if not self.data.constants then
        self.data.constants = {}
      end
      core.log("Loaded " .. self:count_constants() .. " constants")
    else
      core.log("Failed to parse YAML")
      self.data = { constants = {} }
    end
  end
end

function ConstDataView:get_all_constants()
  local all_constants = {}
  
  for key, value in pairs(self.data.constants) do
    table.insert(all_constants, {key = key, value = value})
  end
  
  -- Sort by key
  table.sort(all_constants, function(a, b) return a.key < b.key end)
  
  return all_constants
end

function ConstDataView:get_name()
  return "Constants"
end

function ConstDataView:get_scrollable_size()
  local count = self:count_constants()
  local cards_per_row = 2
  local rows = math.ceil(count / cards_per_row)
  return (rows * 120) + 300
end

function ConstDataView:try_close(do_close)
  do_close()
end

function ConstDataView:update()
  ConstDataView.super.update(self)
end

function ConstDataView:draw_constant_card(x, y, width, height, key, value)
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
  
  -- Constant key/name
  renderer.draw_text(style.font, tostring(key), content_x, content_y, style.accent)
  content_y = content_y + style.font:get_height() + 10
  
  -- Divider
  renderer.draw_rect(content_x, content_y, content_width, 1, style.divider)
  content_y = content_y + 10
  
  -- Value
  local value_str = tostring(value)
  local max_width = content_width
  
  -- Truncate if needed
  if style.font:get_width(value_str) > max_width then
    while style.font:get_width(value_str .. "...") > max_width and #value_str > 0 do
      value_str = value_str:sub(1, -2)
    end
    value_str = value_str .. "..."
  end
  
  renderer.draw_text(style.font, value_str, content_x, content_y, style.text)
end

function ConstDataView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 80
  
  -- Header
  local title_font = style.big_font or style.font
  renderer.draw_text(title_font, "Constants", x, y, style.accent)
  y = y + title_font:get_height() + 5
  
  local count = self:count_constants()
  local subtitle = string.format("%d constant%s", count, count == 1 and "" or "s")
  renderer.draw_text(style.font, subtitle, x, y, style.dim)
  y = y + style.font:get_height() + 30
  
  -- Divider
  renderer.draw_rect(x, y, w, 2, style.accent)
  y = y + 30
  
  if count == 0 then
    local empty_msg = "No constants defined"
    local empty_x = x + (w - style.font:get_width(empty_msg)) / 2
    renderer.draw_text(style.font, empty_msg, empty_x, y + 40, style.dim)
  else
    local card_width = (w - 20) / 2
    local card_height = 100
    local gap = 20
    
    local all_constants = self:get_all_constants()
    
    -- Draw cards in simple grid
    for i, item in ipairs(all_constants) do
      local card_index = i - 1
      local col = card_index % 2
      local row = math.floor(card_index / 2)
      
      local card_x = x + (col * (card_width + gap))
      local card_y = y + (row * (card_height + gap))
      
      self:draw_constant_card(card_x, card_y, card_width, card_height, item.key, item.value)
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

  if path:find("const.constdata") and avi_editor.is_editing_enabled() then
    local node = self:get_active_node_default()
    local view = ConstDataView(doc)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end

  return open_doc(self, doc)
end

return {
  ConstDataView = ConstDataView
}