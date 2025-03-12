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
alias thm="cd /home/jain/thm && sudo openvpn VyomJain.ovpn"
alias htb="sudo openvpn academy-regular.ovpn"
alias pwn="sudo openvpn VyomOp.ovpn"
alias mk="mkdir "
alias exir="exit"
alias ins="sudo apt install -y "
alias ll="ls -lart"
alias omz="omz update"
alias gt="git clone"
alias nr="sudo systemctl restart NetworkManager"
alias msf="msfconsole"
alias mobsf="cd /home/jain/Android && sudo docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest"
alias dvwa="cd /home/jain/QHA/Metasploitable2-Linux && sudo docker run --rm -it -p 80:80 vulnerables/web-dvwa"
alias remove="sudo apt remove --purge -y "

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
