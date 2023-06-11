local prompt_parser = require("telescope-git-grep.prompt_parser")

local telescope = require("telescope")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local sorters = require("telescope.sorters")
local make_entry = require("telescope.make_entry")
local finders = require("telescope.finders")
local telescope_actions = require("telescope.actions")

local setup_opts = {
	auto_quoting = true,
	mappings = {},
}

local git_grep = function(opts)
	opts = vim.tbl_extend("force", setup_opts, opts or {})

	opts.entry_maker = vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_commits(opts))
	opts.cwd = opts.cwd and vim.fn.expand(opts.cwd)

	local cmd_generator = function(prompt)
		if not prompt or prompt == "" then
			return nil
		end

		local args = { "git", "log", "--pretty=oneline", "--abbrev-commit", "-G" }

		local prompt_parts = prompt_parser.parse(prompt, opts.auto_quoting)

		local cmd = vim.tbl_flatten({ args, prompt_parts })
		return cmd
	end

	pickers
		.new(opts, {
			prompt_title = "Git Grep",
			finder = finders.new_job(cmd_generator, opts.entry_maker, opts.max_results, opts.cwd),
			previewer = {
				previewers.git_commit_diff_to_parent.new(opts),
				previewers.git_commit_diff_to_head.new(opts),
				previewers.git_commit_diff_as_was.new(opts),
				previewers.git_commit_message.new(opts),
			},
			sorter = sorters.highlighter_only(opts),
			attach_mappings = function(_, map)
				telescope_actions.select_default:replace(telescope_actions.git_checkout)
				for mode, mappings in pairs(opts.mappings) do
					for key, action in pairs(mappings) do
						map(mode, key, action)
					end
				end
				return true
			end,
		})
		:find()
end

local git_bgrep = function(opts)
	opts = vim.tbl_extend("force", setup_opts, opts or {})

	opts.entry_maker = vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_commits(opts))
	opts.cwd = opts.cwd and vim.fn.expand(opts.cwd)
	opts.current_file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

	local cmd_generator = function(prompt)
		if not prompt or prompt == "" then
			return nil
		end

		local args = { "git", "log", "--pretty=oneline", "--abbrev-commit", "-G" }

		local prompt_parts = prompt_parser.parse(prompt, opts.auto_quoting)

		local cmd = vim.tbl_flatten({ args, prompt_parts, { "--follow", opts.current_file } })
		return cmd
	end

	pickers
		.new(opts, {
			prompt_title = "Git Grep Buffer",
			finder = finders.new_job(cmd_generator, opts.entry_maker, opts.max_results, opts.cwd),
			previewer = {
				previewers.git_commit_diff_to_parent.new(opts),
				previewers.git_commit_diff_to_head.new(opts),
				previewers.git_commit_diff_as_was.new(opts),
				previewers.git_commit_message.new(opts),
			},
			sorter = sorters.highlighter_only(opts),
			attach_mappings = function(_, map)
				telescope_actions.select_default:replace(telescope_actions.git_checkout)
				for mode, mappings in pairs(opts.mappings) do
					for key, action in pairs(mappings) do
						map(mode, key, action)
					end
				end
				return true
			end,
		})
		:find()
end

return telescope.register_extension({
	setup = function(ext_config)
		for k, v in pairs(ext_config) do
			setup_opts[k] = v
		end
	end,
	exports = {
		git_grep = git_grep,
		git_bgrep = git_bgrep,
	},
})
