return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
        },
        lightbulb = {
          enable = false,
        },
      })
    end,
    keys = {
      { "gh", "<cmd>Lspsaga lsp_finder<CR>", desc = "LSP Finder" },
      { "gd", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
      { "gr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
      { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
      { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    },
    opts = {},
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },
}
