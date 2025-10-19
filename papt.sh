#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
MAGENTA="\e[35m"
RESET="\e[0m"

PACMAN_FRAMES=("á—§ ")

BAR_WIDTH=50

LOG_FILE="/tmp/apt-wrapper.log"
ERR_FILE="/tmp/apt-wrapper.err"

cleanup() {
  tput cnorm 2>/dev/null
  rm -f "$LOG_FILE" "$ERR_FILE"
  printf "%b" "$RESET"
}
trap cleanup EXIT INT TERM

show_help() {
  printf "${GREEN}papt${RESET} - APT Wrapper\n\n"
  printf "${YELLOW}Usage:${RESET} sudo papt [options] command\n\n"
  printf "${CYAN}Most used commands :${RESET}\n"
  printf "  ${GREEN}list${RESET}         - list packages based on package names\n"
  printf "  ${GREEN}search${RESET}       - search in package descriptions (with fzf if available)\n"
  printf "  ${GREEN}show${RESET}         - show package details\n"
  printf "  ${GREEN}install${RESET}      - install packages\n"
  printf "  ${GREEN}reinstall${RESET}    - reinstall packages\n"
  printf "  ${GREEN}remove${RESET}       - remove packages\n"
  printf "  ${GREEN}autoremove${RESET}   - automatically remove all unused packages\n"
  printf "  ${GREEN}update${RESET}       - update list of available packages\n"
  printf "  ${GREEN}upgrade${RESET}      - upgrade the system by installing/upgrading packages\n"
  printf "  ${GREEN}full-upgrade${RESET} - upgrade the system by removing/installing/upgrading packages\n"
  printf "  ${GREEN}dist-upgrade${RESET} - alias for full-upgrade\n"
  printf "  ${GREEN}purge${RESET}        - remove packages and their configuration files\n\n"
  printf "${CYAN}Interactive commands :${RESET}\n"
  printf "  ${GREEN}finstall${RESET}  - search and install packages interactively\n"
  printf "  ${GREEN}fremove${RESET}   - search and remove packages interactively\n"
  printf "  ${GREEN}fshow${RESET}     - search and show package details interactively\n\n"
  printf "${CYAN}Additional commands :${RESET}\n"
  printf "  ${GREEN}edit-sources${RESET} - edit the source information file\n"
  printf "  ${GREEN}satisfy${RESET}      - satisfy dependency strings\n\n"
  printf "${YELLOW}Options :${RESET}\n"
  printf "  ${GREEN}-h, --help${RESET}   - show this help message\n"
  printf "  ${GREEN}-v, --version${RESET} - show version information\n"
}

show_version() {
  printf "%bpapt%b version 1.0.0\n" "$GREEN" "$RESET"
  printf "APT Wrapper - A Modern APT package manager\n"
  printf "\nBased on APT:\n"
  apt --version
}

get_color_for_command() {
  local cmd="$1"
  case "$cmd" in
    install|reinstall)
      echo "$GREEN"
      ;;
    update)
      echo "$CYAN"
      ;;
    upgrade|dist-upgrade|full-upgrade)
      echo "$YELLOW"
      ;;
    remove|purge|autoremove)
      echo "$RED"
      ;;
    *)
      echo "$GREEN"
      ;;
  esac
}

needs_progress_bar() {
  local cmd="$1"
  case "$cmd" in
    install|reinstall|remove|purge|autoremove|update|upgrade|dist-upgrade|full-upgrade)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

draw_pacman_bar() {
  local percent=$1
  local frame_index=$2
  local color=$3

  printf "\r\033[K"

  local pacman_pos=$((percent * (BAR_WIDTH - 1) / 100))
  ((pacman_pos < 0)) && pacman_pos=0
  ((pacman_pos >= BAR_WIDTH)) && pacman_pos=$((BAR_WIDTH - 1))

  printf "%b[" "$color"

  local i
  for ((i=0; i<pacman_pos; i++)); do
    printf "-"
  done

  printf "%s" "${PACMAN_FRAMES[frame_index]}"

  local dots_start=$((pacman_pos + 1))
  for ((i=dots_start; i<BAR_WIDTH; i++)); do
    if ((i % 2 == 0)); then
      printf "o"
    else
      printf " "
    fi
  done

  printf "] %3d%%%b" "$percent" "$RESET"
}

draw_completed_bar() {
  local color=$1

  printf "\r\033[K"
  printf "%b[" "$color"

  for ((i=0; i<BAR_WIDTH-1; i++)); do
    printf "-"
  done

  printf "á—§ ] 100%%%b" "$RESET"
  printf "\n"
}

