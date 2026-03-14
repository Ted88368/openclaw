# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="" # Using Starship instead

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ll='eza -la --icons'
alias ls='eza --icons'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

# History setup
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion
autoload -Uz compinit
compinit
