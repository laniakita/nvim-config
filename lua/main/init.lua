require("main.opts")
require("main.keymaps")
require("main.mini_init")

-- lsp --
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_cmds", {}),
	callback = function(event)
		local bufnr = event.buf
		-- local client = event.data.client --

		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				local opts = {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = "rounded",
					source = "always",
					prefix = " ",
					scope = "cursor",
				}
				vim.diagnostic.open_float(nil, opts)
			end,
		})
	end,
})

--Enable (broadcasting) snippet capability for completion
local capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
  }
}
capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)


-- STAGE I: CONFIG --

vim.lsp.config("cssls", {
	capabilities = capabilities,
})

vim.lsp.config("html", {
	capabilities = capabilities,
})

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Depending on the usage, you might want to add additional paths
          -- here.
          '${3rd}/luv/library',
          '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = true,
			},
			check = {
				command = "clippy",
			},
		},
	},
})

-- STAGE II: ACTIVATION --

vim.lsp.enable("basedpyright")
vim.lsp.enable("cmake")
-- vim.lsp.enable("cssls") use tailwindcss instead --
vim.lsp.enable("lua_ls")
vim.lsp.enable("eslint")
vim.lsp.enable("gopls")
vim.lsp.enable("html")
vim.lsp.enable("nixd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("ts_ls")

