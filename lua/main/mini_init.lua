local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		-- Uncomment next line to use 'stable' branch
		-- '--branch', 'stable',
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require("mini.deps").setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	local header_logo = [[
 ________   ___      ___ ___  _____ ______      
|\   ___  \|\  \    /  /|\  \|\   _ \  _   \    
\ \  \\ \  \ \  \  /  / | \  \ \  \\\__\ \  \   
 \ \  \\ \  \ \  \/  / / \ \  \ \  \\|__| \  \  
  \ \  \\ \  \ \    / /   \ \  \ \  \    \ \  \ 
   \ \__\\ \__\ \__/ /     \ \__\ \__\    \ \__\
    \|__| \|__|\|__|/       \|__|\|__|     \|__|
  ]]
	require("mini.starter").setup({
		header = header_logo,
	})
end)
now(function()
	require("mini.notify").setup()
end)
now(function()
	require("mini.icons").setup()
end)
now(function()
	require("mini.statusline").setup()
end)

--[[later(function()
	require("mini.files").setup()
  vim.keymap.set('n', '<leader>pv', '<cmd>lua MiniFiles.open()<cr>')
end)]]
--

--[[
now(function()
	local map = require("mini.map")

	require("mini.map").setup({
		integrations = {
			map.gen_integration.builtin_search(),
			map.gen_integration.gitsigns(),
			map.gen_integration.diagnostic(),
		},
	})

	vim.keymap.set("n", "<leader>mc", MiniMap.close)
	vim.keymap.set("n", "<leader>mf", MiniMap.toggle_focus)
	vim.keymap.set("n", "<leader>mo", MiniMap.open)
	vim.keymap.set("n", "<leader>mr", MiniMap.refresh)
	vim.keymap.set("n", "<leader>ms", MiniMap.toggle_side)
	vim.keymap.set("n", "<leader>ml", MiniMap.toggle)
end)
]]
--

-- utils --

--- Dynamically fetches the latest git tag matching a pattern for a local mini.deps plugin.
--- @param repo string The GitHub repository (e.g., "L3MON4D3/LuaSnip")
--- @param pattern string The git tag pattern to match (e.g., "v2.*")
--- @param fallback? string The fallback branch if no tags are found or repo isn't cloned yet (default: "master")
--- @return string The latest matching tag, or the fallback branch.
local function get_latest_tag(repo, pattern, fallback)
	fallback = fallback or "master"

	-- Extract the plugin folder name (everything after the last '/')
	local plugin_name = repo:match("[^/]+$")
	if not plugin_name then
		return fallback
	end

	-- mini.deps default installation path for plugins
	local plugin_dir = vim.fn.stdpath("data") .. "/site/pack/deps/opt/" .. plugin_name

	-- Return fallback if the directory doesn't exist yet (initial install)
	if vim.fn.isdirectory(plugin_dir) == 0 then
		return fallback
	end

	-- Query git for tags matching the pattern, sorted by version descending
	local obj = vim.system({ "git", "-C", plugin_dir, "tag", "-l", pattern, "--sort=-v:refname" }, { text = true })
		:wait()

	if obj.code == 0 and obj.stdout ~= "" then
		local highest_tag = vim.split(vim.trim(obj.stdout), "\n")[1]
		if highest_tag and highest_tag ~= "" then
			return highest_tag
		end
	end

	return fallback
end

-- completions (blink.cmp) --

now(function()
	local function luasnip_post_install(params)
		vim.notify("LuaSnip: Making JSRegExp")
		local obj = vim.system({ "make", "install_jsregexp" }, { cwd = params.path }):wait()
		if obj.code == 0 then
			vim.notify("LuaSnip: Building JSRegExp done", vim.log.levels.INFO)
		else
			vim.notify("LuaSnip: Building JSRegExp failed", vim.log.levels.ERROR)
		end
	end

	add({
		source = "saghen/blink.cmp",
		depends = {
			{
				source = "L3MON4D3/LuaSnip",
				checkout = get_latest_tag("L3MON4D3/LuaSnip", "v2.*", "master"),
				monitor = "master",
				hooks = {
					post_install = luasnip_post_install,
					post_checkout = luasnip_post_install,
				},
			},
		},
		checkout = "v1",
		monitor = "v1",
	})

	require("blink.cmp").setup({
		keymap = { preset = "enter" },
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = { documentation = { auto_show = true } },
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "cmdline" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	})
end)

-- colors (catppuccin) --
now(function()
	add({
		source = "catppuccin/nvim",
	})
	require("catppuccin").setup({
		transparent_background = true,
		styles = {
			comments = { "italic" },
			conditionals = { "italic" },
		},
		default_integrations = true,
		integrations = {
			barbar = true,
			blink_cmp = {
				style = "bordered",
			},
			mini = {
				enabled = true,
				indentscope_color = "pink",
			},
			gitsigns = true,
			treesitter = true,
			neotree = true,
		},
	})
	vim.cmd([[colorscheme catppuccin]])
end)

