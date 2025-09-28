local servers = { "clangd", "lua-language-server" }

for _, server in ipairs(servers) do
  if vim.fn.executable(server) == 1 then
    vim.lsp.enable(server)
  end
end

vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    prefix = "^",
    spacing = 1
 },
  signs = true,
  underline = true,
  update_in_insert = false
})
