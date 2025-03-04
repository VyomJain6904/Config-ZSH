export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="apple"

plugins=(
  ssh
	git
	sublime
	fzf
	zsh-autosuggestions 
	zsh-syntax-highlighting
	zsh-completions 
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

PROMPT='[%F{red} %~%f] [%F{green}  $(get_ip_address)%f] ➜ '

get_ip_address() {
  if [[ -n "$(ifconfig wlan0 2>/dev/null)" ]]; then
    echo "%{$fg[green]%}$(ifconfig wlan0 | awk '/inet / {print $2}')%{$reset_color%}"
  elif [[ -n "$(ifconfig wlan0 2>/dev/null)" ]]; then
    echo "%{$fg[green]%}$(ifconfig wlan0 | awk '/inet / {print $2}')%{$reset_color%}"
  else
    echo "%{$fg[red]%}No IP%{$reset_color%}"
  fi
}

alias cls="clear"
alias cl="clear"
alias su="su - root"
alias upd="sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y"
alias rmf="sudo rm -rf"
alias cln="sudo apt autoremove -y && sudo apt autoclean -y"
alias mk="mkdir "
alias exir="exit"
alias ins="sudo apt install -y "
alias ll="ls -lart"
alias omz="omz update"
alias gt="git clone"
alias nr="sudo systemctl restart NetworkManager"
alias msf="msfconsole"

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
