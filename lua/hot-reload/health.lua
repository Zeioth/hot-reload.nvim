-- On neovim you can run
-- :chechealth distroupdate
-- To know possible causes in case distroupdate.nvim is not working correctly.

-- TODO: This plugin doesn't require dependencies, so just print everything is ok.

local M = {}

function M.check()
  vim.health.start("distroupdate.nvim")

  vim.health.info(
    "Neovim Version: v"
      .. vim.fn.matchstr(vim.fn.execute("version"), "NVIM v\\zs[^\n]*")
  )

  if vim.version().prerelease then
    vim.health.warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.10" == 1 then
    vim.health.ok "Using stable Neovim >= 0.10.0"
  else
    vim.health.error "Neovim >= 0.10.0 is required"
  end

  local programs = {
    {
      cmd = "git",
      type = "error",
      msg = "Having git installed is a hard requirement.",
    }
  }

  for _, program in ipairs(programs) do
    if type(program.cmd) == "string" then program.cmd = { program.cmd } end
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        found = true
        break
      end
    end

    if found then
      vim.health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      vim.health[program.type](
        ("`%s` is not installed: %s"):format(name, program.msg)
      )
    end
  end
end

return M
