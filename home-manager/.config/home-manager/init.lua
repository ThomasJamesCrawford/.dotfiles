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
        null_ls.builtins.formatting.prettier_d_slim.with({
            disabled_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" } -- eslint_d does these
        }),
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.diagnostics.eslint_d,
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

local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.tsserver.setup { capabilities = capabilities }
lspconfig.rust_analyzer.setup { capabilities = capabilities }
lspconfig.intelephense.setup { capabilities = capabilities }
lspconfig.rnix.setup { capabilities = capabilities }
lspconfig.golangci_lint_ls.setup { capabilities = capabilities }
lspconfig.yamlls.setup {
    capabilities = capabilities,
    settings = {
        yaml = {
            keyOrdering = false,
        },
        redhat = { telemetry = { enabled = false } }
    },
}
lspconfig.bashls.setup { capabilities = capabilities }

lspconfig.lua_ls.setup {
    capabilities = capabilities,
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
            vim.lsp.buf.format { async = true, filter = function(client) return client.name ~= "tsserver" end }
        end, opts)
    end,
})

require("nvim_comment").setup()

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
    { "─", "FloatBorder" },
    { "╮", "FloatBorder" },
    { "│", "FloatBorder" },
    { "╯", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╰", "FloatBorder" },
    { "│", "FloatBorder" },
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

-- Make visual highlight more obvious
vim.cmd('highlight Visual guibg=#458588')

function GetVisualSelection()
    local start_pos = vim.api.nvim_buf_get_mark(0, '<')
    local end_pos = vim.api.nvim_buf_get_mark(0, '>')

    if start_pos[1] == end_pos[1] then
        -- selection is within a single line
        local line = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, start_pos[1], false)[1]
        local selection = string.sub(line, start_pos[2] + 1, end_pos[2])
        return selection
    else
        -- selection spans multiple lines
        local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
        lines[1] = string.sub(lines[1], start_pos[2] + 1)
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[2])
        local selection = table.concat(lines, '\n')
        return selection
    end
end

function GetPrompt()
    local prompt = vim.fn.input("Enter your prompt: ")
    local selection = GetVisualSelection()
    return prompt .. "\n" .. selection
end

function CallApi(prompt)
    local data = string.format('"%s"', vim.fn.json_encode({
        model = "gpt-3.5-turbo",
        messages = { { role = "user", content = prompt } },
        max_tokens = 200,
    }))

    local cmd = string.format(
        "curl -s -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -X POST -d %s 'https://api.openai.com/v1/chat/completions'",
        os.getenv('OPENAI_API_KEY'),
        data
    )

    print(vim.inspect(cmd))

    local success, response = pcall(vim.fn.system, cmd)

    if not success then
        print("Error running curl command:", response)
        return nil
    end

    if not response or response == "" then
        print("Error: empty response")
        return nil
    end

    return vim.fn.json_decode(response)
end

function InsertResponse(response)
    local output = response.choices[1].message.content

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = math.min(80, vim.o.columns - 4),
        height = math.min(20, vim.o.lines - 4),
        style = 'minimal',
        border = border,
    })
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    -- insert the response into the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- focus the window
    vim.api.nvim_set_current_win(win)
end

vim.cmd("command! -range OpenAIRequest <line1>,<line2>lua InsertResponse(CallApi(GetPrompt()))")

vim.keymap.set('v', 'ai', ':OpenAIRequest<CR>')
