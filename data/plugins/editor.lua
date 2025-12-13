-- mod-version:3
local core = require "core"
local command = require "core.command"
local config = require "core.config"

--------------------------------------------------------------------------------
-- AVI EDITOR TOGGLE - Global State Manager
--------------------------------------------------------------------------------

-- Initialize config namespace if it doesn't exist
if not config.plugins then
  config.plugins = {}
end
if not config.plugins.avi_editor then
  config.plugins.avi_editor = {}
end

-- Default state: editing enabled
if config.plugins.avi_editor.edit_screens_enabled == nil then
  config.plugins.avi_editor.edit_screens_enabled = true
end

--------------------------------------------------------------------------------
-- PUBLIC API - Access from any plugin
--------------------------------------------------------------------------------

-- Global table for easy access from other plugins
local avi_editor = {}

-- Check if edit screens are enabled
function avi_editor.is_editing_enabled()
  return config.plugins.avi_editor.edit_screens_enabled
end

-- Set editing state programmatically
function avi_editor.set_editing_enabled(enabled)
  config.plugins.avi_editor.edit_screens_enabled = enabled
  core.log("AVI Editor: Edit screens " .. (enabled and "enabled" or "disabled"))
end

-- Toggle editing state
function avi_editor.toggle_editing()
  local new_state = not config.plugins.avi_editor.edit_screens_enabled
  avi_editor.set_editing_enabled(new_state)
  return new_state
end

--------------------------------------------------------------------------------
-- COMMANDS
--------------------------------------------------------------------------------

command.add(nil, {
  ["avi-editor:disable-edit-screens"] = function()
    avi_editor.set_editing_enabled(false)
    core.log("AVI Editor: Edit screens disabled")
  end,
  
  ["avi-editor:enable-edit-screens"] = function()
    avi_editor.set_editing_enabled(true)
    core.log("AVI Editor: Edit screens enabled")
  end,
  
  ["avi-editor:toggle-edit-screens"] = function()
    local enabled = avi_editor.toggle_editing()
    local status = enabled and "enabled" or "disabled"
    core.log("AVI Editor: Edit screens " .. status)
  end
})

--------------------------------------------------------------------------------
-- EXPORT
--------------------------------------------------------------------------------

return avi_editor