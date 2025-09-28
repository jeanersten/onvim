local M = {}

local state = {
  window_prompt = -1,
  buffer_prompt = -1,
  window_list   = -1,
  buffer_list   = -1,
  debounce_timer = nil,
  loading        = false,
  ns_dim         = vim.api.nvim_create_namespace("PickerDimNS"),
  files          = {}
}

local config = {
  enable = true,
  title     = "Picker",
  title_pos = "left",
  border    = "single",
  width     = 80,
  height    = 25,
  icon_prompt_search   = ">",
  icon_info            = "[INF]",
  icon_file_normal     = "[FLE]",
  icon_file_code       = "[CDE]",
  icon_file_config     = "[CFG]",
  icon_file_text       = "[TXT]",
  icon_file_image      = "[IMG]",
  icon_file_executable = "[EXE]",
  keymap_toggle      = "<M-f>",
  keymap_next        = "<Tab>",
  keymap_previous    = "<S-Tab>",
  keymap_select_file = "<CR>",
  keymap_quit        = "q",
  max_display   = 100,
  debounce_time = 1000
}

local function open_floating_window()
  local buffer_prompt = nil

  if vim.api.nvim_buf_is_valid(state.buffer_prompt) then
    buffer_prompt = state.buffer_prompt
  else
    buffer_prompt = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "picker", { buf = buffer_prompt })
    vim.api.nvim_set_option_value("buftype", "prompt", { buf = buffer_prompt })
    vim.fn.prompt_setprompt(buffer_prompt, " " .. config.icon_prompt_search .. ": ")
    state.buffer_prompt = buffer_prompt

    vim.schedule(function()
      vim.cmd("startinsert")

      vim.defer_fn(function()
        vim.cmd("stopinsert")
      end, 5)
    end)
  end

  local buffer_list = nil

  if vim.api.nvim_buf_is_valid(state.buffer_list) then
    buffer_list = state.buffer_list
  else
    buffer_list = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "picker", { buf = buffer_list })
    state.buffer_list = buffer_list
  end

  local row_start    = math.floor((vim.o.lines - config.height) / 2)
  local column_start = math.floor((vim.o.columns - config.width) / 2)

  local config_prompt = {
    relative  = "editor",
    width     = config.width,
    height    = 1,
    row       = row_start,
    col       = column_start,
    style     = "minimal",
    border    = config.border,
    title     = (" " .. config.title .. " "),
    title_pos = config.title_pos
  }

  local window_prompt = nil

  window_prompt = vim.api.nvim_open_win(buffer_prompt, true, config_prompt)
  vim.api.nvim_set_option_value("winfixbuf", true, { win = window_prompt })
  vim.api.nvim_set_option_value("winfixwidth", true, { win = window_prompt })
  vim.api.nvim_set_option_value("winfixheight", true, { win = window_prompt })
  vim.api.nvim_set_option_value("wrap", true, { win = window_prompt })
  state.window_prompt = window_prompt

  local config_list = {
    relative  = "editor",
    width     = config.width,
    height    = config.height - 3,
    row       = row_start + 3,
    col       = column_start,
    style     = "minimal",
    border    = config.border,
    title     = " Results ",
    title_pos = "center"
  }

  local window_list = nil

  window_list = vim.api.nvim_open_win(buffer_list, false, config_list)
  vim.api.nvim_set_option_value("winfixbuf", true, { win = window_list })
  vim.api.nvim_set_option_value("winfixwidth", true, { win = window_list })
  vim.api.nvim_set_option_value("winfixheight", true, { win = window_list })
  vim.api.nvim_set_option_value("cursorline", true, { win = window_list })
  state.window_list = window_list
end

local function hide_floating_window()
  if vim.api.nvim_win_is_valid(state.window_prompt) then
    vim.api.nvim_win_hide(state.window_prompt)
    state.window_prompt = -1
  end

  if vim.api.nvim_win_is_valid(state.window_list) then
    vim.api.nvim_win_hide(state.window_list)
    state.window_list = -1
  end
end

local function is_floating_buffer(buffer)
  return buffer == state.buffer_prompt or buffer == state.buffer_list
end

