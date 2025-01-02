# my neovim config

this is my neovim config with a custom theme

## install debendecies

Install fonts

```bash
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv
```

Add to kitty

```kitty
font_family      JetBrainsMono Nerd Font Mono
bold_font        JetBrainsMono Nerd Font Mono Extra Bold
bold_italic_font JetBrainsMono Nerd Font Mono Extra Bold Italic
```