animate_progress() {
  local pid=$1
  local color=$2
  local progress=0
  local frame_index=0
  local speed=0.1

  tput civis 2>/dev/null

  while kill -0 "$pid" 2>/dev/null; do
    draw_pacman_bar "$progress" "$frame_index" "$color"
    sleep "$speed"

    ((progress += 2))
    if ((progress > 100)); then
      progress=0
    fi

    ((frame_index = (frame_index + 1) % ${#PACMAN_FRAMES[@]}))
  done

  draw_completed_bar "$color"
  tput cnorm 2>/dev/null
}

fzf_search_packages() {
  local action="$1"

  if ! command -v fzf &> /dev/null; then
    printf "%bfzf is not installed. Install it first: sudo apt install fzf%b\n" "$RED" "$RESET"
    exit 1
  fi

  case "$action" in
    install)
      local selected=$(apt-cache search . | \
        awk '{print $1}' | \
        command fzf --prompt='ðŸ“¦ Install â¯ ' \
            --header='â†µ Install | ESC Cancel | Type to search' \
            --preview='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null' \
            --preview-window='right:65%:wrap' \
            --color='prompt:#50fa7b,pointer:#50fa7b,marker:#50fa7b')

      if [[ -n "$selected" ]]; then
        printf "\n%bInstalling: %s%b\n" "$GREEN" "$selected" "$RESET"
        PACKAGE_NAME="$selected"
        APT_COMMAND="install"
        BAR_COLOR="$GREEN"

        apt -y install "$selected" > "$LOG_FILE" 2> "$ERR_FILE" &
        apt_pid=$!
        animate_progress "$apt_pid" "$BAR_COLOR"
        wait "$apt_pid"
        status=$?

        if [[ $status -eq 0 ]]; then
          printf "%bðŸ“¦ Package '%s' installed successfully%b\n" "$GREEN" "$selected" "$RESET"
        else
          printf "%bðŸ“¦ Failed to install '%s'%b\n" "$RED" "$selected" "$RESET"
        fi
        exit $status
      else
        printf "%bðŸ“¦ No package selected%b\n" "$YELLOW" "$RESET"
        exit 0
      fi
      ;;

    remove)
      local selected=$(dpkg -l | \
        awk '/^ii/ {print $2}' | \
        command fzf --prompt='ðŸ“¦ Remove â¯ ' \
            --header='â†µ Remove | ESC Cancel | Type to search' \
            --preview='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null' \
            --preview-window='right:65%:wrap' \
            --color='prompt:#ff5555,pointer:#ff5555,marker:#ff5555,bg+:red,hl+:white,info:cyan')

      if [[ -n "$selected" ]]; then
        printf "\n%bRemoving: %s%b\n" "$RED" "$selected" "$RESET"
        PACKAGE_NAME="$selected"
        APT_COMMAND="remove"
        BAR_COLOR="$RED"

        apt -y remove "$selected" > "$LOG_FILE" 2> "$ERR_FILE" &
        apt_pid=$!
        animate_progress "$apt_pid" "$BAR_COLOR"
        wait "$apt_pid"
        status=$?

        if [[ $status -eq 0 ]]; then
          printf "%bðŸ“¦ Package '%s' removed successfully%b\n" "$GREEN" "$selected" "$RESET"
        else
          printf "%bðŸ“¦ Failed to remove '%s'%b\n" "$RED" "$selected" "$RESET"
        fi
        exit $status
      else
        printf "%bðŸ“¦ No package selected%b\n" "$YELLOW" "$RESET"
        exit 0
      fi
      ;;

    show)
      local selected=$(apt-cache search . | \
        awk '{print $1}' | \
        command fzf --prompt='ðŸ“¦ View â¯ ' \
            --header='â†µ View Details | ESC Cancel | Type to search' \
            --preview='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null' \
            --preview-window='right:65%:wrap' \
            --color='prompt:#8be9fd,pointer:#8be9fd,marker:#8be9fd')

      if [[ -n "$selected" ]]; then
        printf "\n%bPackage Details:%b\n" "$CYAN" "$RESET"
        apt-cache show "$selected"
        exit 0
      else
        printf "%bâœ— No package selected%b\n" "$YELLOW" "$RESET"
        exit 0
      fi
      ;;
  esac
}

check_package_status() {
  local cmd="$1"
  local pkg="$2"

  case "$cmd" in
    install|reinstall)
      if [[ "$cmd" == "install" ]] && dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        printf "%bâš  Package '%s' is already installed%b\n" "$YELLOW" "$pkg" "$RESET"
        return 1
      fi
      ;;
    remove|purge)
      if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        printf "%bâš  Package '%s' is not installed%b\n" "$YELLOW" "$pkg" "$RESET"
        return 1
      fi
      ;;
  esac
  return 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if [[ "$1" == "-v" || "$1" == "--version" ]]; then
  show_version
  exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
  printf "%b%s%b\n" "$RED" "Error: Run with sudo privilege" "$RESET"
  exit 1
fi