local function is_floating_window(window)
  return window == state.window_prompt or window == state.window_list
end

local function get_file_icon(filename)
  local extension_code_list       = {
    "c", "cpp", "h", "hpp", "lua",
    "py", "rs", "go", "java", "cs",
    "ts", "tsx", "js", "jsx", "sh",
    "bash", "zsh", "fish", "rb", "php",
    "swift", "kt", "m", "mm"
  }

  local extension_config_list     = {
    "conf", "json", "jsonc", "toml", "yaml",
    "yml", "ini", "cfg", "env", "editorconfig"
  }

  local extension_text_list       = {
    "md", "markdown", "txt", "log", "rst",
    "org"
  }

  local extension_image_list      = {
    "bmp", "gif", "jpg", "jpeg", "png",
    "webp", "svg", "tiff", "ico", "heic"
  }

  local extension_executable_list = {
    "exe", "bat", "cmd", "sh", "bin",
    "run", "msi", "apk", "app", "elf"
  }

  local extension = filename:match("%.([^%.]+)$")

  if extension then
    extension = extension:lower()
  else
    return config.icon_file_normal
  end

  if vim.tbl_contains(extension_code_list, extension) then
    return config.icon_file_code
  elseif vim.tbl_contains(extension_config_list, extension) then
    return config.icon_file_config
  elseif vim.tbl_contains(extension_text_list, extension) then
    return config.icon_file_text
  elseif vim.tbl_contains(extension_image_list, extension) then
    return config.icon_file_image
  elseif vim.tbl_contains(extension_executable_list, extension) then
    return config.icon_file_executable
  else
    return config.icon_file_normal
  end
end

local function render()
  local lines = {}

  if #state.files == 0 then
    lines = { string.format(config.icon_info .. " Nothing to display over here..") }
  elseif state.loading == true then
    lines = { string.format(config.icon_info .. " Loading..") }
  else
    for i, filename in ipairs(state.files) do
      lines[i] = string.format("%s %s", get_file_icon(filename), filename)
    end
  end

  if vim.api.nvim_buf_is_valid(state.buffer_list) then
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.buffer_list })
    vim.api.nvim_buf_set_lines(state.buffer_list, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buffer_list })
    vim.api.nvim_buf_clear_namespace(state.buffer_list, state.ns_dim, 0, -1)

    if #state.files == 0 or state.loading == true then
      vim.api.nvim_buf_add_highlight(state.buffer_list, state.ns_dim, "Comment", 0, 0, -1)
    end
  end
end

