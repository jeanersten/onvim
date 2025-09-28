local M = {}

local config = {
  enable = true,
  show_version    = true,
  show_tab_number = true,
  separator = "│"
}

local function get_version()
  local version = string.format("Neovim %s.%s.%s",
                                vim.version().major, vim.version().minor,
                                vim.version().patch)

  return version
end

local function get_file_name()
  local file_name  = ""
  local file_flags = ""

  if vim.bo.filetype == "explorer" then
    file_name = "- Explorer -"
  elseif vim.bo.filetype == "picker" then
    file_name = "- Picker -"
  elseif vim.bo.filetype == "terminal" then
    file_name = "- Terminal -"
  else
    file_name = vim.fn.expand("%:.")
    file_flags = "%h%m%r"
  end

  file_name = file_name ~= "" and file_name or "- No Name -"
  file_name = " " .. file_name .. " "
  file_name = file_name .. file_flags

  return file_name
end

local function get_tab_number()
  local tab_number = ""

  for i = 1, vim.fn.tabpagenr("$") do
    local tabline_hl = i == vim.fn.tabpagenr() and "%#TabLineSel#" or "%#TabLine#"
    tab_number = tab_number .. tabline_hl .. " " .. i .. " " .. "%#TabLineSel#" .. "%#TabLine#"
  end

  return tab_number
end

function M.get_format()
  local version    = get_version()
  local file_name  = get_file_name()
  local tab_number = get_tab_number()
  local separator  = config.separator

  local format = {}

  table.insert(format, "%#TabLine#")

  if config.show_version then
    table.insert(format, " ")
    table.insert(format, version)
    table.insert(format, " ")
    table.insert(format, separator)
  end

  table.insert(format, "%=")

  table.insert(format, file_name)

  table.insert(format, "%=")

  if config.show_tab_number then
    table.insert(format, separator)
    table.insert(format, " ")
    table.insert(format, tab_number)
    table.insert(format, " ")
  end

  table.insert(format, "%#TabLine#")

  return table.concat(format)
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.o.showtabline = 2
    vim.o.tabline = "%!v:lua.require('module.tabline').get_format()"
  end
end

return M
