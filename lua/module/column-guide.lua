local M = {}

local state = {
  timer    = nil,
  ns_color = vim.api.nvim_create_namespace("ColumnGuideColorNS")
}

local config = {
  enable = true,
  symbol    = "|",
  highlight = "Comment",
  columns   = { 80 },
  debounce_time = 100
}

local function should_render()
  local buftype  = vim.api.nvim_buf_get_option(0, "buftype")
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")

  if buftype ~= "" then
    return false
  end

  local win_config = vim.api.nvim_win_get_config(0)

  if win_config.relative ~= "" then
    return false
  end

  local skip_filetypes = { "help", "terminal", "explorer", "picker" }

  for _, ft in ipairs(skip_filetypes) do
    if filetype == ft then
      return false
    end
  end

  return true
end

local function clear_guide()
  if not vim.api.nvim_buf_is_valid(0) then return end

  vim.api.nvim_buf_clear_namespace(0, state.ns_color, 0, -1)
end

local function render()
  if not should_render() then
    clear_guide()

    return
  end

  clear_guide()

  local total_lines = vim.api.nvim_buf_line_count(0)

  local virt_text = { { config.symbol, config.highlight } }

  for _, col in ipairs(config.columns) do
    for line_num = 1, total_lines do
      local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

      if line_content then
        local char_at_col = line_content:sub(col + 1, col + 1)

        if char_at_col == "" or char_at_col:match("%s") then
          local extmark_opts = {
            virt_text = virt_text,
            virt_text_pos = "overlay",
            virt_text_win_col = col,
            hl_mode = "combine",
            priority = 1,
          }

          pcall(vim.api.nvim_buf_set_extmark, 0, state.ns_color, line_num - 1, 0, extmark_opts)
        end
      end
    end
  end
end

local function update()
  vim.loop.timer_stop(state.timer)
  vim.loop.timer_start(state.timer, config.debounce_time, 0, vim.schedule_wrap(render))
end

local function attach_autocmd()
  local group = vim.api.nvim_create_augroup("ColumnGuide", { clear = true })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "*",
    callback = function()
      clear_guide()
    end
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "CursorMoved" }, {
    group = group,
    pattern = "*",
    callback = function()
      update()
    end
  })
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.o.colorcolumn = ""
    vim.api.nvim_set_hl(0, config.highlight, { link = "Comment", default = true })
    state.timer = vim.loop.new_timer()

    attach_autocmd()
  end
end

return M
