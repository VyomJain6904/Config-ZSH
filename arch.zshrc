# -----------------------------
# Oh-My-Zsh Config
# -----------------------------
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


# -----------------------------
# Function for IP Address
# -----------------------------
get_ip_address() {
  local ip
  ip=$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7}' | head -1)
  if [[ -z "$ip" ]]; then
    ip=$(ip -4 addr show | awk '/inet.*scope global/ {print $2}' | cut -d/ -f1 | head -1)
  fi
  if [[ -n "$ip" ]]; then
    echo "%{$fg[green]%}$ip%{$reset_color%}"
  else
    echo "%{$fg[red]%}No IP%{$reset_color%}"
  fi
}


# -----------------------------
# Function for Git Branch
# -----------------------------
git_branch() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    echo "[%{$fg[blue]%}  $branch%{$reset_color%}]"
  fi
}


# -----------------------------
# Github Workflow with fzf
# -----------------------------
function gtg() {
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
      "${CYAN}  View Recent Commits${RESET}"
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
      *"View Recent Commits"*)
        echo -e "${BLUE}  Recent commits:${RESET}"
        git log --pretty=format:"%s" --reverse | nl -w2 -s'. '
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
# Prompt
# -----------------------------
PROMPT='[%F{red}󰣇 %c%f] [%F{green}  $(get_ip_address)%f] $(git_branch)➤ '


# -----------------------------
# Aliases
# -----------------------------
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
alias nr="sudo systemctl restart NetworkManager"
alias remove="sudo pacman -Rns "
alias ff="fastfetch"
alias cat="bat "
alias start="npm run dev"
alias code="code-insiders ."
alias gt="git clone"
alias gts="git status"
alias gtr="git remote set-url origin "
alias gta="git add ."
alias gtc="git commit -m "
alias gtp="git push -u origin main"


# -----------------------------
# Auto-suggestions
# -----------------------------
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999999'
fi


# -----------------------------
# Go Config
# -----------------------------
export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin


# -----------------------------
# NVM Config
# -----------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# -----------------------------
# pnpm Config
# -----------------------------
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# -----------------------------
# Yazi Setup
# -----------------------------
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


# -----------------------------
# fzf & fd Config
# -----------------------------
FD_EXCLUDES="--strip-cwd-prefix \
  --exclude .git \
  --exclude node_modules \
  --exclude .idea \
  --exclude .cargo \
  --exclude .bash \
  --exclude .cache \
  --exclude .var \
  --exclude .rustup \
  --exclude .dotnet \
  --exclude .claude \
  --exclude .icons \
  --exclude .gnupg"

export FZF_DEFAULT_COMMAND="fd --type=f $FD_EXCLUDES"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d $FD_EXCLUDES"

# Dracula fzf theme
export FZF_DEFAULT_OPTS="
  --ansi
  --height=40%
  --layout=reverse
  --border=rounded
  --prompt='❯ '
  --pointer='➤ '
  --marker='✓ '
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#bd93f9,marker:#ff5555,spinner:#ffb86c,header:#8be9fd
"

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
    FZF_DEFAULT_COMMAND="fd --type=f --hidden $FD_EXCLUDES" command fzf "${args[@]}"
  else
    command fzf "${args[@]}"
  fi
}

_fzf_compgen_path() { fd --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --exclude .git . "$1"; }

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1; shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


# -----------------------------
# Bat Theme
# -----------------------------
export BAT_THEME=Dracula
