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

# Initialize Starship prompt (Add this if you haven't already)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"  # or zsh, fish, depending on your shell
fi

# Optionally, you can set Fira Code Nerd Font as a fallback (just in case)
export TERM="xterm-256color"  # Ensures proper color rendering

# Initialize zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"  # Or bash, fish, depending on your shell
fi

# Set eza as the default 'ls' command (Optional)
alias ls="eza --color=auto"  # You can customize eza's options if needed
