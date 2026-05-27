# Neovim Config (kickstart.nvim-based)

## Structure

- **`init.lua`** — single entrypoint, contains ALL config (~677 lines). NOT split across `lua/` modules.
- **`lua/custom/plugins/*.lua** — optional override pattern (commented out in `init.lua:268`). Enable by uncommenting `{ import = 'custom.plugins' }`.
- **`lazy-lock.json`** — lockfile for pinned plugin commits. Tracks but do not hand-edit.

## Plugin manager

lazy.nvim at `:help lazy.nvim.txt`. All plugins are configured inline in a single `require('lazy').setup({...})` call.

## Keymaps (leader = Space)

| binding | action |
|---|---|
| `<leader>fm` | LSP format |
| `<leader>neo` | Neoformat |
| `<leader>rr` | reload `$MYVIMRC` |
| `<leader>t` | toggle Neotree file explorer |
| `gd` | LSP go-to-definition |
| `gr` | Telescope LSP references |
| `K` | hover documentation |
| `<leader>hm` | Harpoon mark file |
| `<leader>qm` | Harpoon toggle menu |
| `C-q/w/e/r/t` | Harpoon nav file 1-5 |
| `C-9/C-0` | Harpoon nav next/prev |
| `<leader>[[/]]` | buffer previous/next |
| `<C-f>` | tmux sessionizer |

## LSP

- `mason.nvim` auto-installs servers to stdpath. Servers are defined in `local servers = {...}` (`init.lua:558`). Only `lua_ls` is enabled by default.
- Add new servers by adding entries to the `servers` table and restarting Neovim.
- LSP keymaps are attached via `on_attach` (`init.lua:507`): rename, code actions, go-to-definition, references, hover, diagnostics.

## Completion

nvim-cmp + LuaSnip + friendly-snippets. Tab/S-Tab for navigation, Enter to confirm.

## Treesitter

`ensure_installed`: `c`, `cpp`, `go`, `lua`, `python`, `rust`, `tsx`, `typescript`, `vimdoc`, `vim`. Text objects enabled (function/class/parameter inner/outer). Run `:TSUpdate` to update parsers.

## Style conventions

- indent: 4 spaces, expandtab, smartindent
- `vim.opt.tabstop = 4`, `shiftwidth = 4`, `softtabstop = 4`
- relative number + line number
- clipboard = unnamedplus (syncs with system clipboard)
- undo directory: `~/.vim/undodir`

## Customization

This is a personal config. Add new plugins by appending to the `require('lazy').setup({...})` list in `init.lua`. No CI, tests, or build steps — just edit and reload with `<leader>rr`.