-- formatting (conform) --
now(function()
	add({
		source = "stevearc/conform.nvim",
	})
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "goimports", "gofmt" },
			nix = { "nixfmt", lsp_format = "fallback" },
			rust = { "rustfmt", lsp_format = "fallback" },
			javascript = { "prettier", lsp_format = "fallback" },
			typescript = { "prettier", lsp_format = "fallback" },
			javascriptreact = { "prettier", lsp_format = "fallback" },
			typescriptreact = { "prettier", lsp_format = "fallback" },
			python = { "ruff_format", lsp_fallback = "fallback" },
			default_format_opts = {
				lsp_format = "fallback",
			},
		},
	})

	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, lsp_fallback = true, range = range })
	end, { range = true })
	vim.keymap.set("n", "<leader>f", "<cmd>Format<cr>", { desc = "Format document" })
end)

-- flutter --
later(function()
	add({
		source = "nvim-flutter/flutter-tools.nvim",
		checkout = "main",
		monitor = "main",
		depends = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim",
		},
	})
	require("snacks").setup({
		input = { enabled = true },
	})
	require("flutter-tools").setup()
end)

-- fugitive --
later(function()
	add({
		source = "tpope/vim-fugitive",
		checkout = "master",
	})
	vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "open fugitive" })
end)

-- lsp --
now(function()
	add({
		source = "neovim/nvim-lspconfig",
		checkout = "master",
		monitor = "master",
	})
end)

