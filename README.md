# my neovim config

Custom Neovim setup with an ofirkai-based theme and lazy.nvim plugin management.

## install dependencies

### tools used by this config

- `git`
- `fd`
- `rg` (ripgrep)
- `lazygit` (used by snacks lazygit integration)
- `stylua`
- `prettier` or `prettierd`
- `go` (for go tooling/plugins)

### nerd font

```bash
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip && unzip ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts && rm ~/.local/share/fonts/JetBrainsMono.zip && fc-cache -fv
```

### kitty font config

```kitty
font_family      JetBrainsMono Nerd Font Mono
bold_font        JetBrainsMono Nerd Font Mono Extra Bold
bold_italic_font JetBrainsMono Nerd Font Mono Extra Bold Italic
```
