# ~/.bashrc - Interactive Bash shell configuration (based on .zshrc)

# Create $HOME/.local/bin folder if it doesn't exist
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"

# Add $HOME/.local/bin to PATH if not already in PATH
if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# History settings must be configured BEFORE oh-my-posh so oh-my-posh can append to PROMPT_COMMAND
HISTSIZE=50000
HISTFILE="$HOME/.bash_history"
HISTFILESIZE=$HISTSIZE
shopt -s histappend                # Append to history, don't overwrite
export PROMPT_COMMAND='history -a' # Save each command immediately

# Add in oh-my-posh
# Install oh-my-posh in $HOME/.local/bin if not already installed
if [ ! -x "$(command -v oh-my-posh)" ]; then
    echo "Installing oh-my-posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

# Initialize oh-my-posh with fallback configurations
if [ -f "$HOME/.config/ohmyposh/not_so_bad.omp.json" ]; then
    OMP_OUT="$(oh-my-posh.exe init bash --config "$(cygpath -w "$HOME/.config/ohmyposh/not_so_bad.omp.json")" 2>/dev/null)"
    eval "$OMP_OUT"
elif [ -f "$HOME/dotfiles/.config/ohmyposh/not_so_bad.omp.json" ]; then
    OMP_OUT="$(oh-my-posh.exe init bash --config "$(cygpath -w "$HOME/dotfiles/.config/ohmyposh/not_so_bad.omp.json")" 2>/dev/null)"
    eval "$OMP_OUT"
else
    OMP_OUT="$(oh-my-posh.exe init bash 2>/dev/null)"
    eval "$OMP_OUT"
fi

# Shell integrations
# Install fzf if not installed
if [[ ! -f "$HOME/.fzf.bash" && ! -x "$(command -v fzf)" ]]; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

# fzf configuration
if [ -f "$HOME/.fzf.bash" ]; then
    source "$HOME/.fzf.bash"
fi
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

# Shell integrations / Homebrew
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

# Kubectl / Kubecolor completion
if [ -x "$(command -v kubectl)" ]; then
    source <(kubectl completion bash)
    if [ -x "$(command -v kubecolor)" ]; then
        complete -o default -F _kubectl kubecolor
        alias k=kubecolor
    fi
fi

# ====== Aliases & Functions (Based on .zsh_profile) ======
alias ls='ls --color'
alias rsync='rsync --info=progress2'

glitchgit() {
    GIT_COMMITTER_DATE="$(date --date="$1")" git commit --amend --no-edit --date "$(date --date="$1")"
}

curlFileDrive() {
    # Config
    local rcloneRemote="adpatil:CurlChatUploads/"
    local chatWebhook='https://chat.googleapis.com/v1/spaces/AAAAqWooSPA/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=a-DS4_tvOjZr0PuB4m3zeaI0i0ac620yO9e-gYnbvsc'
    # Check if $1 has a leading '/' before any alphanumeric character
    if [[ ! "$1" =~ ^/[^/]*[a-zA-Z0-9] ]]; then
        # Prepend '/' to $1
        local filepath="./$1"
    else
        local filepath="$1"
    fi
    local filename="${1##*/}"
    local base_filename="${filename%.*}"
    local ext="${filename##*.}"

    local counter=1
    local unique_filename="$filename"

    local remote_files
    remote_files=$(rclone lsf "$rcloneRemote" | awk '{print $NF}')

    while echo "$remote_files" | grep -q "^$unique_filename$"; do
        unique_filename="${base_filename}-${counter}.${ext}"
        ((counter++))
    done

    echo "$unique_filename"
    echo "rclone copyto -P '$filepath' '$rcloneRemote$unique_filename'"
    rclone copyto -P "$filepath" "$rcloneRemote$unique_filename" \
    && shareLink=$(rclone link "$rcloneRemote$unique_filename") \
    && curl -X POST \
         -H "Content-Type: application/json" \
         -d "{
             'text': 'Sender: $(hostname)
Filename: $(echo ${1##*/})
Here is the link to the uploaded file: $shareLink'
         }" \
         "$chatWebhook"
}

driveGetFile() {
    local rcloneRemote="adpatil:CurlChatUploads/"
    echo "rclone copyto -P '$filepath' '$rcloneRemote$unique_filename'"
    rclone copyto -P "$rcloneRemote$1" "./$1"
}

ARIA2_TRACKERS="udp://tracker.opentrackr.org:1337/announce,udp://tracker.openbittorrent.com:6969/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.moeking.me:6969/announce,udp://open.stealth.si:80/announce,udp://tracker1.bt.moack.co.kr:80/announce"

aria2update_trackers() { 
    local url="https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/all.txt" 
    ARIA2_TRACKERS=$(curl -fsSL "$url" | awk 'NF' | paste -sd, -) 
    echo "Updated ARIA2_TRACKERS (length: ${#ARIA2_TRACKERS})" 
}

aria2t() { 
    aria2c \
    --enable-dht=true \
    --enable-dht6=true \
    --enable-peer-exchange=true \
    --bt-enable-lpd=true \
    --bt-max-peers=200 \
    --dht-listen-port=6881-6991 \
    --listen-port=51413 \
    --seed-time=0 \
    --seed-ratio=0.0 \
    --bt-tracker="${ARIA2_TRACKERS}" \
    --summary-interval=30 \
    --check-integrity=true \
    --file-allocation=falloc \
    --continue=true \
    "$@" 
}

# ====== Startup Directory ======
# If terminal starts in system32 (often happens when running as Admin), switch to home
if [[ "${PWD,,}" == "/c/windows/system32" ]]; then
    cd ~
fi
