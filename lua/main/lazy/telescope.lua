return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>pf", "<cmd>Telescope find_files<cr>" },
      { "<C-p>",      "<cmd>Telescope git_files<cr>" },
      { "<leader>ps", "<cmd>Telescope live_grep<cr>" },
      { "<leader>vh", "<cmd>Telescope help_tags<cr>" },
    },
  },
}
