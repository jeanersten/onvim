local M = {}

local system = require("util.system")

local state = {
  buffer = -1,
  window = -1,
  workspace_directory = vim.fn.getcwd(),
  current_directory   = vim.fn.getcwd(),
  header_row_height   = 3,
  last_cursor_row     = 4,
  items               = {},
  tree_mode      = true,
  tree_nodes     = {},
  expanded_dirs  = {}
}

local config = {
  enable = true,
  title     = "Explorer",
  title_pos = "left",
  border    = "single",
  width     = 80,
  height    = 25,
  tree_indent = 1,
  icon_header_normal    = "[ND]",
  icon_header_workspace = "[WD]",
  icon_folder_parent    = "[PAR]",
  icon_folder_current   = "[CUR]",
  icon_folder_normal    = "[FDR]",
  icon_file_normal      = "[FLE]",
  icon_file_code        = "[CDE]",
  icon_file_config      = "[CFG]",
  icon_file_text        = "[TXT]",
  icon_file_image       = "[IMG]",
  icon_file_executable  = "[EXE]",
  icon_bullet           = ".",
  icon_tree_expanded    = "-",
  icon_tree_collapsed   = "+",
  keymap_toggle           = "<M-e>",
  keymap_select_item      = "<CR>",
  keymap_add_item         = "a",
  keymap_delete_item      = "d",
  keymap_move_item        = "m",
  keymap_open_in_system   = "o",
  keymap_go_previous_dir  = "-",
  keymap_go_workspace_dir = "w",
  keymap_go_home_dir      = "~",
  keymap_refresh          = "y",
  keymap_toggle_tree      = "t",
  keymap_quit             = "q"
}

local function open_floating_window()
  local buffer = nil

  if vim.api.nvim_buf_is_valid(state.buffer) then
    buffer = state.buffer
  else
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "explorer", { buf = buffer })
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
  vim.api.nvim_set_option_value("cursorline", true, { win = window })
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

local function get_item_icon(item)
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

  if item.type == "folder" then
    if item.name == ".." then
      return config.icon_folder_parent
    elseif item.name == "." then
      return config.icon_folder_current
    else
      return config.icon_folder_normal
    end
  else
    local extension = item.name:match("%.([^%.]+)$")
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
end

local function scan_directory(path, depth)
  depth = depth or 0

  local items  = {}
  local handle = vim.uv.fs_scandir(path)

  if not handle then return items end
  
  local folders = {}
  local files = {}
  
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    
    local item_path = path .. system.get_separator() .. name
    
    if type == "directory" then
      table.insert(folders, {
        name = name,
        path = item_path,
        type = "folder",
        depth = depth
      })
    else
      table.insert(files, {
        name = name,
        path = item_path,
        type = "file",
        depth = depth
      })
    end
  end
  
  table.sort(folders, function(a, b) return a.name < b.name end)
  table.sort(files, function(a, b) return a.name < b.name end)
  
  for _, folder in ipairs(folders) do
    table.insert(items, folder)
  end
  
  for _, file in ipairs(files) do
    table.insert(items, file)
  end
  
  return items
end

local function build_tree_structure()
  state.tree_nodes = {}
  
  local function add_tree_items(path, depth)
    local items = scan_directory(path, depth)
    
    for _, item in ipairs(items) do
      table.insert(state.tree_nodes, item)
      
      if item.type == "folder" and state.expanded_dirs[item.path] then
        add_tree_items(item.path, depth + 1)
      end
    end
  end
  
  add_tree_items(state.current_directory, 0)
end

