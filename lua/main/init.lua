require("main.opts")
require("main.keymaps")
require("main.lazy_init")

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
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("cssls", {
	capabilities = capabilities,
})

vim.lsp.config("html", {
	capabilities = capabilities,
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

vim.lsp.enable("basedpyright")
vim.lsp.enable("cmake")
-- vim.lsp.enable("cssls") use tailwindcss instead --
vim.lsp.enable("eslint")
vim.lsp.enable("gopls")
vim.lsp.enable("html")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("ts_ls")

