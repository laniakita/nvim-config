return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        default_integrations = true,
        integrations = {
          treesitter = true,
          neotree = true,
          barbar = true,
        }
      })

      require("lualine").setup({
        options = {
          theme = "catppuccin"
        }
      })

      vim.cmd([[colorscheme catppuccin]])
    end,
  }
}