if [[ $# -lt 1 ]]; then
  printf "%b%s%b %s\n" "$YELLOW" "Usage:" "$RESET" "sudo papt [options] command"
  printf "Try 'papt --help' for more information.\n"
  exit 1
fi

APT_COMMAND="$1"
BAR_COLOR=$(get_color_for_command "$APT_COMMAND")

case "$APT_COMMAND" in
  finstall)
    fzf_search_packages "install"
    ;;
  fremove)
    fzf_search_packages "remove"
    ;;
  fshow)
    fzf_search_packages "show"
    ;;
  search)
    if [[ $# -eq 1 ]] && command -v fzf &> /dev/null; then
      printf "%bUse interactive search? (y/n): %b" "$CYAN" "$RESET"
      read -r response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        fzf_search_packages "show"
      else
        apt search
      fi
      exit $?
    else
      apt "$@"
      exit $?
    fi
    ;;
  list)
    if command -v fzf &> /dev/null && [[ $# -eq 1 ]]; then
      printf "%bSelect list option:%b\n" "$CYAN" "$RESET"
      choice=$(printf "All packages\nInstalled packages\nUpgradable packages\nManual packages" | \
        command fzf --prompt='ðŸ“¦ List â¯ ' \
            --header='â†µ Select | ESC Cancel' \
            --color='prompt:#50fa7b,pointer:#50fa7b,marker:#50fa7b')

      case "$choice" in
        "All packages")
          apt list 2>/dev/null | command fzf --prompt='ðŸ“¦ All Packages â¯ ' \
              --preview='apt-cache show {1} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {1} 2>/dev/null' \
              --preview-window='right:65%:wrap'
          ;;
        "Installed packages")
          apt list --installed 2>/dev/null | command fzf --prompt='ðŸ“¦ Installed â¯ ' \
              --preview='apt-cache show {1} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {1} 2>/dev/null' \
              --preview-window='right:65%:wrap'
          ;;
        "Upgradable packages")
          apt list --upgradable 2>/dev/null | command fzf --prompt='ðŸ“¦ Upgradable â¯ ' \
              --preview='apt-cache show {1} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {1} 2>/dev/null' \
              --preview-window='right:65%:wrap' \
              --color='prompt:#ffb86c,pointer:#ffb86c,marker:#ffb86c'
          ;;
        "Manual packages")
          apt list --manual-installed 2>/dev/null | command fzf --prompt='ðŸ“¦ Manual â¯ ' \
              --preview='apt-cache show {1} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {1} 2>/dev/null' \
              --preview-window='right:65%:wrap'
          ;;
        *)
          printf "%bâœ— No option selected%b\n" "$YELLOW" "$RESET"
          ;;
      esac
      exit $?
    else
      apt "$@"
      exit $?
    fi
    ;;
  show)
    if [[ $# -eq 1 ]] && command -v fzf &> /dev/null; then
      fzf_search_packages "show"
    else
      apt "$@"
      exit $?
    fi
    ;;
esac

if [[ "$APT_COMMAND" == "install" || "$APT_COMMAND" == "reinstall" || "$APT_COMMAND" == "remove" || "$APT_COMMAND" == "purge" ]]; then
  if [[ $# -lt 2 ]]; then
    printf "%b%s%b\n" "$RED" "Error: Package name required" "$RESET"
    exit 1
  fi
  PACKAGE_NAME="$2"
  if ! check_package_status "$APT_COMMAND" "$PACKAGE_NAME"; then
    exit 0
  fi
fi

if ! needs_progress_bar "$APT_COMMAND"; then
  apt "$@"
  exit $?
fi

apt -y "$@" > "$LOG_FILE" 2> "$ERR_FILE" &
apt_pid=$!

animate_progress "$apt_pid" "$BAR_COLOR"

wait "$apt_pid"
status=$?

if [[ $status -eq 0 ]]; then
  printf "%bâœ“ Done!%b\n" "$GREEN" "$RESET"

  case "$APT_COMMAND" in
    update)
      upgradable=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
      if [[ $upgradable -gt 0 ]]; then
        printf "%bðŸ“¦ %d package(s) can be upgraded%b\n" "$CYAN" "$upgradable" "$RESET"
        printf "%bRun 'sudo papt upgrade' to upgrade them%b\n" "$CYAN" "$RESET"
      else
        printf "%bðŸ“¦ All packages are up to date%b\n" "$GREEN" "$RESET"
      fi
      ;;
    upgrade|dist-upgrade|full-upgrade)
      printf "%bðŸ“¦ System upgraded successfully%b\n" "$GREEN" "$RESET"
      ;;
    install|reinstall)
      if [[ -n "$PACKAGE_NAME" ]]; then
        printf "%bðŸ“¦ Package '%s' installed successfully%b\n" "$GREEN" "$PACKAGE_NAME" "$RESET"
      fi
      ;;
    remove|purge)
      if [[ -n "$PACKAGE_NAME" ]]; then
        printf "%bðŸ“¦ Package '%s' removed successfully%b\n" "$GREEN" "$PACKAGE_NAME" "$RESET"
      fi
      ;;
    autoremove)
      printf "%bðŸ“¦ Unused packages removed successfully%b\n" "$GREEN" "$RESET"
      ;;
  esac
else
  printf "%bâœ— Failed!%b\n" "$RED" "$RESET"
fi

exit $status
