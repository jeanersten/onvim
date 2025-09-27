local U = {}

function U.is_windows()
  return vim.uv.os_uname().sysname == "Windows_NT" or vim.fn.has("win32") == 1
end

function U.is_linux()
  return vim.uv.os_uname().sysname == "Linux"
end

function U.is_macos()
  return vim.uv.os_uname().sysname == "Darwin"
end

function U.is_root(directory)
  local root = false

  if U.is_windows() and directory:match("^[A-Za-z]:[\\/]?$") then
    root = true
  elseif not U.is_windows() and directory == "/" then
    root = true
  end

  return root
end

function U.get_separator()
  return U.is_windows() and "\\" or "/"
end

function U.get_open_command()
  if U.is_windows() then
    return "explorer"
  elseif U.is_macos() then
    return "open"
  elseif U.is_linux() then
    return "xdg-open"
  end
end

function U.get_item_count_command(path)
  if U.is_windows() then
    return string.format('dir /b "%s" | find /c /v ""', path)
  else
    return string.format('find "%s" -mindepth 1 | wc -l', path)
  end
end

return U
