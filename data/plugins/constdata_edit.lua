-- mod-version:3
local core = require "core"
local View = require "core.view"
local style = require "core.style"
local Widget = require "widget"
local Button = require "widget.button"
local TextBox = require "widget.textbox"
local yaml = require "core.yaml"

--------------------------------------------------------------------------------
-- YAML PARSER FALLBACK
--------------------------------------------------------------------------------

local function parse_yaml(text)
  return yaml.eval(text)
end

local function serialize_yaml(data)
  return yaml.dump(data)
end

--------------------------------------------------------------------------------
-- CONSTDATA VIEW WITH WIDGETS
--------------------------------------------------------------------------------
local ConstDataView = Widget:extend()

function ConstDataView:new(doc)
  ConstDataView.super.new(self)
  self.doc = doc
  self.scrollable = true
  self.data = { constants = {} }
  self.rows = {}
  
  -- Create key input
  self.key_input = TextBox(self, "", "Name")
  self.key_input.border.width = 1
  self.key_input:set_size(240)
  
  -- Create value input  
  self.value_input = TextBox(self, "", "Enter value...")
  self.value_input.border.width = 1
  self.value_input:set_size(240)
  
  -- Create add button
  self.add_button = Button(self, "Add Constant")
  self.add_button:set_size(240, 30)
  
  self.editing_key = nil
  
  local view = self
  function self.add_button:on_click()
    local key = view.key_input:get_text()
    if key and #key > 0 then
      -- Check if we're editing or adding
      if view.editing_key and view.editing_key ~= key then
        -- Key changed, delete old key
        view.data.constants[view.editing_key] = nil
      end
      
      view.data.constants[key] = view.value_input:get_text() or ""
      view.key_input:set_text("")
      view.value_input:set_text("")
      view.editing_key = nil
      view:save_data()
      view:rebuild_rows()
      core.log("Saved constant: " .. key)
      
      -- Update button text
      view.add_button:set_label("Add Constant")
    else
      core.error("Please enter a key name")
    end
  end
  
  self:load_data()
  self:rebuild_rows()
  
  core.log("ConstDataView created with " .. self:count_constants() .. " constants")
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
    local ok, result = pcall(parse_yaml, text)
    if ok and result then
      self.data = result
      if not self.data.constants then
        self.data.constants = {}
      end
      core.log("Loaded " .. self:count_constants() .. " constants")
    else
      core.log("Failed to parse YAML")
    end
  end
end

function ConstDataView:save_data()
  local yaml = serialize_yaml(self.data)
  self.doc:remove(1, 1, math.huge, math.huge)
  self.doc:insert(1, 1, yaml)
  self.doc:clean()
  core.log("Data saved")
end

function ConstDataView:rebuild_rows()
  -- Clear existing row widgets
  for _, row in ipairs(self.rows) do
    self:remove(row.delete_button)
    if row.edit_button then
      self:remove(row.edit_button)
    end
  end
  self.rows = {}
  
  -- Create buttons for each constant
  local keys = {}
  for k in pairs(self.data.constants) do
    table.insert(keys, k)
  end
  table.sort(keys)
  
  for _, key in ipairs(keys) do
    -- Create edit button
    local edit_btn = Button(self, "Edit")
    edit_btn:set_size(70, 30)
    
    -- Create delete button
    local delete_btn = Button(self, "Delete")
    delete_btn:set_size(80, 30)
    
    local view = self
    local row_key = key
    
    function edit_btn:on_click()
      view.key_input:set_text(row_key)
      view.value_input:set_text(view.data.constants[row_key] or "")
      view.editing_key = row_key
      core.log("Editing constant: " .. row_key)
    end
    
    function delete_btn:on_click()
      view.data.constants[row_key] = nil
      view:save_data()
      view:rebuild_rows()
      core.log("Deleted constant: " .. row_key)
    end
    
    table.insert(self.rows, {
      key = key,
      value = self.data.constants[key],
      edit_button = edit_btn,
      delete_button = delete_btn
    })
  end
end

function ConstDataView:get_name()
  return "ConstData Editor"
end

function ConstDataView:get_scrollable_size()
  local count = self:count_constants()
  return (count + 1) * 70 + 400
end

function ConstDataView:try_close(do_close)
  do_close()
end

function ConstDataView:update()
  ConstDataView.super.update(self)
  
  -- Update button label based on editing state
  if self.editing_key then
    self.add_button:set_label("Save Changes")
  else
    self.add_button:set_label("Add Constant")
  end
  
end

function ConstDataView:draw()
  self:draw_background(style.background)
  
  local x = self.position.x + 40
  local y = self.position.y + 30 - self.scroll.y
  local w = self.size.x - 360
  local line_height = style.font:get_height()
  
  -- Header
  local title_font = style.big_font or style.font
  renderer.draw_text(title_font, "Constants Manager", x, y, style.accent)
  y = y + title_font:get_height() + 5
  
  local subtitle = string.format("%d constant%s", 
                                 self:count_constants(), 
                                 self:count_constants() == 1 and "" or "s")
  renderer.draw_text(style.font, subtitle, x, y, style.dim)
  y = y + line_height + 30
  
  -- Table header
  local key_col_x = x + 20
  local value_col_x = x + 250
  
  renderer.draw_rect(x, y, w, 40, style.line_highlight)
  renderer.draw_text(style.font, "Key", key_col_x, y + 12, style.accent)
  renderer.draw_text(style.font, "Value", value_col_x, y + 12, style.accent)
  renderer.draw_text(style.font, "Actions", x + w - 100, y + 12, style.accent)
  y = y + 40
  
  renderer.draw_rect(x, y, w, 2, style.accent)
  y = y + 10
  
  -- Draw constants
  if #self.rows == 0 then
    y = y + 40
    renderer.draw_text(style.font, "No constants yet. Add one using the sidebar!", x + 20, y, style.dim)
  else
    for i, row in ipairs(self.rows) do
      local row_y = y
      
      if i % 2 == 0 then
        renderer.draw_rect(x, row_y, w, 50, style.background2)
      end
      
      renderer.draw_rect(x, row_y + 49, w, 1, style.divider)
      
      local text_y = row_y + 15
      renderer.draw_text(style.font, row.key, key_col_x, text_y, style.accent)
      
      local display_value = row.value or ""
      if #display_value > 40 then
        display_value = display_value:sub(1, 37) .. "..."
      end
      renderer.draw_text(style.font, display_value, value_col_x, text_y, style.text)
      
      y = y + 60
    end
  end
  
  ConstDataView.super.draw(self)
  self:draw_scrollbar()
end

--------------------------------------------------------------------------------
-- COMMAND REGISTRATION
--------------------------------------------------------------------------------    
local RootView = require 'core.rootview'
local open_doc = RootView.open_doc
function RootView:open_doc(doc)
  local path = doc.filename or doc.abs_filename or ""

  if path:find("const.constdata") then
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