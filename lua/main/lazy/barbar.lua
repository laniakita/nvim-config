return {
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    config = function()
      vim.g.barbar_auto_setup = false
      require("barbar").setup({
        -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
        -- animation = true,
        -- insert_at_start = true,
        -- …etc.
        sidebar_filetypes = {
          undotree = {
            text = 'undotree',
            align = 'left',
          },
        },
      })
    end,
    keys = {
      { "<A-w>",   "<cmd>BufferClose<cr>",        desc = "close tab" },
      { "<A-,>",   "<cmd>BufferPrevious<cr>",     desc = "view previous tab" },
      { "<A-.>",   "<cmd>BufferNext<cr>",         desc = "view next tab" },
      { "<A-S-l>", "<cmd>BufferMovePrevious<cr>", desc = "move tab left" },
      { "<A-S-l>", "<cmd>BufferMoveNext<cr>",     desc = "move tab right" },
      { "<A-1>",   "<cmd>BufferGoto 1<cr>",       desc = "view first tab" },
      { "<A-2>",   "<cmd>BufferGoto 2<cr>",       desc = "view second tab" },
      { "<A-3>",   "<cmd>BufferGoto 3<cr>",       desc = "view third tab" },
      { "<A-4>",   "<cmd>BufferGoto 4<cr>",       desc = "view fourth tab" },
      { "<A-5>",   "<cmd>BufferGoto 5<cr>",       desc = "view fifth tab" },
      { "<A-6>",   "<cmd>BufferGoto 6<cr>",       desc = "view sixth tab" },
      { "<A-7>",   "<cmd>BufferGoto 7<cr>",       desc = "view seventh tab" },
      { "<A-8>",   "<cmd>BufferGoto 8<cr>",       desc = "view eighth tab" },
      { "<A-9>",   "<cmd>BufferGoto 9<cr>",       desc = "view ninth tab" },
      { "<A-10>",  "<cmd>BufferLast<cr>",         desc = "view last tab" },
    },
    lazy = false,
    version = '^1.0.0', -- optional: only update when a new 1.x version is released

  },
}
