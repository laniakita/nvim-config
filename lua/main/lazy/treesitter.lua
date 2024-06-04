return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = {"c_sharp", "c", "lua", "vim", "vimdoc", "javascript", "typescript", "html", "go", "rust", "zig", "python"},
        sync_install = false,
        auto_install = true,
        highlight = { enable = true }
      })
    end
  }
}
