### 🧭 PATH Configuration ###

# Apple Silicon (M1/M2) Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Intel Mac Homebrew
export PATH="/usr/local/bin:$PATH"

# Add custom binary paths
export PATH="$HOME/.dotfiles/lazygit:$PATH"
export PATH="$HOME/.console-ninja/.bin:$PATH"

### 🧠 Environment Setup ###

# Starship prompt config location
export XDG_CONFIG_HOME="$HOME/.dotfiles"
export STARSHIP_CONFIG="$HOME/.dotfiles/starship/starship.toml"

# Set terminal type for full color support
export TERM="xterm-256color"

### ⚙️ Initialize Zoxide First ###
# (so its completions are ready before compinit)

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # optional: alias cd to z
  alias cd='z'
fi

### 🚀 Autocompletion Setup ###

# Enable completion system
autoload -U compinit
compinit

# Tab-completion key binding (optional)
bindkey '^I' complete-word  # Default tab behavior

### 📝 Editor Configuration ###

# Use remote nvim if available (e.g. in Obsidian context)
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

### ✨ Aliases ###

# Better ls with icons and sorting using eza
alias ls="eza --icons=always -1 --group-directories-first --git-ignore --sort=name"

### 🌟 Starship Prompt ###

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
# Auto load zsh-autosuggestions and zsh-syntax-highlighting
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