local function render_tree()
  local lines = {}
  local header_icon = ""

  if state.current_directory:match(vim.pesc(state.workspace_directory)) then
    header_icon = config.icon_header_workspace
  else
    header_icon = config.icon_header_normal
  end

  table.insert(lines, "")
  table.insert(lines, " " .. header_icon .. " " .. state.current_directory)
  table.insert(lines, "")

  for _, item in ipairs(state.tree_nodes) do
    local indent = string.rep(" ", item.depth * config.tree_indent)
    local icon = get_item_icon(item)
    local line = ""
    
    if item.type == "folder" then
      local expand_icon = state.expanded_dirs[item.path] and
                          config.icon_tree_expanded or
                          config.icon_tree_collapsed

      line = string.format(". %s%s%s %s%s", indent, expand_icon, icon,
                           item.name, system.get_separator())
    else
      line = string.format(" %s  %s %s", indent, icon, item.name)
    end
    
    table.insert(lines, line)
  end

  if vim.api.nvim_buf_is_valid(state.buffer) then
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.buffer })
    vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buffer })
  end
end

local function render_list()
  local lines = {}
  local header_icon = ""

  if state.current_directory:match(vim.pesc(state.workspace_directory)) then
    header_icon = config.icon_header_workspace
  else
    header_icon = config.icon_header_normal
  end

  table.insert(lines, "")
  table.insert(lines, " " .. header_icon .. " " .. state.current_directory)
  table.insert(lines, "")

  for _, item in ipairs(state.items) do
    local line = string.format(config.icon_bullet .. " %s %s",
                               get_item_icon(item), item.name)

    if item.type == "folder" then
      line = line .. system.get_separator()
    end

    table.insert(lines, line)
  end

  if vim.api.nvim_buf_is_valid(state.buffer) then
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.buffer })
    vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buffer })
  end
end

local function render()
  if state.tree_mode then
    build_tree_structure()
    render_tree()
  else
    render_list()
  end
end

local function update_items()
  state.items = {}

  local handle = vim.uv.fs_scandir(state.current_directory)

  if not handle then return {} end

  if not system.is_root(state.current_directory) then
    table.insert(state.items, {
      name = "..",
      path = vim.fn.fnamemodify(state.current_directory, ":h"),
      type = "folder"
    })
  end

  table.insert(state.items, {
    name = ".",
    path = state.current_directory,
    type = "folder"
  })

  local folders = {}
  local files   = {}

  while true do
    local name, type = vim.uv.fs_scandir_next(handle)

    if not name then break end

    local path = ""

    if state.current_directory:sub(-1) == system.get_separator() then
      path = state.current_directory .. name
    else
      path = state.current_directory .. system.get_separator() .. name
    end

    if type == "directory" then
      local item = {
        name = name,
        path = path,
        type = "folder"
      }

      table.insert(folders, item)
    else
      local item = {
        name = name,
        path = path,
        type = "file"
      }

      table.insert(files, item)
    end
  end

  for _, folder in ipairs(folders) do
    table.insert(state.items, folder)
  end

  for _, file in ipairs(files) do
    table.insert(state.items, file)
  end

  table.sort(state.items, function(a, b)
    if a.name == ".." and b.name ~= ".." then return true end
    if b.name == ".." and a.name ~= ".." then return false end

    if a.name == "." and b.name ~= "." then return true end
    if b.name == "." and a.name ~= "." then return false end

    if a.type ~= b.type then
      return a.type == "folder"
    end

    return a.name < b.name
  end)

  render()
end

local function get_current_item()
  local line_index = vim.api.nvim_win_get_cursor(state.window)[1]
  local item_index = line_index - state.header_row_height

  if line_index <= state.header_row_height then
    return nil
  end
  
  if state.tree_mode then
    if item_index > #state.tree_nodes then
      return nil
    end
    return state.tree_nodes[item_index]
  else
    if item_index > #state.items then
      return nil
    end
    return state.items[item_index]
  end
end

local function handle_item_select()
  local item = get_current_item()

  if not item then
    return
  end

  if item.type == "folder" then
    if state.tree_mode then
      if state.expanded_dirs[item.path] then
        state.expanded_dirs[item.path] = nil
      else
        state.expanded_dirs[item.path] = true
      end
      render()
    else
      state.current_directory = item.path
      update_items()
      vim.api.nvim_win_set_cursor(state.window,
                                  { state.header_row_height + 1, 0 })
    end
  else
    hide_floating_window()
    vim.schedule(function()
      vim.cmd("edit " .. vim.fn.fnameescape(item.path))
    end)
  end
