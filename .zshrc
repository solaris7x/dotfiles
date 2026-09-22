# Created by newuser for 5.8.1

# Load .zsh_alias if it exists
if [ -f ~/.zsh_alias ]; then
    source ~/.zsh_alias
fi

# Create $HOME/.local/bin foler if doesnt exist
[ -d $HOME/.local/bin ] || mkdir $HOME/.local/bin

# Add $HOME/.local/bin to PATH if not already in PATH
if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
    export PATH=$HOME/.local/bin:$PATH
fi

# Add in oh-my-posh
# Install oh-my-posh in $HOME/.local/bin if not already installed
if [ ! -x "$(command -v oh-my-posh)" ]; then
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi
# eval "$(oh-my-posh init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/not_so_bad.omp.json)"

# Shell integrations
# Install fzf if not installed
if [[ ! -f $HOME/.fzf.zsh && ! -x "$(command -v fzf)" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# fzf for command history
source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Silent rm
setopt rmstarsilent

# History
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory

# Vscode config
# [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

###  Add in zsh plugins
# Add in zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Add in zsh completions
zinit light zsh-users/zsh-completions

# Add aoe completions
command -v aoe >/dev/null 2>&1 && eval "$(aoe completion zsh)"

# Load completions
autoload -Uz compinit && compinit

zinit light zsh-users/zsh-autosuggestions
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#242b36,bg=bold,underline"
# Partial accept
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-kill-word

# fzf like auto completion
zstyle ':completion:*' menu no
zinit light Aloxaf/fzf-tab

# No clue what this does , just recommended by zinit
zinit cdreplay -q

# Add in oh-my-posh
# eval "$(oh-my-posh init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/not_so_bad.omp.json)"

# Shell integrations
if [ -d /home/linuxbrew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    # Nodejs brew
    if [ -d '/home/linuxbrew/.linuxbrew/opt/node@20' ]; then
        export PATH="/home/linuxbrew/.linuxbrew/opt/node@20/bin:$PATH"
        export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/node@20/lib"
        export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/node@20/include"
    fi
fi


# RKE2
if [ -d /var/lib/rancher/rke2/bin ]; then
    export PATH="$PATH:/var/lib/rancher/rke2/bin"
fi

# If kubectl is installed
if [ -x "$(command -v kubectl)" ]; then
    source <(kubectl completion zsh)
    # Make "kubecolor" borrow the same completion logic as "kubectl"
    compdef kubecolor=kubectl
    alias k=kubecolor
fi

# bun completions
[ -s "/home/ubuntu/.bun/_bun" ] && source "/home/ubuntu/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.free-coding-models.env ] && . ~/.free-coding-models.env  # free-coding-models-env

# Added by Antigravity CLI installer
export PATH="/home/ubuntu/.local/bin:$PATH"

# API keys
export CONTEXT7_API_KEY=ctx7sk-730e3c2b-d033-43fe-bca5-137cb80be98b

# Alias
killport() {
     local port=$1 pid
     if command -v lsof >/dev/null; then
       pid=$(lsof -ti :$port | head -n1)
     else
       pid=$(ss -tulpn | grep ":$port" | grep -oP 'pid=\K[0-9]+' | head -n1)
     fi
     if [ -z "$pid" ]; then
       echo "No process on port $port"
       return 1
     fi
     echo "Killing PID $pid on port $port"
     kill "$pid" && echo "Killed." || echo "Failed."
   }



# opencode
export PATH=/home/ubuntu/.opencode/bin:$PATH
