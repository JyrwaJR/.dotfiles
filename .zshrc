# Enable autocompletion
autoload -U compinit
compinit

# Add Homebrew paths for M1 (Apple Silicon) and Intel Macs
export PATH="/opt/homebrew/bin:$PATH"   # For Apple Silicon (M1/M2)
export PATH="/usr/local/bin:$PATH"       # For Intel Macs

# Add lazygit path from dotfiles (adjust if the path is different)
export PATH="$HOME/.dotfiles/lazygit:$PATH"

# Starship configuration
export XDG_CONFIG_HOME="$HOME/.dotfiles"
export STARSHIP_CONFIG="$HOME/.dotfiles/starship/starship.toml"

# If Homebrew is installed, add its binary path to $PATH
if which brew > /dev/null; then
  export PATH="$(brew --prefix)/bin:$PATH"
fi

# Initialize Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Optionally, you can set Fira Code Nerd Font as a fallback (just in case)
export TERM="xterm-256color"  # Ensures proper color rendering

# Initialize zoxide (smarter 'cd' command) with autocompletion
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # Enable autocompletion for `z` command
  compdef _zoxide z  # This sets up autocompletion for 'z'
  
  # Alias `cd` to `z` to completely replace it
  alias cd='z'
fi

# Set eza as the default 'ls' command with options for icons and sorting
alias ls="eza --icons=always -1 --group-directories-first --git-ignore --sort=name"

# Set up Neovim to use the correct configuration (if necessary)
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    export VISUAL="nvim"
    export EDITOR="nvim"
fi

# Ensure correct tab completion for 'z' (Zoxide)
bindkey '^I' menu-complete  # Similar to 'bind' in bash, zsh uses 'bindkey'
