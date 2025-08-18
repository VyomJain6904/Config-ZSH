export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="apple"

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"

plugins=(
    ssh
    git
    sublime
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    zsh-history-substring-search
    zsh-interactive-cd
)


source $ZSH/oh-my-zsh.sh


# Function for IP Address
get_ip_address() {
    local ip
    ip=$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7}' | head -1)
    if [[ -z "$ip" ]]; then
        ip=$(ip -4 addr show | awk '/inet.*scope global/ {print $2}' | cut -d/ -f1 | head -1)
    fi
    if [[ -n "$ip" ]]; then
        echo "%{$fg[green]%}$ip%{$reset_color%}"
        return
    fi
    echo "%{$fg[red]%}No IP%{$reset_color%}"
}


# Function for Git
git_branch() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        echo "[%{$fg[blue]%}  $branch%{$reset_color%}]"
    fi
}


PROMPT='[%F{red}󰣇 %~%f] [%F{green}  $(get_ip_address)%f] $(git_branch)➤ '


# Alias
alias cls="clear"
alias cl="clear"
alias upd="sudo pacman -Syu"
alias updapp="sudo yay -Syu"
alias rmf="sudo rm -rf"
alias cln='sudo pacman -Rns $(pacman -Qdtq) && sudo pacman -Sc --noconfirm'
alias mk="mkdir "
alias exir="exit"
alias ins="sudo pacman -S "
alias l="eza --color=always --long --git --icons=always --tree --level=1 --no-time --no-user -all"
alias ll="eza --color=always --long --git --icons=always --tree --level=2 --no-time --no-user -all"
alias omz="omz update"
alias gt="git clone"
alias nr="sudo systemctl restart NetworkManager"
alias remove="sudo pacman -Rns "
alias ff="fastfetch"
alias cat="bat "


# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999999'
fi


# Go Config
export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin


# NVM Config
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# pnpm Config
export PNPM_HOME="/home/jain/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# Yazi Setup
export EDITOR="subl"
export VISUAL="$EDITOR"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -- "$tmp"
}


# fzf && fd Config
FD_EXCLUDES="--hidden --strip-cwd-prefix --exclude .git --exclude node_modules --exclude .idea"
export FZF_DEFAULT_COMMAND="fd $FD_EXCLUDES"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d $FD_EXCLUDES"

_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
        ssh)          fzf --preview 'dig {}'                   "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}


# Bat Theme
export BAT_THEME=Dracula
