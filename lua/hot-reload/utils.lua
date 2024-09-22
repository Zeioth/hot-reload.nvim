--- ### General utils
--
--  DESCRIPTION:
--  General utility functions.

--    Helpers:
--      -> notify                → Send a notification with the plugin title.
--      -> filepath_to_module    → Converts a file path to module name.
--      -> reload                → Hot reloads the files in the config.
--      -> os_path               → Convert a path to / (UNIX) or \ (Windows).

local M = {}

--- Serve a notification with a default title.
---@param msg string The notification body.
---@param type number|nil The type of the notification (:help vim.log.levels).
---@param opts? table The nvim-notify options to use (:help notify-options).
function M.notify(msg, type, opts)
  vim.schedule(function()
    vim.notify(msg, type,
      vim.tbl_deep_extend(
        "force", { title = "hot-reload.nvim" }, opts or {})
    )
  end)
end

--- Given a path, return its nvim module.
---@param path string Path of a file inside your nvim config directory.
---@return string module A string which is the module of the file path.
---@example  filepath_to_module(/home/user/.config/nvim/lua/base/1-options.lua)  -- returns "base.1-options"
function M.filepath_to_module(path)
    local filename = path:gsub("^.*[\\/]", "")  -- Remove leading directory path
    filename = filename:gsub("%..+$", "")       -- Remove file extension
    filename = filename:gsub("/", ".")          -- Replace '/' with '.'

    -- Extract directory name when constructed using vim.fn.stdpath()
    local directory = path:match(".*/") or ""
    directory = directory:gsub("^.*[\\/]", "") -- Remove leading directory path

    -- Check if directory is empty and try extracting it differently
    if directory == "" then
        directory = path:match("^.*/([^/]+)/.*$") or ""
    end

    return directory .. "." .. filename
end

--- Reload the the specified lua module.
--- Useful to reload the files where you define your vim options, mappings...
--- Be aware depending how the module to load was written, the result might
--- not be as expected.
--- Example: some colorschemes might not look as expected if they were not prepared for this.
---@return boolean success True if the reload was successful, False otherwise.
function M.reload()
  local config = vim.g.hot_reload_config

  -- Reload options, mappings and plugins (this is managed automatically by lazy).
  -- To avoid issues, don't try to reload your autocmds file unless you are sure.
  local was_modifiable = vim.opt.modifiable:get()
  if not was_modifiable then vim.opt.modifiable = true end
  local core_modules = vim.g.hot_reload_config.reload_files
  local modules = vim.tbl_filter(
    function(module) return module:find "^user%." end,
    vim.tbl_keys(package.loaded)
  )

  vim.tbl_map(
    require("plenary.reload").reload_module,
    vim.list_extend(modules, core_modules)
  )
  local success = true
  for _, module in ipairs(core_modules) do
    module = M.filepath_to_module(module)
    local status_ok, fault = pcall(require, module)
    if not status_ok then
      vim.api.nvim_err_writeln("Failed to load " .. module .. "\n\n" .. fault)
      success = false
    end
  end
  if not was_modifiable then vim.opt.modifiable = false end

  -- notifications
  if config.notify then
    if success then
      M.notify("File hot reloaded.", vim.log.levels.INFO)
    else
      M.notify("Error hot reloading this file...", vim.log.levels.ERROR)
    end
  end

  return success
end

return M
