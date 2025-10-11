# Onvim

Forget the name, it's a small Neovim configuration built without any external plugins.
Every tool, including floating terminal, file explorer, and picker, is implemented directly in Lua.
Huge thanks to the Neovim developers for adding many powerful built-in features in recent versions.

---

## Overview

![screenshot](https://github.com/user-attachments/assets/913e197a-0037-470d-8e06-ad52caebbf61)

Each extension implementation can be seen under `lua/module/`, with each module implemented as a single file.
I hope it is readable enough.

---

## Installation

#### Prerequisites

- **Neovim 0.11+**: https://github.com/neovim/neovim/releases
- **ripgrep**: https://github.com/BurntSushi/ripgrep/releases

---

#### Windows

1. Clone this repo to Neovim config folder:
   ```
   git clone https://github.com/jeanersten/onvim %LOCALAPPDATA%\nvim
   ```

2. Launch Neovim:
   ```
   nvim
   ```

---

#### Linux & MacOS

1. Clone this repo to Neovim config folder:
   ```
   git clone https://github.com/jeanersten/onvim ~/.config/nvim
   ```

2. Launch Neovim:
   ```
   nvim
   ```
