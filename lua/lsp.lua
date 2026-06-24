vim.pack.add {
  "https://github.com/j-hui/fidget.nvim"
}
require("fidget").setup {}

local loclistname = "Lsp Diagnostics"
local loclist_update_group = vim.api.nvim_create_augroup("DIAGNOSTIC LOCLIST", {
  clear = true
})

vim.keymap.set("n", "<S-Z>", "", {
  callback = function ()
    vim.diagnostic.setloclist(
      {
        title = loclistname,
        open = false
      }
    )
    require("quicker").toggle({
      loclist = true
    })
  end
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = loclist_update_group,
  desc = "Update loc list diagnostic",
  callback = function ()
    local title = vim.fn.getloclist(0, { title = 0 }).title
    if title == loclistname then
      vim.diagnostic.setloclist({
        open = false,
        title = loclistname
      })
    end
  end
})

vim.diagnostic.config {
  signs = {
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'Error'
    }
  },
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = {
    severity = vim.diagnostic.severity.WARN
  },
  virtual_text = false, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

local plugs = {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}
vim.pack.add(plugs)

local servers = {
  clangd = {
  },
  rust_analyzer = {
    -- standalone = true,
    settings = {
      ['rust-analyzer'] = {
      },
    }
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          -- Prevents lua_ls from scanning your entire machine for third-party libraries
          checkThirdParty = false,
          -- Tells lua_ls to stop loading massive amounts of files into memory
          library = {
            vim.env.VIMRUNTIME
            -- Depending on your version, you can add specific paths here if needed,
            -- but leaving it minimal keeps it fast.
          },
          -- Speeds up loading by ignoring large, irrelevant directories
          ignoreDir = { ".git", "node_modules" },
        },
        format = { enable = false }, -- Matches your format = false preference
        telemetry = { enable = false },
      },
    },
  }
}

-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup {}

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, you can run
--    :Mason
--
-- You can press `g?` for help in this menu.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- You can add other tools here that you want Mason to install
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})
require "feat.complete"
vim.g.rust_recommended_style = false
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = true })
