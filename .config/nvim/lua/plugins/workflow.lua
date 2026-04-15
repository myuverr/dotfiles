return {
  {
    "olimorris/persisted.nvim",
    opts = {
      save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"),
      autostart = false,
      autoload = false,
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
