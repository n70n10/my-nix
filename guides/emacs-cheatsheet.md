# Emacs Cheatsheet

> Normal mode bindings use `SPC` as leader. All `C-` bindings remain active in insert mode and globally.

---

## Meow — Modal Editing

### Mode Switching

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `I` | Open line above |
| `a` | Append after cursor |
| `A` | Open line below |
| `<ESC>` | Return to normal mode |

### Motion

| Key | Action |
|-----|--------|
| `h j k l` | Left / down / up / right |
| `H J K L` | Expand selection left / down / up / right |
| `w` | Mark word |
| `W` | Mark symbol |
| `b` | Back word |
| `B` | Back symbol |
| `e` | Next word |
| `E` | Next symbol |
| `f` | Find char forward |
| `t` | Till char forward |
| `x` | Select line |
| `X` / `Q` | Go to line |
| `o` | Select block |
| `O` | To block |
| `[` / `]` | Beginning / end of thing |
| `,` | Inner of thing |
| `.` | Bounds of thing |

### Editing

| Key | Action |
|-----|--------|
| `d` | Delete (forward) |
| `D` | Delete (backward) |
| `c` | Change selection |
| `r` | Replace char |
| `s` | Kill selection |
| `y` | Yank (copy) |
| `p` | Paste |
| `u` | Undo |
| `U` | Undo in selection |
| `m` | Join lines |
| `n` | Search next |
| `;` | Reverse direction |
| `g` | Cancel selection |
| `G` | Grab (secondary selection) |
| `R` | Swap grab |
| `Y` | Sync grab |
| `z` | Pop selection |
| `'` | Repeat last command |
| `q` | Quit window |

### Digits / Misc

| Key | Action |
|-----|--------|
| `1`–`9` | Expand selection (tree-sitter units) |
| `-` | Negative argument |
| `SPC /` | Describe key |
| `SPC ?` | Meow cheatsheet |

---

## SPC Leader (Normal Mode)

### Files — `SPC f`

| Key | Action |
|-----|--------|
| `SPC f f` | Open file |
| `SPC f r` | Recent files |
| `SPC f s` | Save buffer |
| `SPC f S` | Save as |

### Buffers — `SPC b`

| Key | Action |
|-----|--------|
| `SPC b b` | Switch buffer |
| `SPC b d` | Kill buffer |
| `SPC b r` | Revert buffer |
| `SPC b n` | Next buffer |
| `SPC b p` | Previous buffer |
| `SPC b i` | ibuffer |

### Windows — `SPC w`

| Key | Action |
|-----|--------|
| `SPC w s` | Split horizontal |
| `SPC w v` | Split vertical |
| `SPC w d` | Delete window |
| `SPC w o` | Delete other windows |
| `SPC w u` | Winner undo |
| `SPC w r` | Winner redo |
| `SPC w h/j/k/l` | Move to window |

### Search — `SPC s`

| Key | Action |
|-----|--------|
| `SPC s s` | Search lines (consult) |
| `SPC s r` | Ripgrep |
| `SPC s f` | Find file |
| `SPC s i` | Imenu |
| `SPC s .` | Embark act |

### Git — `SPC g`

| Key | Action |
|-----|--------|
| `SPC g g` | Magit status |
| `SPC g b` | Magit blame |
| `SPC g l` | Magit log |
| `SPC g d` | Diff buffer |
| `SPC g s` | Stage file |

### Code / LSP — `SPC c`

| Key | Action |
|-----|--------|
| `SPC c a` | Code actions |
| `SPC c r` | Rename symbol |
| `SPC c f` | Format buffer |
| `SPC c d` | Go to definition |
| `SPC c D` | Definition (other window) |
| `SPC c R` | Find references |
| `SPC c e` | List errors (flymake) |
| `SPC c h` | Hover docs |

### Project — `SPC p`

| Key | Action |
|-----|--------|
| `SPC p p` | Switch project |
| `SPC p f` | Find file in project |
| `SPC p b` | Switch project buffer |
| `SPC p k` | Kill project buffers |
| `SPC p s` | Search in project |

### Jump — `SPC j`

| Key | Action |
|-----|--------|
| `SPC j j` | Jump to char (avy) |
| `SPC j l` | Jump to line (avy) |
| `SPC j d` | Jump to definition |

### Toggle — `SPC t`

| Key | Action |
|-----|--------|
| `SPC t l` | Line numbers |
| `SPC t h` | Highlight line |
| `SPC t w` | Whitespace mode |
| `SPC t v` | Visual line mode |
| `SPC t i` | Indent bars |

### Help — `SPC h`

| Key | Action |
|-----|--------|
| `SPC h f` | Describe function |
| `SPC h v` | Describe variable |
| `SPC h k` | Describe key |
| `SPC h m` | Describe mode |
| `SPC h p` | Describe package |

### Misc

| Key | Action |
|-----|--------|
| `SPC x` | M-x (execute command) |
| `SPC ;` | Comment / uncomment |
| `SPC u` | Universal argument |
| `SPC '` | Repeat |
| `SPC q q` | Save and quit |

---

## Global Bindings (all modes)

### Consult

| Key | Action |
|-----|--------|
| `C-s` | Search lines |
| `C-x b` | Switch buffer |
| `M-y` | Yank pop |
| `M-g g` | Go to line |
| `M-g i` | Imenu |
| `M-s r` | Ripgrep |
| `M-s f` | Find file |

### Embark

| Key | Action |
|-----|--------|
| `C-.` | Embark act |
| `C-;` | Embark dwim |

### Editing

| Key | Action |
|-----|--------|
| `C-=` | Expand region |
| `C->` | Mark next like this (mc) |
| `C-<` | Mark previous like this (mc) |
| `C-c a` | Mark all like this (mc) |
| `M-↑ / M-↓` | Move line / region |

### Navigation

| Key | Action |
|-----|--------|
| `M-j` | Avy jump to char |
| `M-J` | Avy jump to line |
| `M-←/→/↑/↓` | Move between windows |

### Magit

| Key | Action |
|-----|--------|
| `C-x g` | Magit status |

---

## LSP Servers Required on `$PATH`

| Language | Server | Install |
|----------|--------|---------|
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| Nix | `nixd` | `nix-env -i nixd` |
| Markdown | `unified-language-server` | `npm i -g unified-language-server` |

---

## First-Run Setup

```
M-x nerd-icons-install-fonts
```