local function get_prompt_query()
  local line = ""
  local prompt = ""

  if vim.api.nvim_buf_is_valid(state.buffer_prompt) then
    line   = vim.api.nvim_buf_get_lines(state.buffer_prompt, 0, 1, false)[1]
    prompt = vim.fn.prompt_getprompt(state.buffer_prompt)
  end

  return line:sub(#prompt + 1)
end

local function update_files()
  state.loading = true
  render()

  if state.debounce_timer then
    vim.fn.timer_stop(state.debounce_timer)
  end

  state.debounce_timer = vim.fn.timer_start(state.debounce_time, function()
    local query = get_prompt_query()

    if not query or query == "" then
      state.files = {}
      render()

      return
    end

    local query_lower = query:lower()
    local results     = {}

    vim.schedule(function()
      vim.fn.jobstart("rg --files --color never --ignore-case --hidden", {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            for _, path in ipairs(data) do
              if path ~= "" and #results < config.max_display then
                if path:lower():find(query_lower, 1, true) and vim.fn.filereadable(path) == 1 then
                  results[#results + 1] = path
                end
              end
            end
          end
        end,
        on_exit = function()
          table.sort(results)
          state.files = results
          state.loading = false
          vim.schedule(function()
            render()
          end)
        end
      })
    end)
  end)
end

local function get_selected_file()
  local item_index = vim.api.nvim_win_get_cursor(state.window_list)[1]

  if item_index > #state.files then
    return nil
  end

  return state.files[item_index]
end

local function handle_file_select()
  local file = get_selected_file()

  if not file then
    return
  end

  hide_floating_window()
  vim.schedule(function()
    vim.cmd("edit " .. vim.fn.fnameescape(file))
  end)
end

local function fix_cursor_position()
  local window = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(window)
  local row    = cursor[1]
  local column = cursor[2]

  if (window == state.window_prompt) then
    local prompt_text        = vim.fn.prompt_getprompt(state.buffer_prompt)
    local prompt_text_length = string.len(prompt_text)

    if row == 1 and column < prompt_text_length then
      vim.api.nvim_win_set_cursor(0, { 1, prompt_text_length })
    end
  elseif (window == state.window_list) then
    if vim.api.nvim_buf_is_valid(state.buffer_prompt) then
      vim.api.nvim_set_current_win(state.window_prompt)
    end
  end
end

local function navigate_through(direction)
  local total_lines = vim.api.nvim_buf_line_count(state.buffer_list)
  local cursor = vim.api.nvim_win_get_cursor(state.window_list)
  local row    = cursor[1]

  local target_row = row + direction

  if target_row < 1 then
    target_row = total_lines
  elseif target_row > total_lines then
    target_row = 1
  end

  vim.api.nvim_win_set_cursor(state.window_list, { target_row, 0 })
end

local function attach_keymaps()
  local opts = { buffer = state.buffer_prompt, silent = true }

  vim.keymap.set({ "n", "i" }, config.keymap_next, function()
    navigate_through(1)
  end, opts)

  vim.keymap.set({ "n", "i" }, config.keymap_previous, function()
    navigate_through(-1)
  end, opts)

  vim.keymap.set({ "n", "i" }, config.keymap_select_file, handle_file_select, opts)

  vim.keymap.set("n", config.keymap_quit, hide_floating_window, opts)

  vim.keymap.set({ "n", "i" }, "<2-LeftMouse>", handle_file_select, opts)
end

local function attach_autocmd()
  local group = vim.api.nvim_create_augroup("PickerProtect", { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      vim.schedule(function()
        hide_floating_window()
      end)
    end
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      vim.schedule(function()
        local window = tonumber(args.match)

        if is_floating_window(window) then
          hide_floating_window()
        end
      end)
    end
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "WinNew" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        local window = vim.api.nvim_get_current_win()
        local buffer = vim.api.nvim_win_get_buf(window)

        if not is_floating_window(window) then
          hide_floating_window()
          if is_floating_buffer(buffer) then
            vim.api.nvim_win_close(window, true)
          end
        end
      end)
    end
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufNew" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        local window = vim.api.nvim_get_current_win()
        local buffer = vim.api.nvim_win_get_buf(window)

        if is_floating_window(window) and not is_floating_buffer(buffer) then
          hide_floating_window()
          vim.schedule(function()
            vim.api.nvim_set_current_buf(buffer)
          end)
        end
      end)
    end
  })

  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = group,
    buffer = state.buffer_prompt,
    callback = function()
      vim.api.nvim_set_option_value("modified", false, { buf = state.buffer_prompt })
    end
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    buffer = state.buffer_prompt,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode

      if mode == "v" or mode == "V" or mode == "\x16" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end
  })


  vim.api.nvim_create_autocmd("TextChanged", {
    group = group,
    buffer = state.buffer_prompt,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(state.buffer_prompt, 0, -1, false)
      local empty = true

      for _, line in ipairs(lines) do
        if line ~= "" then
          empty = false
          break
        end
      end

      if empty then
        vim.schedule(function()
          vim.cmd("startinsert")
          vim.defer_fn(function()
            vim.cmd("stopinsert")
          end, 5)
        end)
      end

      update_files()
    end
  })

  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    buffer = state.buffer_prompt,
    callback = function()
      update_files()
    end
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = state.buffer_list,
    callback = function()
      fix_cursor_position()
    end
  })
end

function M.toggle()
  if vim.api.nvim_get_current_win() == state.window_prompt then
    hide_floating_window()
  else
    open_floating_window()
    update_files()
    attach_keymaps()
    attach_autocmd()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.keymap.set("n", config.keymap_toggle, M.toggle, { desc = "Toggle Picker" })
    vim.api.nvim_create_user_command("Picker", M.toggle, {})
  end
end

return M
