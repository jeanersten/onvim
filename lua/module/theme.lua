local M = {}

local system = require("util.system")

local state = {
 file_name = ".last_theme"
}

local config = {
  enable = true,
  default_theme = "zaman"
}

local function save_theme(theme_name)
  local data_path = vim.fn.stdpath("data")
  local file      = io.open(data_path .. system.get_separator() ..
                    state.file_name, "w")

  if file then
    file:write(theme_name)
    file:close()
    vim.notify(string.format("Theme '%s' saved", theme_name),
               vim.log.levels.INFO)
  else
    vim.notify("Failed to save theme", vim.log.levels.ERROR)
  end
end

local function load_theme()
  pcall(vim.cmd, string.format("colorscheme %s", config.default_theme))

  local data_path = vim.fn.stdpath("data")
  local file      = io.open(data_path .. system.get_separator() ..
                    state.file_name, "r")

  if file then
    local theme_name = ""

    theme_name = file:read("*all"):gsub("%s+$", "")
    file:close()

    if theme_name and theme_name ~= "" then
      local ok = pcall(vim.cmd, string.format("colorscheme %s", theme_name))

      if ok then
        vim.notify(string.format("Loaded theme: %s", theme_name),
                   vim.log.levels.INFO)
      else
        vim.notify(string.format("Theme '%s' not found, using default",
                   theme_name), vim.log.levels.WARN)
      end
    end
  end
end

local function change_theme(theme_name)
  local ok = pcall(vim.cmd, string.format("colorscheme %s", theme_name))

  if ok then
    save_theme(theme_name)
  else
    vim.notify(string.format("Failed to set theme '%s'", theme_name),
               vim.log.levels.ERROR)
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    load_theme()

    vim.api.nvim_create_user_command("Theme", function(cmd)
      change_theme(cmd.args)
    end, {
      nargs = 1,
      complete = function(arg_lead)
        local colorschemes = vim.fn.getcompletion("", "color")
        local matches      = {}

        for _, scheme in ipairs(colorschemes) do
          if scheme:match("^" .. vim.pesc(arg_lead)) then
            table.insert(matches, scheme)
          end
        end

        return matches
      end,
      desc = "Set and Save Theme"
    })
  end
end

return M
