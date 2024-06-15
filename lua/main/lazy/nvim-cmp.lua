return {
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
          { name = 'buffer' },
        }),
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
      --[[require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
        capabilities = capabilities
      }]]
      --

      local on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            local opts = {
              focusable = false,
              close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
              border = 'rounded',
              source = 'always',
              prefix = ' ',
              scope = 'cursor',
            }
            vim.diagnostic.open_float(nil, opts)
          end
        })
      end

      local nvim_lsp = require('lspconfig')

      -- requires: npm install -g @biomejs/biome
      nvim_lsp['biome'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: dotnet tool install --global csharp-ls
      nvim_lsp['csharp_ls'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: npm i -g vscode-langservers-extracted
      nvim_lsp['eslint'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        --[[on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,]] --
      }

      nvim_lsp['glsl_analyzer'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      nvim_lsp['gopls'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: npm install -g vscode-langservers-extracted
      nvim_lsp['html'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: $ brew install / # pacman -S lua-language-server
      nvim_lsp['lua_ls'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                -- Depending on the usage, you might want to add additional paths here.
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              }
              -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
              -- library = vim.api.nvim_get_runtime_file("", true)
            }
          })
        end,
        settings = {
          Lua = {}
        }
      }

      nvim_lsp['mdx_analyzer'].setup {
        capabilities = capabilities,
        on_attach = on_attach
      }

      -- requires: npm install -g svelte-language-server
      -- in addition: you'll need to configure tsserver + typescript-svelte-plugin.
      -- see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#svelte
      nvim_lsp['svelte'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: npm install -g @tailwindcss/language-server
      nvim_lsp['tailwindcss'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- requires: npm install -g typescript typescript-language-server
      -- tsserver is setup per project.
      -- see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
      nvim_lsp['tsserver'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      nvim_lsp['zls'].setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end
  },
}