-- neotree --
later(function()
	add({
		source = "nvim-neo-tree/neo-tree.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		checkout = "v3.x",
	})
	require("neo-tree").setup({
		close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = true,
		open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
		sort_case_insensitive = false, -- used when sorting files and directories in the tree
		sort_function = nil,
		default_component_configs = {
			container = {
				enable_character_fade = true,
			},
			indent = {
				indent_size = 2,
				padding = 1, -- extra padding on left hand side
				-- indent guides
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "└",
				highlight = "NeoTreeIndentMarker",
				-- expander config, needed for nesting files
				with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "󰜌",
				-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
				-- then these will never be used.
				default = "*",
				highlight = "NeoTreeFileIcon",
			},
			modified = {
				symbol = "[+]",
				highlight = "NeoTreeModified",
			},
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			git_status = {
				symbols = {
					-- Change typ
					added = "A", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified = "M", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted = "✖", -- this can only be used in the git_status source
					renamed = "󰁕", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
			-- If you don't want to use these columns, you can set `enabled = false` for each of them individually
			file_size = {
				enabled = true,
				required_width = 64, -- min width of window required to show this column
			},
			type = {
				enabled = true,
				required_width = 122, -- min width of window required to show this column
			},
			last_modified = {
				enabled = true,
				required_width = 88, -- min width of window required to show this column
			},
			created = {
				enabled = true,
				required_width = 110, -- min width of window required to show this column
			},
			symlink_target = {
				enabled = false,
			},
		},
		window = {
			position = "float",
			width = 40,
			mapping_options = {
				noremap = true,
				nowait = true,
			},
			mappings = {
				["<TAB>"] = {
					"toggle_node",
					nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
				},
				["<2-LeftMouse>"] = "open",
				["<cr>"] = "open",
				["<esc>"] = "cancel", -- close preview or floating neo-tree window
				["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
				-- Read `# Preview Mode` for more information
				["l"] = "focus_preview",
				["S"] = "open_split",
				["s"] = "open_vsplit",
				-- ["S"] = "split_with_window_picker",
				-- ["s"] = "vsplit_with_window_picker",
				["t"] = "open_tabnew",
				-- ["<cr>"] = "open_drop",
				-- ["t"] = "open_tab_drop",
				["w"] = "open_with_window_picker",
				--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
				["C"] = "close_node",
				-- ['C'] = 'close_all_subnodes',
				["z"] = "close_all_nodes",
				--["Z"] = "expand_all_nodes",
				["a"] = {
					"add",
					-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
					-- some commands may take optional config options, see `:h neo-tree-mappings` for details
					config = {
						show_path = "none", -- "none", "relative", "absolute"
					},
				},
				["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
				["d"] = "delete",
				["r"] = "rename",
				["y"] = "copy_to_clipboard",
				["x"] = "cut_to_clipboard",
				["p"] = "paste_from_clipboard",
				["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
				-- ["c"] = {
				--  "copy",
				--  config = {
				--    show_path = "none" -- "none", "relative", "absolute"
				--  }
				--}
				["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
				["q"] = "close_window",
				["R"] = "refresh",
				["?"] = "show_help",
				["<"] = "prev_source",
				[">"] = "next_source",
				["i"] = "show_file_details",
			},
		},
		git_status = {
			window = {
				position = "float",
				mappings = {
					["A"] = "git_add_all",
					["gu"] = "git_unstage_file",
					["ga"] = "git_add_file",
					["gr"] = "git_revert_file",
					["gc"] = "git_commit",
					["gp"] = "git_push",
					["gg"] = "git_commit_and_push",
					["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
					["oc"] = { "order_by_created", nowait = false },
					["od"] = { "order_by_diagnostics", nowait = false },
					["om"] = { "order_by_modified", nowait = false },
					["on"] = { "order_by_name", nowait = false },
					["os"] = { "order_by_size", nowait = false },
					["ot"] = { "order_by_type", nowait = false },
				},
			},
		},
	})
	vim.keymap.set("n", "<leader>pv", "<cmd>Neotree<cr>", { desc = "Open Neotree" })
	vim.keymap.set("n", "<leader>gv", "<cmd>Neotree float git_status<cr>", { desc = "Open Neotree in git mode" })
end)

-- scrollbar --
later(function()
	add({
		source = "petertriho/nvim-scrollbar",
		depends = {
			"lewis6991/gitsigns.nvim",
			"kevinhwang91/nvim-hlslens",
		},
		checkout = "main",
	})
	-- hlsllens config --
	require("hlslens").setup()

	local kopts = { noremap = true, silent = true }

	vim.api.nvim_set_keymap(
		"n",
		"n",
		[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
		kopts
	)
	vim.api.nvim_set_keymap(
		"n",
		"N",
		[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
		kopts
	)
	vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

	vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)

	-- scrollbar config --
	local colors = require("catppuccin.palettes").get_palette()
	require("scrollbar").setup({
		handle = {
			color = colors.bg_highlight,
		},
		marks = {
			Search = { color = colors.orange },
			Error = { color = colors.error },
			Warn = { color = colors.warning },
			Info = { color = colors.info },
			Hint = { color = colors.hint },
			Misc = { color = colors.purple },
		},
		handlers = {
			cursor = true,
			diagnostic = true,
			gitsigns = true, -- Requires gitsigns
			handle = true,
			search = true, -- Requires hlslens
			ale = false, -- Requires ALE
		},
	})
end)

-- tabline --
later(function()
	add({
		source = "romgrk/barbar.nvim",
		depends = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		checkout = "master",
		monitor = "master",
	})

	require("barbar").setup()

	vim.keymap.set("n", "<A-w>", "<cmd>BufferClose<cr>", { desc = "close tab" })
	vim.keymap.set("n", "<A-,>", "<cmd>BufferPrevious<cr>", { desc = "view previous tab" })
	vim.keymap.set("n", "<A-.>", "<cmd>BufferNext<cr>", { desc = "view next tab" })
	vim.keymap.set("n", "<A-S-h>", "<cmd>BufferMovePrevious<cr>", { desc = "move tab left" })
	vim.keymap.set("n", "<A-S-l>", "<cmd>BufferMoveNext<cr>", { desc = "move tab right" })
end)

-- telescope --
later(function()
	local function telescope_fzf_post_install(params)
		vim.notify("Telescope FZF: Making...")
		local obj = vim.system({ "make" }, { cwd = params.path }):wait()
		if obj.code == 0 then
			vim.notify("Telescope FZF: Building done", vim.log.levels.INFO)
		else
			vim.notify("Telescope FZF: Building failed", vim.log.levels.ERROR)
		end
	end

	add({
		source = "nvim-telescope/telescope.nvim",
		checkout = get_latest_tag("nvim-telescope/telescope.nvim", "v0.*", "master"),
		monitor = "master",
		depends = {
			"nvim-lua/plenary.nvim",
			{
				source = "nvim-telescope/telescope-fzf-native.nvim",
				monitor = "main",
				checkout = "main",
				hooks = {
					post_install = telescope_fzf_post_install,
					post_checkout = telescope_fzf_post_install,
				},
			},
		},
	})

	vim.keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<cr>", { desc = "Search file names" })
	vim.keymap.set("n", "<leader>pg", "<cmd>Telescope git_files<cr>", { desc = "Search git file names" })
	vim.keymap.set("n", "<leader>ps", "<cmd>Telescope live_grep<cr>", { desc = "Grep search through files" })
	vim.keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<cr>", { desc = "Telescop help tags" })
end)

-- treesitter manager --
later(function()
	add({
		source = "romus204/tree-sitter-manager.nvim",
		checkout = "main",
		monitor = "main",
	})

	require("tree-sitter-manager").setup({
		ensure_installed = {
			"lua",
			"python",
			"rust",
			"tsx",
		},
		auto_install = true,
	})
end)

-- ufo --
now(function()
	-- ufo folding opts --
	vim.o.foldcolumn = "1" -- '0' is not bad
	vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
	vim.o.foldlevelstart = 99
	vim.o.foldenable = true
	vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"

	add({
		source = "kevinhwang91/nvim-ufo",
		depends = {
			"kevinhwang91/promise-async",
		},
		checkout = "main",
	})

	require("ufo").setup({
		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
	})

	vim.keymap.set("n", "zR", require("ufo").openAllFolds)
	vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
end)

-- undotree --
now(function()
	add({
		source = "mbbill/undotree",
		checkout = "master",
	})
	vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Open undotree" })
end)