end

local function handle_toggle_tree_mode()
  state.tree_mode = not state.tree_mode
  
  render()

  vim.api.nvim_win_set_cursor(state.window, { state.header_row_height + 1, 0 })
end

local function handle_item_create()
  local item = get_current_item()

  if not item then
    return
  end

  local base_path = item.type == "folder" and item.path or
                    vim.fn.fnamemodify(item.path, ":h")

  vim.ui.input({
    prompt = string.format("Create new item: %s", base_path) ..
                           system.get_separator(),
  }, function(input)
    if not input or input == "" then
      vim.notify("Item not created", vim.log.levels.INFO)

      return
    end

    local path             = vim.fs.joinpath(base_path, input)
    local parent_directory = vim.fn.fnamemodify(path, ":h")

    local function exists_anywhere(p)
      if system.is_windows() then
        p = p:gsub("/", "\\")
      end

      local no_slash = p:gsub("[\\/]+$", "")

      return vim.fn.filereadable(no_slash) == 1 or
             vim.fn.isdirectory(no_slash) == 1
    end

    if system.is_windows() then
      path = path:gsub("/", "\\")
      parent_directory = parent_directory:gsub("/", "\\")
    end

    path = path:gsub("[/\\]$", "")

    if exists_anywhere(path) then
      vim.notify("Item already exists", vim.log.levels.ERROR)

      return
    end

    local is_folder = input:match("[/\\]$") ~= nil

    if is_folder then
      vim.fn.mkdir(path, "p")
      vim.notify(string.format("Item '%s' created (folder)", path),
                 vim.log.levels.INFO)
    else
      vim.fn.mkdir(parent_directory, "p")
      local file = io.open(path, "w")

      if file then
        file:close()
        vim.notify(string.format("Item '%s' created (file)", path),
                   vim.log.levels.INFO)
      else
        vim.notify(string.format("Failed to create item '%s'", path),
                   vim.log.levels.ERROR)

        return
      end
    end

    if not state.tree_mode then
      state.current_directory = parent_directory
    end
    update_items()

    if vim.api.nvim_win_is_valid(state.window) then
      local buffer = vim.api.nvim_win_get_buf(state.window)
      local lines  = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

      local target_name = vim.fn.fnamemodify(path, ":t")
      local target_line = nil

      for i, line in ipairs(lines) do
        local pattern = "%f[%w]" .. vim.pesc(target_name) .. "%f[%W]"

        if line:find(pattern) then
          target_line = i
        end
      end
      if target_line then
        vim.api.nvim_win_set_cursor(state.window, { target_line, 0 })
      end
    end
  end)
end

