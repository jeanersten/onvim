local M = {}

local state = {
  timer    = nil,
  ns_color = vim.api.nvim_create_namespace("IndentScopeColorNS")
}

local config = {
  enable = true,
  symbol    = "|",
  highlight = "Comment",
  debounce_time  = 100
}

local function has_treesitter()
  local ok, parser = pcall(vim.treesitter.get_parser, 0)

  return ok and parser
end

local function get_line_indent(line_num)
  if line_num <= 0 or line_num > vim.api.nvim_buf_line_count(0) then
    return 0
  end

  local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num,
                                                  false)[1]

  if not line_content or line_content:match("^%s*$") then
    local prev_non_blank = vim.fn.prevnonblank(line_num)
    local next_non_blank = vim.fn.nextnonblank(line_num)

    if prev_non_blank == 0 and next_non_blank == 0 then return 0 end

    local prev_indent = prev_non_blank > 0 and
                        vim.fn.indent(prev_non_blank) or 0
    local next_indent = next_non_blank > 0 and
                        vim.fn.indent(next_non_blank) or prev_indent

    if next_indent > prev_indent then
      return next_indent
    end

    return prev_indent
  end

  return vim.fn.indent(line_num)
end

local function get_scope()
  if has_treesitter() then
    local buffer = vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buffer)

    if not parser then
      return nil
    end

    local current_win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(current_win)
    local current_row = cursor[1] - 1
    local current_col = cursor[2]

    local trees = parser:parse()

    if not trees or #trees == 0 then
      return nil
    end

    local root = trees[1]:root()
    local current_node = root:descendant_for_range(current_row, current_col,
                                                   current_row, current_col)

    if not current_node then
      return nil
    end

    local node = current_node

    while node do
      local parent = node:parent()

      if not parent then
        break
      end

      local node_type = node:type()

      if node_type:match("statement") or
         node_type:match("declaration") or
         node_type:match("definition") or
         node_type:match("function") or
         node_type:match("class") or
         node_type:match("method") then

        local start_row, _, end_row, _ = node:range()

        if end_row > start_row then
          return { top = start_row + 1, bottom = end_row + 1,
                   indent = get_line_indent(start_row + 1) }
        end
      end

      node = parent
    end

    return nil
  else
    local current_win = vim.api.nvim_get_current_win()
    local current_line = vim.api.nvim_win_get_cursor(current_win)[1]
    local total_lines  = vim.api.nvim_buf_line_count(0)
    local current_indent = get_line_indent(current_line)

    if current_indent == 0 then return nil end

    local parent_line_num = -1
    local parent_indent = -1

    for l = current_line - 1, 1, -1 do
      local indent = get_line_indent(l)

      if indent < current_indent then
        parent_line_num = l
        parent_indent = indent

        break
      end
    end

    if parent_line_num == -1 then return nil end

    local top_line = -1

    for l = parent_line_num + 1, total_lines do
      if get_line_indent(l) > parent_indent then
        top_line = l

        break
      end
    end

    if top_line == -1 then return nil end

    local bottom_line = top_line

    for l = top_line + 1, total_lines do
      if get_line_indent(l) > parent_indent then
        bottom_line = l
      else
        break
      end
    end

    return { top = top_line, bottom = bottom_line, indent = parent_indent }
  end
end

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

  local scope = get_scope()

  if not scope then return end

  local virt_text = { { config.symbol, config.highlight } }
  
  local leftcol = vim.fn.winsaveview().leftcol

  for i = scope.top, scope.bottom do
    local line_content = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

    if line_content then
      local char_at_indent = line_content:sub(scope.indent + 1,
                                              scope.indent + 1)

      if char_at_indent == "" or char_at_indent:match("%s") then
        local win_col = scope.indent - leftcol
        
        if win_col >= 0 then
          local extmark_opts = {
            virt_text = virt_text,
            virt_text_pos = "overlay",
            virt_text_win_col = win_col,
            hl_mode = "combine"
          }

          pcall(vim.api.nvim_buf_set_extmark, 0, state.ns_color, i - 1, 0,
                extmark_opts)
        end
      end
    end
  end
end

local function update()
  vim.loop.timer_stop(state.timer)
  vim.loop.timer_start(state.timer, config.debounce_time, 0,
                       vim.schedule_wrap(render))
end

local function attach_autocmd()
  local group = vim.api.nvim_create_augroup("IndentScope", { clear = true })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "*",
    callback = function()
      clear_guide()
    end
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged",
                                "TextChangedI", "CursorMoved" }, {
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
    vim.api.nvim_set_hl(0, config.highlight,
                        { link = "Comment", default = true })
    state.timer = vim.loop.new_timer()

    attach_autocmd()
  end
end

return M
