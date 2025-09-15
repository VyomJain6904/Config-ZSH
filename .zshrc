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
source ~/.oh-my-zsh/plugins/zsh-defer/zsh-defer.plugin.zsh
zsh-defer source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
zsh-defer source /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh


get_ip_address() {
    if [[ -n "$(ifconfig eth0 2>/dev/null)" ]]; then
        echo "%{$fg[green]%}$(ifconfig eth0 | awk '/inet / {print $2}')%{$reset_color%}"
        elif [[ -n "$(ifconfig eth0 2>/dev/null)" ]]; then
        echo "%{$fg[green]%}$(ifconfig eth0 | awk '/inet / {print $2}')%{$reset_color%}"
    else
        echo "%{$fg[red]%}No IP%{$reset_color%}"
    fi
}

git_branch() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        echo "[%{$fg[blue]%}  $branch%{$reset_color%}]"
    fi
}

PROMPT='[%F{red} %c%f] [%F{green} $(get_ip_address)%f] ➤ '

# ------
# Alias
# ------

# System
alias cls="clear"
alias cl="clear"
alias su="su - root"
alias upd="sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y"
alias updk="sudo apt install linux-headers-$(uname -r)"
alias rmf="sudo rm -rf"
alias cln="sudo apt autoremove -y && sudo apt autoclean -y"
alias cltmp="cd /tmp && rmf *"
alias mk="mkdir"
alias exir="exit"
alias ins="sudo apt install -y "
alias remove="sudo apt remove --purge -y "
alias omz="omz update"
alias nr="sudo systemctl restart NetworkManager"

# Files
alias l="eza --color=always --long --git --icons=always --tree --level=1 --no-time --no-user --all"
alias ll="eza --color=always --long --git --icons=always --tree --level=2 --no-time --no-user --all"
alias gt="git clone"
alias msf="msfconsole"
alias bat="batcat"
alias thm="cd /home/kali/Downloads && sudo openvpn VyomJain.ovpn"
alias fd="fdfind"
alias f="fzf"
alias ff="fastfetch"

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -----------
# Yazi Setup
# -----------
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

# ----------------------
# Github Workflow & fzf
# ----------------------
function gt() {
    # Colors
    local RED=$'\033[1;31m'
    local GREEN=$'\033[1;32m'
    local YELLOW=$'\033[1;33m'
    local BLUE=$'\033[1;34m'
    local CYAN=$'\033[1;36m'
    local MAGENTA=$'\033[1;35m'
    local RESET=$'\033[0m'

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "  ${RED}  Not in a Git repository!${RESET}"
        return 1
    fi

    local exit_requested=false

    while [[ "$exit_requested" == false ]]; do
        local options=(
            "${BLUE}  Git Status${RESET}"
            "${YELLOW}  Git Add${RESET}"
            "${GREEN}  Git Commit${RESET}"
            "${MAGENTA}  Git Push${RESET}"
            "${CYAN}  Recent Commits${RESET}"
            "${RED}󰩈  Exit${RESET}"
        )

        local choice=$(printf "%s\n" "${options[@]}" \
            | command fzf \
            --ansi \
            --prompt=" ${CYAN}Git › ${RESET}" \
            --header="${MAGENTA}Repository: $(basename "$(git rev-parse --show-toplevel 2>/dev/null)")${RESET}" \
            --border=rounded \
            --height=40% \
            --reverse \
            --cycle \
        --bind='ctrl-c:abort,esc:abort')

        if [[ $? -ne 0 ]] || [[ -z "$choice" ]]; then
            echo -e "\n  ${YELLOW}󰩈  Exited.${RESET}"
            break
        fi

        case $choice in
            *"Git Status"*)
                echo -e "${BLUE}  Repository Status:${RESET}"
                git status
            ;;
            *"Git Add"*)
                git add .
                echo -e "  ${GREEN}  Files staged.${RESET}"
            ;;
            *"Git Commit"*)
                if git diff --cached --quiet 2>/dev/null; then
                    echo -e "  ${YELLOW}  No staged changes.${RESET}"
                else
                    echo -ne "${CYAN}  Commit message:${RESET} "
                    read msg
                    if [[ -n "$msg" ]]; then
                        git commit -m "$msg"
                        echo -e "  ${GREEN}  Commit created.${RESET}"
                    else
                        echo -e "  ${RED}  Commit message cannot be empty.${RESET}"
                    fi
                fi
            ;;
            *"Git Push"*)
                local current_branch=$(git branch --show-current 2>/dev/null)
                echo -e "${BLUE}  Pushing branch: ${MAGENTA}${current_branch}${RESET}"
                if git push 2>/dev/null; then
                    echo -e "  ${GREEN}  Push successful.${RESET}"
                else
                    git push -u origin "$current_branch"
                    [[ $? -eq 0 ]] && echo -e "  ${GREEN}  Push successful.${RESET}" \
                    || echo -e "  ${RED}  Push failed.${RESET}"
                fi
            ;;
            *"Recent Commits"*)
                echo -e "${BLUE}  Last 5 commits (ascending):${RESET}"
                total=$(git rev-list --count HEAD)
                start=$((total-4))
                git log -n 5 --pretty=format:"%s" --reverse \
                | awk -v start="$start" '{print start++ ". " $0}'
            ;;
            *"Exit"*)
                echo -e "  ${GREEN}󰩈  Exiting Git Workflow.${RESET}"
                exit_requested=true
            ;;
        esac

        if [[ "$exit_requested" == false ]]; then
            echo ""
            echo -e "${CYAN}⏎ Press Enter to continue...${RESET}"
            read
            clear
        fi
    done
}

