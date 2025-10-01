return {
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          go = { "goimports", "gofmt" },
          nix = { 'nixfmt', lsp_format = "fallback" },
          rust = { "rustfmt", lsp_format = "fallback" },
          javascript = {"prettier", lsp_format = "fallback"},
          typescript = {"prettier", lsp_format = "fallback"},
          javascriptreact = {"prettier", lsp_format = "fallback"},
          typescriptreact = {"prettier", lsp_format = "fallback"},
          default_format_opts = {
            lsp_format = "fallback",
          },
        },
      }
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
    end,
    keys = {
      { '<leader>f', '<cmd>Format<cr>' }
    }
  },
}
