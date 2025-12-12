# Neovim Config

This is a very lightweight configuration, mostly for developing and text editing purposes. The main philosophy behind this config, is to keep it the most tiny and fast as possible.

> You may also be interested in my [emacs](https://github.com/aocoronel/emacs) config, which follows the same philosophy.

This config uses the builtin Neovim package manager. All plugin configuration is done in `init.lua`.

This config is also very peculiar: Emacs bindings are a thing, no treesitter, no telescope, no statusline customization, no mason.

Try it! It should not take 10 seconds.

```console
git clone https://github.com/aocoronel/nvim nvim_config
nvim -u nvim_config/init.lua
```

A list with all plugins (no dependencies) in this configuration can be found below:

```console
● blink.cmp
● catppuccin
● compile-mode.nvim
● conform.nvim
● multicursor.nvim
● nvim-lspconfig
```

## History

This config is made from scratch. This was first part of my dotfiles repository, then I ported it to the LazyVim distro. Unsatisfied with the bloated defaults I walked back, and now I enjoy a faster and to the point experience, even without lazy loading.
