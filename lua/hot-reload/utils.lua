--- ### General utils
--
--  DESCRIPTION:
--  General utility functions.

--    Helpers
--      -> with_modifiable_buffer → Run a block of code with modifiable true.
--      -> notify                 → Send a notification with the plugin title.

--    Functions:
--      -> notify_reload          → Notify the list of reloaded modules.
--      -> filepath_to_module     → Converts a file path to module name.
--      -> reload                 → Hot reloads only the current specified file.
--      -> reload_all             → Hot reloads all specified files (by order).

local M = {}

--- Helper to temporarily make the buffer modifiable and restore its original state.
--- The code inside the function passed in the callback, will always have
--- `vim.opt.modifiable = true`.
--- @param callback function Function to execute with modifiable state.
local function with_modifiable_buffer(callback)
  local is_modifiable = vim.opt.modifiable:get()
  if not is_modifiable then vim.opt.modifiable = true end
  callback() -- run function passed as parameter.
  if not is_modifiable then vim.opt.modifiable = false end
end

--- Serve a notification with a default title.
--- @param msg string The notification body.
--- @param type number|nil The type of the notification (:help vim.log.levels).
--- @param opts? table The nvim-notify options to use (:help notify-options).
local function notify(msg, type, opts)
  vim.schedule(
    function()
      vim.notify(
        msg,
        type,
        vim.tbl_deep_extend("force", { title = "Hot-Reload.nvim" }, opts or {})
      )
    end
  )
end

--- Helper to notify the result of the reload.
--- @param success boolean Whether the reload was successful.
--- @param file_list table List of files/modules.
--- @param message string Base message to show.
local function notify_reload(success, file_list, message)
  local formatted_list = table.concat(
    vim.tbl_map(function(module) return "- `" .. module .. "`" end, file_list),
    "\n"
  )

  local log_level = success and vim.log.levels.INFO or vim.log.levels.ERROR
  notify(message .. "\n" .. formatted_list, log_level)
end

--- Given a path, return its nvim module.
--- @param path string Path of a file inside your nvim config directory.
--- @return string module A string which is the module of the file path.
--- @example  filepath_to_module(/home/user/.config/nvim/lua/base/1-options.lua)  -- returns "base.1-options"
local function filepath_to_module(path)
  local filename = path:gsub("^.*[\\/]", "") -- Remove leading directory path
  filename = filename:gsub("%..+$", "")      -- Remove file extension
  filename = filename:gsub("/", ".")         -- Replace '/' with '.'

  -- Extract directory name when constructed using vim.fn.stdpath()
  local directory = path:match(".*/") or ""
  directory = directory:gsub("^.*[\\/]", "") -- Remove leading directory path

  -- Check if directory is empty and try extracting it differently
  if directory == "" then directory = path:match("^.*/([^/]+)/.*$") or "" end

  return directory .. "." .. filename
end

--- Reload a specified lua module.
--- @param path string? File path of the module to reload.
--- @return boolean success True if the reload was successful, False otherwise.
function M.reload(path)
  if not path then return false end

  local config = vim.g.hot_reload_config
  local success = false

  -- code inside this block, will always have modification permissions.
  with_modifiable_buffer(function()
    local module = filepath_to_module(path)
    local status_ok, _ = pcall(require("plenary.reload").reload_module, module)
    success = status_ok
  end)

  if config.notify then
    local message = success and "File hot reloaded successfully:"
        or "Error hot reloading file:"
    notify_reload(success, { path }, message)
  end

  return success
end

--- Reload all files specified in `config.reload_files`.
--- Modules that fail to load will be notified.
--- @return boolean success True if all modules were successfully reloaded, False otherwise.
function M.reload_all()
  local config = vim.g.hot_reload_config
  local success_modules = {} -- Track successfully reloaded modules
  local failed_modules = {}  -- Track failed modules

  -- code inside this function, will always have modification permissions.
  with_modifiable_buffer(function()
    for _, module_path in ipairs(config.reload_files) do
      local module = filepath_to_module(module_path)
      local status_ok, _ =
          pcall(require("plenary.reload").reload_module, module)
      if status_ok then
        table.insert(success_modules, module_path)
      else
        table.insert(failed_modules, module_path)
      end
    end
  end)

  if config.notify then
    if #success_modules > 0 then
      notify_reload(true, success_modules, "Files hot reloaded successfully:")
    end
    if #failed_modules > 0 then
      notify_reload(
        false,
        failed_modules,
        "Error hot reloading the following files:"
      )
    end
  end

  -- Return true if all modules were successfully reloaded, false otherwise.
  local success = #failed_modules == 0
  return success
end

return M
