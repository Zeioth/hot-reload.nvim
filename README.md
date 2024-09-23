# hot-reload.nvim
Reload your neovim config on the fly! It works with any lua file.

![screenshot_2024-03-10_23-20-38_444541684](https://github.com/Zeioth/distroupdate.nvim/assets/3357792/c86e1978-9095-4c50-9365-e130ff69a7d2)

<div align="center">
  <a href="https://discord.gg/ymcMaSnq7d" rel="nofollow">
      <img src="https://img.shields.io/discord/1121138836525813760?color=azure&labelColor=6DC2A4&logo=discord&logoColor=black&label=Join the discord server&style=for-the-badge" data-canonical-src="https://img.shields.io/discord/1121138836525813760">
    </a>
</div>

## Table of contents

- [Why](#why)
- [How to install](#how-to-install)
- [Available options](#available-options)
- [Example of a real config](#example-of-a-real-config)
- [FAQ](#faq)

## Why
If you use Neovim in multiple machines, you can use the command `:DistroUpdate`
to get the latest changes of your config from your GitHub repository from any
device.

If you are developing a Neovim distro, you can ship this plugin, and users will
get updates from your distro GitHub repository when they run `:DistroUpdate`.

### Warning
Running `:DistroUpdate` will overwrite any uncommited change in your
local nvim config.

## How to install
This plugin requires you to use lazy package manager

```lua
{
  "Zeioth/hot-reload.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  event = "BufEnter",
  opts = {}
}
```

## Available options
All options described here are 100% optional and you don't need to define them to use this plugin.

| Name                | Default value  | Description                                                                                                                                                          |
|---------------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **reload_files**         | `string[]`       | Table of paths for the files you want to hot-reload.  |
| **reload_callback**          | `function() end`          | (Optional) function with things to do after the files have hot reloaded. |
| **reload_all**     | `true`          | If true, all files in `reload_files` will hot-reload every time you write any of te files defined in `reload_files`, by order. If false, only the file you write will be reloaded. |
| **notify** | `true`| If true, a notification will be displayed when a file is hot-reloaded. |
| **event** | `BufWritePost`| (Optional) Event that trigger the hot-reload. Please don't change this unless you know what you are doing. |

## Example of a real config

```lua
-- hot-reload.nvim [distro update]
-- https://github.com/Zeioth/hot-reload.nvim
{
  "Zeioth/hot-reload.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufEnter",
  opts = function()
    local config_dir = vim.fn.stdpath("config") .. "/lua/base/"
    return {
      hot_reload_files = {
        -- Files to be hot-reloaded when modified.
        config_dir .. "1-options.lua",
        config_dir .. "4-mappings.lua"
      },
      -- Things to do after hot-reload trigger.
      hot_reload_callback = function()
        vim.cmd ":silent! doautocmd ColorScheme"                     -- heirline colorscheme reload event.
        vim.cmd(":silent! colorscheme " .. base.default_colorscheme) -- nvim     colorscheme reload command.
      end
    }
  end
},
```

## Credits
This GPL3 Neovim plugin has been developed for NormalNvim. It's based on the GPL3 hot reload snippet from AstroNvim v3. So please support both projects if you enjoy this plugin.

## FAQ
* **Is this plugin automatic?** Wip.
 
## Roadmap
* It would be a cool idea to allow specifying a callback per file to hot-reload. But it's unclear how many people would actually use this.
