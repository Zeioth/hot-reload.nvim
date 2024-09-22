-- This plugin is a neovim distro updater.
local M = {}

---Set a default value for an option in a boolean logic safe way.
---@param opt any A option defined by the user.
---@param default any A default value.
local function set_default(opt, default)
  return opt == nil and default or opt
end

---Parse user options, or set the defaults
---@param opts table A table with options to set.
function M.set(opts)
  M.reload_files = opts.reload_files or {}
  M.reload_callback = opts.reload_callback or function() end
  M.notify = opts.notify or set_default(opts.notify, true)

  -- expose the config as global
  vim.g.hot_reload_config = M
end

return M
