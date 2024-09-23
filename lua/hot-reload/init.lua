-- This plugin hot reload the specified lua files given an event.

local M = {}

function M.setup(opts)
  require("hot-reload.config").set(opts)

  -- The entry point of this plugin, is this autocmd.
  vim.api.nvim_create_autocmd({ vim.g.hot_reload_config.event  }, {
    desc = "Hot Reload  - Reload a lua module is it's on `hot_reload_files` and the file is written",
    callback = function()
      local config = vim.g.hot_reload_config
      local buf_path = vim.fn.expand("%:p")

      -- For each file in config.reload_files.
      for _, file_path in ipairs(config.reload_files) do
        if file_path == buf_path then
          if config.reload_all then
            -- Reload all hot reloadable files.
            require("hot-reload.utils").reload_all()
          else
            -- Reload only the current file.
            require("hot-reload.utils").reload(file_path)
          end

          -- Then run the callback, if the user defined it.
          opts.reload_callback()
        end
      end
    end,
  })
end

return M
