local action_state = require "telescope.actions.state"
local helpers = require "telescope-git-grep.helpers"

local default_opts = {
  quote_char = '"',
  postfix = " ",
  trim = true,
}

return function (opts)
  opts = opts or {}
  opts = vim.tbl_extend("force", default_opts, opts)

  return function (prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local prompt = picker:_get_prompt()
    if opts.trim then
      prompt = vim.trim(prompt)
    end
    prompt = helpers.quote(prompt, { quote_char =  opts.quote_char }) .. opts.postfix
    picker:set_prompt(prompt)
  end
end
