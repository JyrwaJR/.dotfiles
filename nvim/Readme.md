# Neovim Configuration

This repository contains my Neovim configuration, optimized for development and productivity. Below are instructions on how to set up and use the configuration.

## Table of Contents

- [Clone the Repository](#clone-the-repository)
- [Requirements](#requirements)
- [Plugins](#plugins)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)

## Clone the Repository

### macOS / Linux

To get started, clone this repository to your local machine:

```sh
git clone https://github.com/JyrwaJR/nvim.git ~/.config/nvim
```

### Windows (CMD)

To get started, clone this repository to your local machine:

```sh
git clone https://github.com/JyrwaJR/nvim.git $HOME/AppData/Local/nvim
```

## Requirements

Make sure you have the following software installed:

- **Neovim**: Version 0.7 or higher.
- **LazyGit**: A tool for managing git repositories (not a plugin manager for Neovim).
- **Node.js**: Required for certain plugins and LSP servers.
- **Python**: Required for some plugins and language servers.
- **Ripgrep**: Required for some plugin functionalities.

You can install Neovim and other dependencies using your preferred package manager. For example, on Debian-based systems:

```sh
sudo apt update
sudo apt install neovim nodejs python3-pip ripgrep
pip3 install neovim
```

## Plugins

This configuration uses the `packer.nvim` plugin manager to handle plugins. Below is a list of the plugins included in this configuration:

### Core Plugins

- **nvim-lspconfig**: Configurations for built-in LSP support.
- **nvim-cmp**: Autocompletion plugin with various sources.
- **telescope.nvim**: Fuzzy finder for files, buffers, and more.
- **nvim-treesitter**: Improved syntax highlighting and code understanding.
- **lualine.nvim**: A statusline plugin written in Lua.
- **gitsigns.nvim**: Git integration for Neovim.

### Optional Plugins

- **dressing.nvim**: Enhanced UI for user inputs and selections.
- **noice.nvim**: UI for messages, cmdline, and popups.
- **inc-rename.nvim**: Incremental renaming with preview.

Add or remove plugins as needed by modifying the `packer.nvim` setup in your `init.lua` or `init.vim` file.

## Customization

You can customize the configuration to fit your workflow by editing the `~/.config/nvim/lua/config/` directory. Key files to modify include:

- **`keymaps.lua`**: Customize key mappings.
- **`plugins.lua`**: Add or remove plugins.
- **`lsp.lua`**: Configure LSP servers and settings.
- **`settings.lua`**: General Neovim settings and options.

## Contributing

If you would like to contribute to this configuration, please submit a pull request with your changes. Make sure to include a description of the changes and any relevant details.

## License

This configuration is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

---

Feel free to adjust the sections and content based on your specific setup and preferences. This template should provide a good starting point for documenting your Neovim configuration.
