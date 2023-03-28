vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

-- Push space to clear annoying search highlights --
vim.keymap.set("n", "<Space>", ":nohlsearch<Bar>:echo<CR>", { silent = true })

-- Copy to clipboard --
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Paste over the top without replacing what we copied
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.cmd [[colorscheme gruvbox-material]]

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", builtin.find_files, {});
vim.keymap.set("n", "<C-p>", builtin.git_files, {});
vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>sh', builtin.help_tags, {})

require("nvim-treesitter.configs").setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require('lualine').setup {
  options = {
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
  },
}

-- Here is the formatting config
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier_d_slim,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.shfmt,
  }
})

require('fidget').setup {
  window = {
    blend = 0,
  }
}

-- Setup language servers.
local lspconfig = require("lspconfig")

lspconfig.tsserver.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.eslint.setup {}
lspconfig.rnix.setup {}
lspconfig.golangci_lint_ls.setup {}
lspconfig.yamlls.setup {
  settings = {
    yaml = {
      keyOrdering = false,
    },
    redhat = { telemetry = { enabled = false } }
  },
}
lspconfig.bashls.setup {}

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you"re using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

require("Comment").setup()

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
}

require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

local border = {
  { "╭", "FloatBorder" },
  { "─",  "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│",  "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─",  "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│",  "FloatBorder" },
}

vim.cmd('highlight FloatBorder guifg=white guibg=#282828')
vim.cmd('highlight NormalFloat guibg=#282828')

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Transparent BG --
vim.cmd('highlight Normal guibg=none ctermbg=none')
vim.cmd('highlight NormalNC guibg=none ctermbg=none') -- This makes fidget transparent
-- vim.cmd('highlight NormalFloat guibg=none ctermbg=none')
vim.cmd('highlight CursorLineNr guibg=none ctermbg=none')
vim.cmd('highlight CursorLine guibg=none ctermbg=none')
vim.cmd('highlight LineNr guibg=none ctermbg=none')
vim.cmd('highlight Folded guibg=none ctermbg=none')
vim.cmd('highlight NonText guibg=none ctermbg=none')
vim.cmd('highlight SpecialKey guibg=none ctermbg=none')
vim.cmd('highlight VertSplit guibg=none ctermbg=none')
vim.cmd('highlight SignColumn guibg=none ctermbg=none')
vim.cmd('highlight EndOfBuffer guibg=none ctermbg=none')
