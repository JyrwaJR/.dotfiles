# Set Starship configuration file
export STARSHIP_CONFIG="$HOME/.dotfiles/starship/starship.toml"

# Initialize Starship prompt (if using Starship)
eval "$(starship init bash)"

# eza 'ls' command aliases (with icons, sorted by name, directories first)
alias ls="eza --icons=always -1 --group-directories-first --git-ignore --sort=name"

# Initialize Zoxide (a smarter cd command)
eval "$(zoxide init bash)"
alias cd="z"

# Ensure Neovim uses the correct configuration
export XDG_CONFIG_HOME="$HOME/.dotfiles"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Alias for fzf with bat for preview
alias fd="fzf --preview 'bat -n --color=always {}' --border"

# Function to search files with fzf and open them in Neovim
fzf_nvim() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always {}' --border) && nvim "$file"
}

alias fdn="fzf_nvim"

