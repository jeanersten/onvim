local M = {}

local state = {
  buffer = -1,
  window = -1
}

local config = {
  enable = true,
  title     = "Terminal",
  title_pos = "left",
  border    = "single",
  width     = 80,
  height    = 25,
  shell = "",
  keymap_toggle = "<M-t>",
  keymap_quit   = "q"
}

local function open_floating_window()
  local buffer = nil

  if vim.api.nvim_buf_is_valid(state.buffer) then
    buffer = state.buffer
  else
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "terminal", { buf = buffer })
    state.buffer = buffer
  end

  local row_pos    = math.floor((vim.o.lines - config.height) / 2)
  local column_pos = math.floor((vim.o.columns - config.width) / 2)

  local window_config = {
    relative  = "editor",
    width     = config.width,
    height    = config.height,
    row       = row_pos,
    col       = column_pos,
    style     = "minimal",
    border    = config.border,
    title     = (" " .. config.title .. " "),
    title_pos = config.title_pos
  }

  local window = nil

  window = vim.api.nvim_open_win(buffer, true, window_config)
  vim.api.nvim_set_option_value("winfixbuf", true, { win = window })
  vim.api.nvim_set_option_value("winfixwidth", true, { win = window })
  vim.api.nvim_set_option_value("winfixheight", true, { win = window })
  state.window = window
end

local function hide_floating_window()
  if vim.api.nvim_win_is_valid(state.window) then
    vim.api.nvim_win_hide(state.window)
    state.window = -1
  end
end

local function is_floating_buffer(buffer)
  return buffer == state.buffer
end

local function is_floating_window(window)
  return window == state.window
end

local function start_terminal()
  if vim.api.nvim_buf_is_valid(state.buffer)then
    if vim.b[state.buffer].terminal_job_id then return end

    local shell = (config.shell ~= "" and config.shell) or vim.o.shell

    vim.fn.jobstart(shell, { term = true })
  end
end

local function stop_terminal()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buffer].buftype == "terminal" then
      local job_id = vim.b[buffer].terminal_job_id

      if job_id then
        pcall(vim.api.nvim_chan_send, job_id, "exit\r")
        pcall(vim.fn.jobstop, job_id)
      end
    end
  end
end

local function attach_keymaps()
  local opts = { buffer = state.buffer, silent = true }

  vim.keymap.set("n", config.keymap_quit, hide_floating_window, opts)
end

local function attach_autocmd()
  local group = vim.api.nvim_create_augroup("TerminalProtect", { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      vim.schedule(function()
        hide_floating_window()
      end)
    end
  })

  vim.api.nvim_create_autocmd("QuitPre", {
    group = group,
    callback = function()
      stop_terminal()
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
end

function M.toggle()
  if vim.api.nvim_get_current_win() == state.window then
    hide_floating_window()
  else
    open_floating_window()
    start_terminal()
    attach_keymaps()
    attach_autocmd()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.keymap.set("n", config.keymap_toggle, M.toggle, { desc = "Toggle Terminal" })
    vim.api.nvim_create_user_command("Terminal", M.toggle, {})
  end
end

return M
