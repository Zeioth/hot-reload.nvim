> ![WARNING]
>  The plugin works fine but I'm still writing the readme and the docs, so please be patient for the next 48h.

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
- [Available commands](#available-commands)
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
  "Zeioth/distroupgrade.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  event = "VeryLazy",
  opts = {}
}
```

## Available commands

| Command                          | Description                                                                                             |
|----------------------------------|---------------------------------------------------------------------------------------------------------|
| **:DistroUpdate**                | If the value of the option `channel` is `stable`, it will update from the latest available released version of the `remote` of the git repository of your nvim config. If the value of `channel` is `nightly`, it will update from the latest changes in the branch `nightly` of the git repository of your nvim config. |
| **:DistroUpdateRevert**          | Uses git to bring your config to the state it had before running `:DistroUpdate`.                        |
| **:DistroFreezePluginVersions**  | Saves your current plugin versions into `lazy_versions.lua` in your config directory. You can import this file and pass it to your lazy config, so it respects your locked versions. [Check the option `spec` in lazy](https://github.com/folke/lazy.nvim). |
| **:DistroReadVersion**           | Prints the commit number of the current distro version.                                                  |
| **:DistroReadChangelog**         | Prints the changelog.                                                                                    |

## Available options
All options described here are 100% optional and you don't need to define them to use this plugin.

### Updater options
Options to configure what version/commit will be downloaded.

| Name                | Default value  | Description                                                                                                                                                          |
|---------------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **channel**         | `stable`       | Channel used by the command `:DistroUpdate`. `stable` will update the distro from the latest available released version of your git repository. `nightly` will update the distro from the nightly branch of your git repository. |
| **commit**          | `nil`          | If this option is specified, it will prevail over `release_tag` and `channel`.                                                                                        |
| **release_tag**     | `nil`          | If this option is specified, it will prevail over `channel`. The format must be semantic versioning, like: `"v1.0"`.                                                  |
| **remote** | `origin`| If you have multiple remotes, you can specify the one to use with this option. |

### Updater UX options
Options to configure what happen during the update.

| Name                          | Default value  | Description                                                                                                                          |
|-------------------------------|----------------|--------------------------------------------------------------------------------------------------------------------------------------|
| **overwrite_uncommitted_local_changes** | `true`         | If true, uncommitted local changes will be lost. If false, the update will fail with an error.                                        |
| **update_plugins**             | `true`         | If true, after `:DistroUpdate`, plugins will update automatically before closing Neovim. If false, you will have to update them manually using lazy. |
| **on_update_show_changelog**   | `true`         | If true, after `:DistroUpdate`, the changes of the new version will be displayed.                                                     |
| **on_update_auto_quit**        | `false`         | If true, after `:DistroUpdate`, Neovim will close automatically. If false, you will have to close it manually to ensure stability.     |
| **auto_accept_prompts**        | `false`         | If true, all prompts in `:DistroUpdate` will be accepted automatically.                                                              |

### Versioning options
Options to configure where to store the plugins file and the rollback file.

| Name              | Default value                                  | Description                                                                 |
|-------------------|------------------------------------------------|-----------------------------------------------------------------------------|
| **snapshot_file**  | `<nvim_config_dir>/lua/lazy_snapshot.lua`      | File used by the command `:DistroFreezePluginVersions` to write the plugins. |
| **rollback_file**  | `<nvim_cache_dir>/rollback.lua`                | Rollback file automatically triggered by `:DistroUpdate`. This file will be used when you use `:DistroUpdateRevert`. |

### Hot reload options
Options to configure the extra feature `hot reload`.

| Name                 | Default value              | Description                                                                                                                          |
|----------------------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| **hot_reload_files**  | `{}`                       | The files included will be hot reloaded every time you write them. This way you can see the changes in your config reflected without having to restart nvim. For example: `{ my_nvim_opts_file, my_nvim_mappings_file}`. Be aware this feature is experimental, and might not work in all cases yet. |
| **hot_reload_callback** | `function() end`         | (optional) Extra things to do after the files defined in the option `hot_reload_files` are reloaded. For example: This can be handy if you want to re-apply your theme. |

## Example of a real config

```lua
-- distroupdate.nvim [distro update]
-- https://github.com/Zeioth/distroupdate.nvim
{
  "Zeioth/distroupdate.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  opts = function()
    local config_dir = vim.fn.stdpath "config" .. "/lua/base/"
    return {
      remote = "origin",
      channel = "stable",                                             -- stable/nightly.
      release_tag = nil,                                              -- in case you wanna freeze a specific distro version.
      hot_reload_files = {
        config_dir .. "1-options.lua",
        config_dir .. "4-mappings.lua"
      },
      hot_reload_callback = function()
        vim.cmd ":silent! doautocmd ColorScheme"                     -- heirline colorscheme reload event.
        vim.cmd(":silent! colorscheme " .. base.default_colorscheme) -- nvim     colorscheme reload command.
      end
    }
  end
},
```

## How to pass the plugins file to lazy
If you've used `:DistroFreezePluginVersions` you have to pass the generated file to lazy, so it can use it. For that use the `spec` option. You can find an example [here](https://github.com/NormalNvim/NormalNvim/blob/main/lua/base/2-lazy.lua).

## Credits
The GPL3 lua libraries this plugin use come from NormalNvim (Full rewrite) and AstroNvim (Foundation and git wrapper).
So please support both projects if you enjoy this plugin.

## FAQ
* **Is this plugin automatic?** NO. This plugin will do nothing unless you run one of its commands.
* **Where do the updates come from?** From your own git repo. You are the only one in control.
* **Why not just using lazy alone?** If lazy covers your case of use, that's totally fine. But there will be scenarios where you are gonna need distroupdate.

## Roadmap
* It would be ideal to write unit tests to ensure we don't introduce regressions or breaking changes in future versions.
* It would be cleaner to move `hot_reload` to a new plugin whith that sole responsability.
