-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "tokyonight",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- pkgs not auto-detected by MasonInstallAll:
-- fish-lsp: missing from NvChad names.lua mapping
-- formatters: not configured in conform.lua so won't be auto-collected
M.mason = { pkgs = { "fish-lsp", "black", "isort", "prettier" } }

M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
