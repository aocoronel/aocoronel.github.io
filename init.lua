pack_ok, pack_err = pcall(vim.pack.add, {
    "https://github.com/catppuccin/nvim",
    "https://github.com/ej-shafran/compile-mode.nvim", -- depends on baleia, plenary
    "https://github.com/neovim/nvim-lspconfig", -- depends on blink
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/stevearc/conform.nvim",
    { src = "https://github.com/jake-stewart/multicursor.nvim", version = "1.0" },
    { src = "https://github.com/m00qek/baleia.nvim", version = "v1.3.0" },
    { src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
})

if not pack_ok then
    vim.notify(
        "vim.pack: some plugins failed to install. Run :lua vim.pack.update() to retry.\n" .. pack_err,
        vim.log.levels.WARN
    )
end

opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
vim.g.autoformat = true
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
vim.g.deprecation_warnings = false

opt.autochdir = true
opt.autowrite = true -- Enable auto write
opt.backspace = "indent,eol,start"
opt.backup = false
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.cmdheight = 1
opt.colorcolumn = "100"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.encoding = "UTF-8"
opt.errorbells = false
opt.expandtab = true -- Use spaces instead of tabs
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldtext = ""
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "grep -rn"
opt.hidden = true
opt.hlsearch = true
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.incsearch = true
opt.iskeyword:append "-"
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.modifiable = true
opt.mouse = "a" -- Enable mouse mode
opt.number = false -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = false -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append { W = true, I = true, c = true, C = true }
opt.showmode = true
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.softtabstop = 2
opt.spell = false
opt.spelllang = "pt,en_us"
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.swapfile = false
opt.tabstop = 4 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.undodir = os.getenv "HOME" .. "/.local/share/vim/undodir"
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

vim.o.breakindent = true
vim.o.statusline = "%#StatusLine#%f %m%r%h%w%=(%l,%c/%L) %P"
vim.o.timeout = true
vim.o.timeoutlen = 1000 -- 1 second to chain bindings
vim.o.updatetime = 500

vim.diagnostic.enable = true
vim.diagnostic.config {
    virtual_lines = false,
}

autocmd = vim.api.nvim_create_autocmd
augroup = function(name) return vim.api.nvim_create_augroup("_vim_" .. name, { clear = true }) end

autocmd({ "CursorHold", "CursorHoldI" }, {
    group = augroup "auto lsp pop up",
    callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})

autocmd({ "BufWritePre" }, {
    group = augroup "remove_leading_spaces",
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd("TextYankPost", {
    group = augroup "highlight-yank",
    callback = function() vim.hl.on_yank() end,
})

autocmd("FileType", {
    group = augroup "write_utils_for_text",
    pattern = { "text", "plaintex", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.spelllang = { "pt", "en_us" }
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

autocmd({ "VimResized" }, {
    group = augroup "resize_splits",
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd "tabdo wincmd ="
        vim.cmd("tabnext " .. current_tab)
    end,
})

autocmd("BufReadPost", {
    group = augroup "last_loc",
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then return end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
    end,
})

autocmd("FileType", {
    group = augroup "close_with_q",
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd "close"
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

autocmd("FileType", {
    group = augroup "man_unlisted",
    pattern = { "man" },
    callback = function(event) vim.bo[event.buf].buflisted = false end,
})

autocmd({ "FileType" }, {
    group = augroup "json_conceal",
    pattern = { "json", "jsonc", "json5" },
    callback = function() vim.opt_local.conceallevel = 0 end,
})

autocmd({ "BufWritePre" }, {
    group = augroup "auto_create_dir",
    callback = function(event)
        if event.match:match "^%w%w+:[\\/][\\/]" then return end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

require("multicursor-nvim").setup()

vim.g.compile_mode = {
    default_command = {
        python = "python %",
        lua = "lua %",
        odin = "odin run % -file",
        sh = "sh %",
        c = "cc -o %:r % && ./%:r",
    },
    baleia_setup = true,
    bang_expansion = true,
    error_regexp_table = {},
    error_ignore_file_list = {},
    error_threshold = require("compile-mode").level.WARNING,
    auto_jump_to_first_error = false,
    error_locus_highlight = 500,
    use_diagnostics = false,
    recompile_no_fail = true,
    ask_about_save = true,
    ask_to_interrupt = false,
    buffer_name = "*compilation*",
    time_format = "%a %b %e %H:%M:%S",
    hidden_output = {},
    environment = nil,
    clear_environment = false,
    input_word_completion = true,
    hidden_buffer = false,
    focus_compilation_buffer = false,
    auto_scroll = true,
    use_circular_error_navigation = true,
    debug = false,
    use_pseudo_terminal = false,
}

require("blink.cmp").setup {
    keymap = {
        preset = "none",
        ["<CR>"] = { "accept", "fallback" },
        ["<M-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<M-n>"] = { "select_next", "fallback_to_mappings" },
        ["<M-b>"] = { "scroll_documentation_up", "fallback" },
        ["<M-f>"] = { "scroll_documentation_down", "fallback" },
    },
    appearance = {
        nerd_font_variant = "mono",
    },
    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },
}

require("conform").setup {
    notify_on_error = false,
    default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
    },
    formatters_by_ft = {
        bash = { "shfmt" },
        c = { "clang-format" },
        odin = { "odinfmt" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "black" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        toml = { "taplo" },
        zsh = { "shfmt" },
        zig = { "zig fmt" },
    },
    formatters = {
        injected = { options = { ignore_errors = true } },
        odinfmt = {
            command = "odinfmt",
            args = { "-stdin" },
            stdin = true,
        },
    },
}

lspconfig = vim.lsp
capabilities = require("blink.cmp").get_lsp_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
        map("gri", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
                end,
            })
        end

        if client then
            map(
                "<leader>th",
                function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
                "[T]oggle Inlay [H]ints"
            )
        end
    end,
})

vim.diagnostic.config {
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    } or {},
    virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
}

basic_lsp = function(lsp_name, ft)
    lspconfig.enable(lsp_name)
    lspconfig.config(lsp_name, {
        filetypes = { ft },
        capabilities = capabilities,
    })
end

basic_lsp("zls", "zig")
basic_lsp("ols", "odin")
basic_lsp("rust_analyzer", "rust")

-- C/C++
lspconfig.enable "clangd"
lspconfig.config("clangd", {
    capabilities = {
        capabilities,
        offsetEncoding = { "utf-8" },
    },
    textDocument = {
        completion = {
            editsNearCursor = true,
        },
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja",
        ".git",
    },
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
})

hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { reverse = true })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

elegantvagrant = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f067fc",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#20dbfc",
    sapphire = "#74c7ec",
    blue = "#5ffcfc",
    lavender = "#b4befe",
    text = "#d9d9d9",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#191919",
    surface0 = "#121311",
    base = "#000000",
    mantle = "#090909",
    crust = "#111111",
}

elegantvagrant_highlights = function(colors)
    return {
        LineNr = { fg = "#393939" },
        CursorLineNr = { fg = colors.subtext1, bold = true },
        Comment = { fg = colors.maroon },
    }
end

require("catppuccin").setup {
    flavour = "mocha",
    background = {
        light = "mocha",
        dark = "mocha",
    },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = {
        enabled = false,
    },
    no_italic = true,
    no_bold = false,
    no_underline = true,
    -- Comment to turn on hard-coded styles
    styles = {
        comments = {},
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        miscs = {},
    },
    default_integrations = false,
    auto_integrations = false,
    custom_highlights = elegantvagrant_highlights,
    color_overrides = {
        mocha = elegantvagrant,
    },
}

vim.cmd.colorscheme "catppuccin-mocha"

map = function(map, lhs, rhs, opts) vim.keymap.set(map, lhs, rhs, opts) end -- Any map

imap = function(lhs, rhs, opts) vim.keymap.set("i", lhs, rhs, opts) end -- Insert map

nmap = function(lhs, rhs, opts) vim.keymap.set("n", lhs, rhs, opts) end -- Normal map

vmap = function(lhs, rhs, opts) vim.keymap.set("v", lhs, rhs, opts) end -- Visual map

map_keep_line = function(map, lhs, normal_cmd, opts)
    opts = opts or {}
    vim.keymap.set(map, lhs, function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd("normal! " .. normal_cmd)
        vim.api.nvim_win_set_cursor(0, pos)
    end, opts)
end

-- Keep cursor position after action
imap_keep_line = function(lhs, normal_cmd, opts) map_keep_line("i", lhs, normal_cmd, opts) end
vmap_keep_line = function(lhs, normal_cmd, opts) map_keep_line("v", lhs, normal_cmd, opts) end
nmap_keep_line = function(lhs, normal_cmd, opts) map_keep_line("n", lhs, normal_cmd, opts) end
emap = function(map, lhs, normal_cmd, opts)
    opts = opts or {}
    vim.keymap.set(map, lhs, function() vim.cmd("normal! " .. normal_cmd) end, opts)
end
eimap = function(lhs, normal_cmd) emap("i", lhs, normal_cmd, { noremap = true, silent = true }) end
evmap = function(lhs, normal_cmd) emap("v", lhs, normal_cmd, { noremap = true, silent = true }) end
eimap_keep_line = function(lhs, normal_cmd) imap_keep_line(lhs, normal_cmd, { noremap = true, silent = true }) end

-- Emacs-like cancel
map("c", "<C-g>", "<C-c>", { noremap = true, silent = true })

-- Open terminal in CWD
nmap("<leader>tt", function()
    local cwd = vim.fn.getcwd()
    os.execute("cd " .. cwd .. " && st &")
end, { desc = "Open st in current directory" })

config = { virtual_text = false, signs = false, underline = false }
vim.keymap.set("n", "<leader>tv", function()
    config.virtual_text = not config.virtual_text
    vim.diagnostic.config(config)
end)

isearch_selected = function()
    vim.cmd 'normal! "ly'
    vim.api.nvim_feedkeys("/", "n", false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-r>"<CR>', true, false, true), "n", false)
end

get_selection = function()
    local s_start = vim.fn.getpos "."
    local s_end = vim.fn.getpos "v"
    local lines = vim.fn.getregion(s_start, s_end)
    return lines
end

ripgrep_selected = function()
    local selection = get_selection()
    local text = vim.fn.escape(selection[1], [[\/]])

    require("compile-mode").compile {
        args = "grep -rn " .. text,
    }
end

vmap("<leader>r", function() ripgrep_selected() end, { desc = "Ripgrep selected" })

vmap("<leader>s", function() isearch_selected() end, {
    desc = "Search yanked text forward",
})

nmap("<leader><tab>s", ":source %<CR>", { desc = "Source lua file" })

-- How to quit nvim?

nmap("<leader>qq", "<CMD>qa<CR>", { desc = "Quit All" })
nmap("<leader>qQ", "<CMD>qa!<CR>", { desc = "Quit All (No Save)" })

-- Emacs-like insert mode keybindings

--- Motions

map({ "n", "i", "v" }, "<C-b>", "<Left>", { noremap = true }) -- backward char
map({ "n", "i", "v" }, "<C-p>", "<Up>", { noremap = true }) -- previous line
map({ "n", "i", "v" }, "<C-n>", "<Down>", { noremap = true }) -- next line
map({ "n", "i", "v" }, "<C-f>", "<Right>", { noremap = true }) -- forward char

map({ "n", "i", "v" }, "<C-a>", "<Home>", { noremap = true }) -- beginning of line
map({ "n", "i", "v" }, "<C-e>", "<End>", { noremap = true }) -- end of line

-- eimap("<C-v>", "11jzz") -- Move half page down
-- eimap("<M-v>", "11kzz") -- Move half page up

emap({ "n", "i", "v" }, "<M-f>", "w") -- forward word
emap({ "n", "i", "v" }, "<M-b>", "b") -- backward word
emap({ "n", "i", "v" }, "<M-a>", "<C-o>(") -- move to start of sentence
emap({ "n", "i", "v" }, "<M-e>", "<C-o>)") -- move to end of sentence
emap({ "n", "i", "v" }, "<M-<LT>>", "gg") -- move to start of buffer M-<
emap({ "n", "i", "v" }, "<M-<GT>>", "G") -- move to end of buffer M->

nmap("s", "/", { desc = "Isearch" })

eimap("<C-/>", "u") -- undo
eimap("<C-\\>", "<C-r>") -- redo

imap("<C-s>", "<C-o>/", { noremap = true }) -- search
vmap("<C-x>s", 'y/<C-r>"<CR>', { noremap = true }) -- search selection

imap("<M-x>", "<C-o>:", { noremap = true }) -- IDO?

imap("<C-d>", "<Del>", { noremap = true }) -- Delete next char
eimap_keep_line("<C-k>", "d$l") -- kill to end of line
eimap("<M-k>", "dd") -- kill line

eimap_keep_line("<C-t>", "xpi") -- transpose chars
eimap_keep_line("<M-t>", "daWWPi") -- transpose words

eimap_keep_line("<M-d>", "de") -- Delete word forward

eimap("<M-BS>", "db") -- kill word backward

eimap("<M-u>", "gUiww") -- upcase word
eimap("<M-l>", "guiww") -- downcase word
eimap("<M-c>", "gewguiwvgUw") -- capitalize word

imap("<C-_>", "<C-o>u", { noremap = true }) -- undo
imap("<C-\\>", "<C-o><C-r>", { noremap = true }) -- redo

-- Visual

imap("<C-Space>", "<Esc>lv") -- Insert to Visual Mode
vmap("<C-Space>", "<Esc>i") -- Visual to Insert Mode

eimap("<C-y>", "p") -- yank
vmap("<C-y>", "pi") -- yank
vmap("<C-w>", "c") -- kill
vmap("<M-w>", "yi") -- copy

-- Move current line up
imap("<M-p>", function()
    vim.cmd "m .-2"
    vim.cmd "normal! =="
end, { silent = true })

-- Move current line down
imap("<M-n>", function()
    vim.cmd "m .+1"
    vim.cmd "normal! =="
end, { silent = true })

-- Duplicate line
imap_keep_line("<M-,>", "yyP", { silent = true })

nmap("<C-d>", "<C-d>zz", { desc = "Page Down and Center" }) -- Better Page Move: Page Down and Center
nmap("<C-u>", "<C-u>zz", { desc = "Page Up and Center" }) -- Better Page Move: Page Up and Center

nmap("<M-h>", ":cprev<CR>", { desc = "Previous QuickFix" })
nmap("<M-l>", ":cnext<CR>", { desc = "Next QuickFix" })

nmap("<leader>cx", ":!chmod +x %<CR>", { desc = "Make Executable" })

nmap("<leader>ts", ":set spell!<CR>", { noremap = true, silent = true, desc = "Toggle: [S]pell" })

nmap("N", "Nzzzv", { desc = "Previous and center" })
nmap("n", "nzzzv", { desc = "Next and center" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
nmap("n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
nmap("N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

vmap("<leader>sS", ":!sort<CR>", { desc = "Sort" })

nmap("<leader>ss", ":%s/", { desc = "Search & Replace" })
vmap("<leader>ss", ":s/", { desc = "Search & Replace" })

vmap("J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move line down" })
vmap("K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move line up" })

nmap("<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
nmap("<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
nmap("<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
nmap("<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

nmap("<C-Up>", "<CMD>resize +2<CR>", { desc = "Increase Window Height" })
nmap("<C-Down>", "<CMD>resize -2<CR>", { desc = "Decrease Window Height" })
nmap("<C-Left>", "<CMD>vertical resize -2<CR>", { desc = "Decrease Window Width" })
nmap("<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase Window Width" })

nmap("<A-Tab>", "<CMD>:b#<CR>", { desc = "Last buffer" })
nmap("<S-h>", "<CMD>bprevious<CR>", { desc = "Prev Buffer" })
nmap("<S-l>", "<CMD>bnext<CR>", { desc = "Next Buffer" })
nmap("<leader>bD", "<CMD>:bd<CR>", { desc = "Delete Buffer and Window" })
nmap("<leader>bb", "<CMD>e #<CR>", { desc = "Switch to Other Buffer" })
nmap("[b", "<CMD>bprevious<CR>", { desc = "Prev Buffer" })
nmap("]b", "<CMD>bnext<CR>", { desc = "Next Buffer" })

nmap("<leader>O", ":%bdelete|edit#<CR>", { desc = "Kill all buffers" })
nmap("<leader>o", "<CMD>only<CR>", { desc = "Kill all panes" })

nmap(
    "<leader>ur",
    "<CMD>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" }
)

nmap("<leader>K", "<CMD>norm! K<CR>", { desc = "manpage" })

vmap("<", "<gv", { desc = "Indenting keeps position" })
vmap(">", ">gv", { desc = "Indenting keeps position" })

nmap("gco", "o<esc>Vcx<esc><CMD>normal gcc<CR>fxa<bs>", { desc = "Add Comment Below" })
nmap("gcO", "O<esc>Vcx<esc><CMD>normal gcc<CR>fxa<bs>", { desc = "Add Comment Above" })

nmap("<leader>fn", "<CMD>enew<CR>", { desc = "New File" })

nmap("<leader>xl", function()
    local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
    if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

nmap("<leader>xq", function()
    local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
    if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

nmap("[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
nmap("]q", vim.cmd.cnext, { desc = "Next Quickfix" })

diagnostic_goto = function(next, severity)
    return function()
        vim.diagnostic.jump {
            count = (next and 1 or -1) * vim.v.count1,
            severity = severity and vim.diagnostic.severity[severity] or nil,
            float = true,
        }
    end
end
nmap("<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
nmap("]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
nmap("[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
nmap("]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
nmap("[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
nmap("]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
nmap("[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- tabs
nmap("<leader><tab>l", "<CMD>tablast<CR>", { desc = "Last Tab" })
nmap("<leader><tab>o", "<CMD>tabonly<CR>", { desc = "Close Other Tabs" })
nmap("<leader><tab>f", "<CMD>tabfirst<CR>", { desc = "First Tab" })
nmap("<leader><tab>n", "<CMD>tabnew<CR>", { desc = "New Tab" })
nmap("<leader><tab>]", "<CMD>tabnext<CR>", { desc = "Next Tab" })
nmap("<leader><tab>d", "<CMD>tabclose<CR>", { desc = "Close Tab" })
nmap("<leader><tab>[", "<CMD>tabprevious<CR>", { desc = "Previous Tab" })

---- Plugins ----

nmap("<leader>Dj", "<CMD>Ex<CR>", { desc = "Ex" })
nmap("<leader>Dh", "<CMD>Ex ~/<CR>", { desc = "Ex: Home" })
nmap("<leader>Dn", "<CMD>Ex ~/.config/nvim<CR>", { desc = "Ex: Nvim" })
nmap("<leader>C", "<CMD>Compile<CR>", { desc = "Compile" })

nmap("<leader>ca", "<cmd>ScissorsAddNewSnippet<cr>", { desc = "[S]nippet [A]dd" })
nmap("<leader>ce", "<cmd>ScissorsEditSnippet<cr>", { desc = "[S]nippet [E]dit" })

multicursor = require "multicursor-nvim"
map({ "n", "x" }, "<C-<>", function() multicursor.matchAddCursor(1) end)
map({ "n", "x" }, "<C->>", function() multicursor.matchAddCursor(-1) end)

-- Add or skip cursor above/below the main cursor.
map({ "n", "x" }, "<up>", function() multicursor.lineAddCursor(-1) end)
map({ "n", "x" }, "<down>", function() multicursor.lineAddCursor(1) end)
map({ "n", "x" }, "<leader><up>", function() multicursor.lineSkipCursor(-1) end)
map({ "n", "x" }, "<leader><down>", function() multicursor.lineSkipCursor(1) end)

-- Add or skip adding a new cursor by matching word/selection
map({ "n", "x" }, "<A-C-j>", function() multicursor.matchAddCursor(1) end)
map({ "n", "x" }, "<C-h>", function() multicursor.matchSkipCursor(1) end)
map({ "n", "x" }, "<A-C-k>", function() multicursor.matchAddCursor(-1) end)
map({ "n", "x" }, "<C-l>", function() multicursor.matchSkipCursor(-1) end)

map("x", "S", multicursor.splitCursors) -- Split visual selections by regex.

map("x", "M", multicursor.matchCursors) -- match new cursors within visual selections by regex.

map("n", "<leader>gv", multicursor.restoreCursors, { desc = "Restore Cursors" }) -- bring back cursors if you accidentally clear them

map({ "n", "x" }, "<leader>A", multicursor.matchAllAddCursors) -- Add a cursor for all matches of cursor word/selection in the document.

map("x", "<leader>t", function() multicursor.transposeCursors(1) end) -- Rotate the text contained in each visual selection between cursors.
map("x", "<leader>T", function() multicursor.transposeCursors(-1) end)

-- Append/insert for each line of visual selections.
map("x", "I", multicursor.insertVisual) -- Similar to block selection insertion.
map("x", "A", multicursor.appendVisual)

map({ "n", "x" }, "g<c-a>", multicursor.sequenceIncrement) -- Increment/decrement sequences, treating all cursors as one sequence.
map({ "n", "x" }, "g<c-x>", multicursor.sequenceDecrement)

map("n", "<leader>/n", function() multicursor.searchAddCursor(1) end) -- Add a cursor and jump to the next/previous search result.
map("n", "<leader>/N", function() multicursor.searchAddCursor(-1) end)

map("n", "<leader>/s", function() multicursor.searchSkipCursor(1) end) -- Jump to the next/previous search result without adding a cursor.
map("n", "<leader>/S", function() multicursor.searchSkipCursor(-1) end)

map("n", "<leader>/A", multicursor.searchAllAddCursors) -- Add a cursor to every search result in the buffer.

-- Pressing `<leader>miwap` will create a cursor in every match of the
-- string captured by `iw` inside range `ap`.
-- This action is highly customizable, see `:h multicursor-operator`.
map({ "n", "x" }, "<leader>m", multicursor.operator)

map({ "n", "x" }, "]d", function() multicursor.diagnosticAddCursor(1) end) -- Add or skip adding a new cursor by matching diagnostics.
map({ "n", "x" }, "[d", function() multicursor.diagnosticAddCursor(-1) end)
map({ "n", "x" }, "]s", function() multicursor.diagnosticSkipCursor(1) end)
map({ "n", "x" }, "[S", function() multicursor.diagnosticSkipCursor(-1) end)

-- Press `mdip` to add a cursor for every error diagnostic in the range `ip`.
map({ "n", "x" }, "md", function()
    -- See `:h vim.diagnostic.GetOpts`.
    multicursor.diagnosticMatchCursors { severity = vim.diagnostic.severity.ERROR }
end)

multicursor.addKeymapLayer(function(layerSet)
    -- Select a different cursor as the main one.
    layerSet({ "n", "x" }, "<left>", multicursor.prevCursor)
    layerSet({ "n", "x" }, "<right>", multicursor.nextCursor)

    -- Delete the main cursor.
    layerSet({ "n", "x" }, "<leader>x", multicursor.deleteCursor)

    -- Enable and clear cursors using escape.
    layerSet("n", "<esc>", function()
        if not multicursor.cursorsEnabled() then
            multicursor.enableCursors()
        else
            multicursor.clearCursors()
        end
    end)
end)

nmap("<leader>cf", function() require("conform").format() end, {
    desc = "Format buffer using conform",
})

toggles = {
    ["true"] = "false",
    ["false"] = "true",
    ["True"] = "False",
    ["False"] = "True",
    ["TRUE"] = "FALSE",
    ["FALSE"] = "TRUE",
    ["yes"] = "no",
    ["no"] = "yes",
    ["Yes"] = "No",
    ["No"] = "Yes",
    ["on"] = "off",
    ["off"] = "on",
    ["On"] = "Off",
    ["Off"] = "On",
    ["enable"] = "disable",
    ["disable"] = "enable",
    ["enabled"] = "disabled",
    ["disabled"] = "enabled",
    ["1"] = "0",
    ["0"] = "1",
    ["[ ]"] = "[x]",
    ["[x]"] = "[ ]",
    ["TODO"] = "DONE",
    ["DONE"] = "TODO",
}

toggle_word = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    local best = nil

    for from, to in pairs(toggles) do
        local start = 1

        while true do
            local s, e = line:find(vim.pesc(text)(from), start)

            if not s then break end

            if col + 1 >= s and col + 1 <= e then
                if not best or #from > #best.from then
                    best = {
                        from = from,
                        to = to,
                        s = s,
                        e = e,
                    }
                end
            end

            start = e + 1
        end
    end

    if not best then
        print "No toggle found under cursor"
        return
    end

    local new_line = line:sub(1, best.s - 1) .. best.to .. line:sub(best.e + 1)

    vim.api.nvim_set_current_line(new_line)
end

nmap("<leader>tw", function() toggle_word() end, { desc = "Toggle word" })

exec_verbose_map = function(mode)
    mode = mode or ""

    local cmd = "verbose " .. mode .. "map"

    local output = vim.api.nvim_exec2(cmd, { output = true }).output

    return vim.split(output, "\n", { plain = true })
end

list_keys = function(mode)
    local lines = exec_verbose_map(mode)
    local qf = {}
    local filtered = {}

    for _, line in ipairs(lines) do
        if not line:match "^%s*$" then table.insert(filtered, line) end
    end

    local i = 1

    while i <= #filtered do
        local map_line = filtered[i]

        if not map_line:match "^%S" then
            i = i + 1
            goto continue
        end

        local next1 = filtered[i + 1] or ""
        local next2 = filtered[i + 2] or ""

        local description = ""
        local last_line = ""

        if next1:match "^%s*Last set from" then
            -- no description
            last_line = next1
            i = i + 2
        else
            description = vim.trim(next1)

            if next2:match "^%s*Last set from" then
                last_line = next2
                i = i + 3
            else
                i = i + 1
            end
        end

        local mode_key, binding, rhs = map_line:match "^(%S+)%s+(%S+)%s+(.+)$"

        local location = last_line:match "^%s*Last set from%s+(.+)$" or "unknown"

        if description == "" then description = rhs or "" end

        table.insert(qf, {
            filename = "",
            text = string.format("%-2s %-24s %-45s %s", mode_key or "", binding or "", description, location),
        })

        ::continue::
    end

    vim.fn.setqflist({}, " ", {
        title = "Verbose Maps",
        items = qf,
    })

    vim.cmd "copen"
    vim.cmd "setlocal nowrap"
end

nmap("<leader>lk", function() list_keys() end, { desc = "List all keybindings" })