local function handle_item_delete()
  local item = get_current_item()

  if not item or item.name == "." or item.name == ".." then return end

  if vim.fn.filereadable(item.path) == 0 and
     vim.fn.isdirectory(item.path) == 0 then
    vim.notify(string.format("Path '%s' no longer exists", item.path),
               vim.log.levels.ERROR)

    return
  end

  vim.ui.input({
    prompt = string.format("Delete '%s'? (y/n): ", item.path)
  }, function(input)
    if not input or input == "" or input:lower() == "n" then
      vim.notify("Item not deleted", vim.log.levels.INFO)

      return
    elseif input and input:lower() ~= "y" then
      vim.notify("Invalid input", vim.log.levels.WARN)

      return
    end

    local function do_delete()
      local ok = vim.fn.delete(item.path, "rf") == 0

      if ok then
        local buffer = vim.fn.bufnr(item.path)

        if buffer ~= -1 then
          local windows = vim.fn.win_findbuf(buffer)

          for _, window in ipairs(windows) do
            vim.api.nvim_win_call(window, function()
              if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
                vim.cmd("enew")
              elseif vim.fn.winnr("$") > 1 then
                vim.cmd("bprevious")
              else
                vim.cmd("new")
              end
            end)
          end

          vim.api.nvim_buf_delete(buffer, { force = true })
        end

        update_items()
        vim.notify(string.format("Item '%s' deleted", item.name),
                   vim.log.levels.INFO)
      else
        vim.notify(string.format("Failed to delete item '%s'", item.name),
                   vim.log.levels.ERROR)
      end
    end

    if item.type == "folder" then
      local result = vim.fn.systemlist(system.get_item_count_command(item.path))
      local file_count = tonumber(result[1]) or 0

      if file_count > 0 then
        vim.ui.input({
          prompt = string.format(
            "Folder contains %d items. Delete anyway? (y/n): ", file_count
          )
        }, function(confirm)
          if not confirm or confirm == "" or confirm:lower() == "n" then
            vim.notify("Item not deleted", vim.log.levels.INFO)

            return
          elseif confirm and confirm:lower() ~= "y" then
            vim.notify("Invalid input", vim.log.levels.WARN)

            return
          end

          do_delete()
        end)
      else
        do_delete()
      end
    else
      do_delete()
    end
  end)
end

local function handle_item_move()
  local item = get_current_item()

  if not item or item.name == "." or item.name == ".." then
    return
  end

  local parent_directory = vim.fn.fnamemodify(item.path, ":h")

  vim.ui.input({
    prompt = string.format("Move item '%s' to: ", item.name),
    default = parent_directory .. system.get_separator(),
    completion = "dir"
  }, function(input)
    if not input or input == "" then
      vim.notify("Item not moved", vim.log.levels.INFO)

      return
    end

    local old_path = vim.fn.fnamemodify(item.path, ":p")
    local new_path = vim.fn.fnamemodify(input, ":p")

    if input:sub(-1) == system.get_separator() then
      if not vim.fn.isdirectory(new_path) then
        local ok = vim.fn.mkdir(new_path, "p")

        if ok == 0 then
          vim.notify(string.format("Failed to create target folder '%s'",
                     new_path), vim.log.levels.ERROR)

          return
        end
      end

      new_path = vim.fs.joinpath(new_path, item.name)
    end

    local function exists_anywhere(p)
      if system.is_windows() then
        p = p:gsub("/", "\\")
      end

      local no_slash = p:gsub("[\\/]+$", "")

      return vim.fn.filereadable(no_slash) == 1 or
             vim.fn.isdirectory(no_slash) == 1
    end

    if system.is_windows() then
      old_path = old_path:gsub("/", "\\")
      new_path = new_path:gsub("/", "\\")
    end

    if new_path == old_path then
      vim.notify("Item target path is the same", vim.log.levels.WARN)

      return
    elseif exists_anywhere(new_path) then
      vim.notify("Item already exists", vim.log.levels.ERROR)

      return
    end

    local ok = vim.uv.fs_rename(old_path, new_path)

    if ok then
      if state.window and vim.api.nvim_win_is_valid(state.window) then
        local lines  = vim.api.nvim_buf_get_lines(state.buffer, 0, -1, false)

        local target_name = vim.fn.fnamemodify(new_path, ":t")

        for i, line in ipairs(lines) do
          local pattern = "%f[%w]" .. vim.pesc(target_name) .. "%f[%W]"

          if line:find(pattern) then
            vim.api.nvim_win_set_cursor(state.window, { i, 0 })

            break
          end
        end
      end

      local buffer = vim.fn.bufnr(item.path)

      if buffer ~= -1 then
        vim.api.nvim_buf_set_name(buffer, new_path)
        vim.api.nvim_buf_call(buffer, function()
          vim.cmd("write!")
        end)
      end

      if not state.tree_mode then
        state.current_directory = vim.fn.fnamemodify(new_path, ":h")
      end
      update_items()
      vim.notify(string.format("Item '%s' moved to '%s'", item.name, new_path),
                 vim.log.levels.INFO)
    else
      vim.notify(string.format("Failed to move item '%s'", new_path),
                 vim.log.levels.ERROR)
    end
  end)
