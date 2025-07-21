export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="apple"
eval "$(starship init zsh)"
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

PROMPT='[%F{blue}󰣇 %~%f] [%F{green}  $(get_ip_address)%f] ➜ '

get_ip_address() {
  local ip

  # Get IP from the default route interface (most reliable method)
  ip=$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7}' | head -1)

  # If that fails, try to get IP from any active interface (excluding loopback)
  if [[ -z "$ip" ]]; then
    ip=$(ip -4 addr show | awk '/inet.*scope global/ {print $2}' | cut -d/ -f1 | head -1)
  fi

  # If we found an IP, display it in green
  if [[ -n "$ip" ]]; then
    echo "%{$fg[green]%}$ip%{$reset_color%}"
    return
  fi

  # If no IP found, display "No IP" in red
  echo "%{$fg[red]%}No IP%{$reset_color%}"
}

alias cls="clear"
alias cl="clear"
alias upd="sudo pacman -Syu"
alias rmf="sudo rm -rf"
alias cln='sudo pacman -Rns $(pacman -Qdtq) && sudo pacman -Sc --noconfirm'
alias mk="mkdir "
alias exir="exit"
alias ins="pacman -S "
alias ll="ls -lart"
alias omz="omz update"
alias gt="git clone"
alias nr="systemctl restart NetworkManager"
alias msf="msfconsole"
alias remove="pacman -Rns "

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi
export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  
