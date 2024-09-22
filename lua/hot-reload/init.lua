-- This plugin reload nvim files given a event.

local M = {}

function M.setup(opts)
  require("hot-reload.config").set(opts)

  -- This plugin has no main function. We use a main autocmd.
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    desc = "Hot Reload  - reload a lua module is it's on `hot_reload_files` and the file is written.",
    callback = function()
      local config = vim.g.hot_reload_config
      local buf_path = vim.fn.expand("%:p")

      for _, file_path in ipairs(config.reload_files) do
        if file_path == buf_path then
          require("hot-reload.utils").reload()
          opts.reload_callback()
        end
      end
    end,
  })
end

return M
