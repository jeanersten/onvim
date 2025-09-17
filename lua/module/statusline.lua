local M = {}

local config = {
  enable = true,
  show_mode = true,
  mode_normal       = "NRML",
  mode_insert       = "INST",
  mode_visual       = "VSAL",
  mode_visual_line  = "VLNE",
  mode_visual_block = "VBLK",
  mode_select       = "SLCT",
  mode_select_line  = "SLNE",
  mode_select_block = "SBLK",
  mode_command      = "CMND",
  mode_replace      = "RPLC",
  mode_terminal     = "TRML",
  separator = "│"
}

local function get_mode_name()
  local mode_type  = vim.fn.mode()
  local mode_names = {
    n       = " " .. config.mode_normal       .. " ",
    i       = " " .. config.mode_insert       .. " ",
    v       = " " .. config.mode_visual       .. " ",
    V       = " " .. config.mode_visual_line  .. " ",
    ["\22"] = " " .. config.mode_visual_block .. " ",
    s       = " " .. config.mode_select       .. " ",
    S       = " " .. config.mode_select_line  .. " ",
    ["\19"] = " " .. config.mode_select_block .. " ",
    c       = " " .. config.mode_command      .. " ",
    R       = " " .. config.mode_replace      .. " ",
    t       = " " .. config.mode_terminal     .. " "
  }

  return mode_names[mode_type] or "????"
end

local function get_file_name()
  local file_name = ""

  file_name = vim.fn.expand("%:t")
  file_name = file_name ~= "" and file_name or "- No Name -"
  file_name = " " .. file_name .. " "
  file_name = file_name

  return file_name
end

function M.get_format()
  local mode_name       = get_mode_name()
  local file_name       = get_file_name()
  local cursor_position = "%l:%c:%p%%"
  local separator       = config.separator

  local format = {}

  table.insert(format, "%#StatusLine#")

  if config.show_mode then
    table.insert(format, " ")
    table.insert(format, mode_name)
    table.insert(format, " ")
    table.insert(format, separator)
  end

  table.insert(format, " ")
  table.insert(format, file_name)
  table.insert(format, " ")
  table.insert(format, separator)

  table.insert(format, "%=")

  table.insert(format, separator)
  table.insert(format, " ")
  table.insert(format, cursor_position)
  table.insert(format, " ")

  table.insert(format, "%#StatusLine#")

  return table.concat(format)
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.o.showmode = false
    vim.o.laststatus = 3
    vim.o.statusline = "%!v:lua.require('module.statusline').get_format()"
  end
end

return M
