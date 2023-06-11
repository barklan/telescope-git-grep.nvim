local git_grep = require("telescope").extensions.git_grep
local helpers = require("telescope-git-grep.helpers")

local function get_visual()
	local _, ls, cs = unpack(vim.fn.getpos("v"))
	local _, le, ce = unpack(vim.fn.getpos("."))
	return vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
end

local grep_under_default_opts = {
	postfix = " -F ",
	quote = true,
	trim = true,
}

local function process_grep_under_text(value, opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", grep_under_default_opts, opts)

	if opts.trim then
		value = vim.trim(value)
	end

	if opts.quote then
		value = helpers.quote(value, opts)
	end

	if opts.postfix then
		value = value .. opts.postfix
	end

	return value
end

local M = {}


return M
