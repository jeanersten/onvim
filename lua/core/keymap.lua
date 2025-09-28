local opts = { noremap = true, silent = true }

vim.keymap.set("i", "df", "<C-c>", opts)
vim.keymap.set("t", "df", "<C-\\><C-n>", opts)

vim.keymap.set("n", "<M-k>", "<CMD> wincmd k <CR>", opts)
vim.keymap.set("n", "<M-j>", "<CMD> wincmd j <CR>", opts)
vim.keymap.set("n", "<M-l>", "<CMD> wincmd l <CR>", opts)
vim.keymap.set("n", "<M-h>", "<CMD> wincmd h <CR>", opts)
vim.keymap.set("n", "<M-Up>",    "<CMD> horizontal resize +1 | set cmdheight=1 <CR>", opts)
vim.keymap.set("n", "<M-Down>",  "<CMD> horizontal resize -1 | set cmdheight=1 <CR>", opts)
vim.keymap.set("n", "<M-Right>", "<CMD> vertical resize +1 | set cmdheight=1 <CR>", opts)
vim.keymap.set("n", "<M-Left>",  "<CMD> vertical resize -1 | set cmdheight=1 <CR>", opts)

vim.keymap.set("n", "<M-x>", "<CMD> tabnext <CR>", opts)
vim.keymap.set("n", "<M-z>", "<CMD> tabprevious <CR>", opts)
vim.keymap.set("n", "<M-s>", "<CMD> bnext <CR>", opts)
vim.keymap.set("n", "<M-a>", "<CMD> bprevious <CR>", opts)

vim.keymap.set("n", "<M-c>", "<CMD> nohl <CR>", opts)

vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", opts)