# -----------------------------
# fzf & fdfind Config
# -----------------------------

FD_EXCLUDES=(
    --strip-cwd-prefix
    --exclude .git
    --exclude node_modules
    --exclude .idea
    --exclude .cargo
    --exclude .bash
    --exclude .cache
    --exclude .var
    --exclude .rustup
    --exclude .dotnet
    --exclude .claude
    --exclude .icons
    --exclude .gnupg
)

# Default fzf commands using fdfind
export FZF_DEFAULT_COMMAND="fdfind --type f ${FD_EXCLUDES[*]}"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type d ${FD_EXCLUDES[*]}"

# Dracula theme
export FZF_DEFAULT_OPTS="--ansi \
--height=50% \
--layout=reverse \
--cycle \
--border=rounded \
--prompt='❯ ' \
--pointer='➤ ' \
--marker='✓ ' \
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
--color=info:#ffb86c,prompt:#50fa7b,pointer:#bd93f9,marker:#ff5555,spinner:#ffb86c,header:#8be9fd"

# Custom wrapper for fzf (-l flag = include hidden files)
fzf() {
    local show_hidden=false
    local args=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l) show_hidden=true; shift ;;
            *) args+=("$1"); shift ;;
        esac
    done

    if [[ "$show_hidden" == true ]]; then
        FZF_DEFAULT_COMMAND="fdfind --type f --hidden --cycle ${FD_EXCLUDES[*]}" command fzf "${args[@]}"
    else
        command fzf "${args[@]}"
    fi
}

# Completion (use fdfind instead of fd)
_fzf_compgen_path() { fdfind --exclude .git . "$1"; }
_fzf_compgen_dir()  { fdfind --type d --exclude .git . "$1"; }

# Preview config
show_file_or_dir_preview='if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
export FZF_CTRL_T_OPTS="--preview \"$show_file_or_dir_preview\""
export FZF_ALT_C_OPTS="--preview \"eza --tree --color=always {} | head -200\""

# Custom preview for completions
_fzf_comprun() {
    local command=$1; shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo ${}'" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}


# ----------
# Bat Theme
# ----------
export BAT_THEME=Dracula


test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
