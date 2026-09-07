### 🧭 PATH Configuration ###

# Apple Silicon Homebrew
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# Intel Homebrew
if [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Custom binaries
export PATH="$HOME/.config/lazygit:$PATH"
export PATH="$HOME/.console-ninja/.bin:$PATH"

### 🧠 Environment Setup ###
export XDG_CONFIG_HOME="$HOME/.config"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export TERM="xterm-256color"

# Aliases
# Open ports
alias op="opencode --port --continue --auto"

### 🚀 NVM (Homebrew) Setup ###
export NVM_DIR="/opt/homebrew/opt/nvm"  # Homebrew path
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # load bash completion

### ⚙️ Zoxide (before compinit) ###
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

### 🚀 Completion System ###
autoload -U compinit
compinit
bindkey '^I' complete-word

### 📝 Editor Configuration ###
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

### ✨ Aliases ###
alias ls="eza --icons=always -1 --group-directories-first --git-ignore --sort=name"

### 🌟 Starship Prompt ###
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

### 🎨 Zsh Plugins ###
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