end

local function handle_item_open_in_system()
  local item = get_current_item()

  if not item then
    return
  end

  local command = string.format("%s %s", system.get_open_command(), item.path)

  vim.fn.system(command)
end

local function handle_go_previous_directory()
  if state.tree_mode then
    vim.notify("Use list mode to navigate directories", vim.log.levels.INFO)
    return
  end
  
  if system.is_root(state.current_directory) then
    vim.notify("Already at root", vim.log.levels.INFO)
  end

  local parent = vim.fn.fnamemodify(state.current_directory, ":h")

  state.current_directory = parent
  update_items()
  vim.api.nvim_win_set_cursor(state.window,
                              { state.header_row_height + 1, 0 })
end

local function constrain_cursor_position()
  local cursor = vim.api.nvim_win_get_cursor(state.window)
  local row    = cursor[1]
  local column = cursor[2]

  if row < state.header_row_height + 1 then
    vim.api.nvim_win_set_cursor(state.window,
                                { state.header_row_height + 1, 0 })

    return
  end

  if column ~= 0 then
    vim.api.nvim_win_set_cursor(state.window, { row, 0 })

    return
  end
end

local function attach_keymaps()
  local opts = { buffer = state.buffer, silent = true }

  vim.keymap.set("n", config.keymap_select_item, handle_item_select, opts)

  vim.keymap.set("n", config.keymap_add_item, handle_item_create, opts)

  vim.keymap.set("n", config.keymap_delete_item, handle_item_delete, opts)

  vim.keymap.set("n", config.keymap_move_item, handle_item_move, opts)

  vim.keymap.set("n", config.keymap_open_in_system,
                 handle_item_open_in_system, opts)

  vim.keymap.set("n", config.keymap_go_previous_dir,
                 handle_go_previous_directory, opts)
  
  vim.keymap.set("n", config.keymap_toggle_tree, handle_toggle_tree_mode, opts)

  vim.keymap.set("n", config.keymap_go_workspace_dir, function()
    state.current_directory = state.workspace_directory
    update_items()
    vim.api.nvim_win_set_cursor(state.window,
                                { state.header_row_height + 1, 0 })
  end, opts)

  vim.keymap.set("n", config.keymap_go_home_dir, function()
    state.current_directory = vim.fn.expand("~")
    update_items()
    vim.api.nvim_win_set_cursor(state.window,
                                { state.header_row_height + 1, 0 })
  end, opts)

  vim.keymap.set("n", config.keymap_refresh, update_items, opts)

  vim.keymap.set("n", config.keymap_quit, hide_floating_window, opts)

  vim.keymap.set("n", "r", "<Nop>", opts)

  vim.keymap.set("n", "R", "<Nop>", opts)

  vim.keymap.set("n", "<2-LeftMouse>", handle_item_select, opts)
end

local function attach_autocmd()
  local group = vim.api.nvim_create_augroup("ExplorerProtect", { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      vim.schedule(function()
        hide_floating_window()
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

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    buffer = state.buffer,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode

      if mode == "v" or mode == "V" or mode == "\x16" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
          "<Esc>", true, false, true), "n", false
        )
      end
    end
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = state.buffer,
    callback = function()
      constrain_cursor_position()
    end
  })
end

function M.toggle()
  if vim.api.nvim_get_current_win() == state.window then
    hide_floating_window()
  else
    open_floating_window()
    update_items()
    attach_keymaps()
    attach_autocmd()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.enable then
    vim.g.loaded_netrw = 1
    vim.keymap.set("n", config.keymap_toggle, M.toggle,
                   { desc = "Toggle Explorer" })
    vim.api.nvim_create_user_command("Explorer", M.toggle, {})
  end
end

return M
