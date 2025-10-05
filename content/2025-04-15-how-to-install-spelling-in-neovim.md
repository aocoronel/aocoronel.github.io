+++
title = "How to Install Spelling in Neovim"
description = """Neovim does not have support for spelling other than English by default. Here are how you can get the required files to enable spelling in Neovim."""
date = 2025-04-14
[taxonomies]
categories = ["tech"]
tags = ["cli", "neovim", "how-to"]
+++

Neovim does not have support for spelling other than English by default. Here are how you can get the required files to enable spelling in Neovim.

<!-- more -->

Neovim does not have support for spelling other than English by default. Here are how you can get the required files to enable spelling in `neovim`.

You can find a list of dictionaries from LibreOffice at: [LibreOffice Extensions](https://extensions.libreoffice.org/?q=Dictionary&action_doExtensionSearch=Search).

A demonstration of the process can be seen below.

## Portuguese (Brazillian)

### Get Files

To install pt_BR spelling in `neovim` you will need to get the files. You can manually download the file at [LibreOffice - Português do Brasil Spellcheck](https://extensions.libreoffice.org/pt-BR/extensions/show/vero-verificador-ortografico-e-hifenizador-em-portugues_gGKns9tJ) or run the following command

```bash
wget https://extensions.libreoffice.org/assets/downloads/z/veroptbrv320aoc.oxt
```

The license from each dictionary may vary.

### Compile

The `.oxt` file is an archive, which can be unpacked using `zip` like this:

```bash
unzip veroptbrv320aoc.oxt
```

The result will be like this:

```text
├── description.xml
├── dialog
│   ├── OptionsDialog.xcs
│   ├── OptionsDialog.xcu
│   ├── pt_BR_pt_BR.default
│   ├── pt_BR_pt_BR.properties
│   └── pt_BR.xdl
├── dictionaries.xcu
├── hyph_pt_BR.dic
├── icons
│   └── VERO-logo.png
├── Lightproof.components
├── Lightproof.py
├── Linguistic.xcu
├── META-INF
│   └── manifest.xml
├── package-description.txt
├── pt_BR.aff
├── pt_BR.dic
├── pythonpath
│   ├── lightproof_handler_pt_BR.py
│   ├── lightproof_impl_pt_BR.py
│   ├── lightproof_opts_pt_BR.py
│   └── lightproof_pt_BR.py
├── README_en.txt
├── README_hyph_pt_BR.txt
├── README_Lightproof_pt_BR.txt
└── README_pt_BR.txt
```

Now, open `neovim` within the directory these files are present and run the following command: `mkspell pt pt_BR`. A new `.spl` file will be generated. In this case, it will look like this: `pt.utf-8.spl`.

### Usage

To enable your spelling you can do it in two interesting ways. Pick one:

1. Enable an Option
2. Create an Autocmd

#### Enable an Option

First, you will have to move your `.spl` file to `spell` folder within your `neovim` config, if you use LazyVim Distro, or you can set an option as well.

In your configuration file, you can add the following lines:

```lua
vim.opt.spell = true
vim.opt.encoding = "UTF-8"
vim.opt.spelllang = "pt,en_us" -- Optionally enable spell for both languages
vim.opt.spellfile="~/.config/neovim/spell/pt.utf-8.spl" -- Required if not using LazyVim
```

#### Enable an Autocmd

If you wish to only turn spelling on in specific files you can use an autocmd to turn spelling on in files like plain text and markdown. See an example:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spelllang = { "pt", "en_us" }
  end,
})
```

This will enable spelling on `text`, `plaintext`, interactive git commit messages and `markdown` filetypes.

## Tips

You can toggle the spelling with the `spell!` command, or set it to a binding like so:

```lua
vim.keymap.set("n", "<leader>ts", ":set spell!<CR>", { noremap = true, silent = true, desc = "Toggle: [S]pell" })
```
