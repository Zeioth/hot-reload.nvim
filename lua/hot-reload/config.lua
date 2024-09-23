-- This plugin is a neovim hot reloader.
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
  --- The files included in this table, will be hot reloaded on BufWritePost.
  M.reload_files = opts.reload_files or {}

  --- If specified, this function will run after a file is hot reloaded.
  M.reload_callback = opts.reload_callback or function() end

  --- If true, it will display a notification when a file is hot reloaded.
  M.notify = opts.notify or set_default(opts.notify, true)

  --- If true, all files in reload_files will be reloaded every time in order.
  --- If false, only the current file will be reloaded.
  M.reload_all = opts.reload_all or set_default(opts.reload_all, true)

  --- Event that triggers hot reload.
  M.event = opts.event or "BufWritePost"

  -- expose the config as global
  vim.g.hot_reload_config = M
end

return M
