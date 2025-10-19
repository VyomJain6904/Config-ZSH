#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
MAGENTA="\e[35m"
RESET="\e[0m"

PACMAN_FRAMES=("ᗧ ")
BAR_WIDTH=50

LOG_FILE="/tmp/apt-wrapper.log"
ERR_FILE="/tmp/apt-wrapper.err"
HISTORY_FILE="/var/log/papt-history.log"
HISTORY_DIR="/var/log/papt-snapshots"

cleanup() {
  tput cnorm 2>/dev/null
  rm -f "$LOG_FILE" "$ERR_FILE"
  printf "%b" "$RESET"
}
trap cleanup EXIT INT TERM

init_history() {
  if [[ ! -w /var/log ]]; then
    printf "%bWarning: No write permission for /var/log. Running without history and snapshots.%b\n" "$RED" "$RESET" >&2
    return 1
  fi

  if [[ ! -f "$HISTORY_FILE" ]]; then
    touch "$HISTORY_FILE" 2>/dev/null || {
      printf "%bWarning: Cannot create history file. Running without history.%b\n" "$YELLOW" "$RESET" >&2
      return 1
    }
  fi

  if [[ ! -d "$HISTORY_DIR" ]]; then
    mkdir -p "$HISTORY_DIR" 2>/dev/null || {
      printf "%bWarning: Cannot create snapshot directory. Rollback disabled.%b\n" "$YELLOW" "$RESET" >&2
      return 1
    }
  fi
  return 0
}

log_operation() {
  local operation="$1"
  local packages="$2"
  local status="$3"
  local timestamp=$(date '+%d-%m-%Y %I:%M:%S %p')

  if [[ -w "$HISTORY_FILE" ]]; then
    local safe_packages=$(echo "$packages" | sed 's/|/PIPE_REPLACEMENT/g')
    echo "$timestamp | $operation | $safe_packages | $status" >> "$HISTORY_FILE"
  fi
}

create_snapshot() {
  local snapshot_id=$(date '+%Y%m%d_%H%M%S')
  local snapshot_file="$HISTORY_DIR/snapshot_$snapshot_id.txt"

  if [[ -w "$HISTORY_DIR" ]]; then
    dpkg --get-selections > "$snapshot_file" 2>/dev/null
    echo "$snapshot_file"
  else
    echo ""
  fi
}

show_help() {
    printf "${GREEN}papt${RESET} - APT Wrapper (Made by VyomJain)\n\n"
    printf "${YELLOW}Usage:${RESET} sudo papt [options] command\n\n"
    printf "${CYAN}Most used commands :${RESET}\n"
    printf "    ${GREEN}list${RESET}                  - list packages based on package names\n"
    printf "    ${GREEN}finstall${RESET}              - search and install packages interactively\n"
    printf "    ${GREEN}fremove${RESET}               - search and remove packages interactively\n"
    printf "    ${GREEN}fshow${RESET}                 - search and show package details interactively\n"
    printf "    ${GREEN}full-upgrade${RESET}          - Full upgrade the system\n\n"
    printf "${CYAN}History :${RESET}\n"
    printf "    ${GREEN}history${RESET}               - show operation history\n"
    printf "    ${GREEN}rollback${RESET}              - rollback to previous snapshot\n"
    printf "    ${GREEN}snapshots${RESET}             - list all available snapshots\n\n"
    printf "${CYAN}Advanced Search :${RESET}\n"
    printf "    ${GREEN}fsearch${RESET}               - filtered search\n"
    printf "    ${GREEN}search --installed${RESET}    - search only installed packages\n"
    printf "    ${GREEN}search --size <size>${RESET}  - filter by size (e.g., <10MB, >5MB)\n\n"
    printf "${CYAN}Package Analysis :${RESET}\n"
    printf "    ${GREEN}compare${RESET} <pkg1> <pkg2> - compare two packages\n"
    printf "    ${GREEN}verify${RESET} <package>      - verify package integrity\n"
    printf "    ${GREEN}github${RESET} <url>          - install from GitHub repository URL\n\n"
    printf "${YELLOW}Options :${RESET}\n"
    printf "    ${GREEN}-h, --help${RESET}            - show this help message\n"
    printf "    ${GREEN}-v, --version${RESET}         - show version information\n\n"
}

show_version() {
    printf "%bpapt%b version 2.0.0\n" "$GREEN" "$RESET"
    printf "APT Wrapper - A Modern APT package manager (Made by VyomJain)\n"
    printf "\nBased on APT:\n"
    apt --version
}

get_color_for_command() {
  local cmd="$1"
  case "$cmd" in
    install|reinstall|finstall)
      echo "$GREEN"
      ;;
    update)
      echo "$CYAN"
      ;;
    upgrade|dist-upgrade|full-upgrade)
      echo "$YELLOW"
      ;;
    remove|purge|autoremove|fremove)
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
    install|reinstall|remove|purge|autoremove|update|upgrade|dist-upgrade|full-upgrade|finstall|fremove)
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
    printf "="
  done

  printf "✓] 100%%%b" "$RESET"
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

show_history() {
  if [[ ! -f "$HISTORY_FILE" ]]; then
    printf "%bNo history file found: %s%b\n" "$RED" "$HISTORY_FILE" "$RESET"
    return 1
  fi

  if [[ ! -s "$HISTORY_FILE" ]]; then
    printf "%bHistory is empty%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  printf "%b%3s | %-20s | %-12s | %-40s | %-7s%b\n" "$YELLOW" "No." "Timestamp" "Operation" "Packages" "Status" "$RESET"
  printf "%b%s%b\n" "$BLUE" "$(printf '%.0s─' {1..91})" "$RESET"


  local line_num=1
  tac "$HISTORY_FILE" | while IFS='|' read -r timestamp operation packages status; do
    timestamp=$(echo "$timestamp" | xargs)
    operation=$(echo "$operation" | xargs)
    packages=$(echo "$packages" | sed 's/PIPE_REPLACEMENT/, /g' | xargs)
    status=$(echo "$status" | xargs)

    local status_color="$GREEN"
    local status_symbol="✓"
    if [[ "$status" == "FAILED" ]]; then
      status_color="$RED"
      status_symbol="✗"
    fi

    local display_packages=$(printf '%.37s' "$packages")
    if [[ ${#packages} -gt 37 ]]; then
      display_packages+="..."
    fi

    printf "%b%3d%b | %b%-20s%b | %b%-12s%b | %-40s | %b%s %-5s%b\n" \
      "$BLUE" "$line_num" "$RESET" \
      "$CYAN" "$timestamp" "$RESET" \
      "$YELLOW" "$operation" "$RESET" \
      "$display_packages" \
      "$status_color" "$status_symbol" "$status" "$RESET"

    ((line_num++))
    if ((line_num > 50)); then
        printf "%b... Only showing the last 50 operations. Check %s for full history.%b\n" "$YELLOW" "$HISTORY_FILE" "$RESET"
        break
    fi
  done
}

rollback_snapshot() {
  if [[ ! -d "$HISTORY_DIR" ]]; then
    printf "%bNo snapshots directory found: %s%b\n" "$RED" "$HISTORY_DIR" "$RESET"
    return 1
  fi

  local snapshots=($(ls -t "$HISTORY_DIR"/snapshot_*.txt 2>/dev/null))

  if [[ ${#snapshots[@]} -eq 0 ]]; then
    printf "%bNo snapshots found%b\n" "$YELLOW" "$RESET"
    return 1
  fi

  printf "%bAvailable snapshots (most recent first):%b\n" "$CYAN" "$RESET"
  local i=1
  for snapshot in "${snapshots[@]}"; do
    local snap_date=$(basename "$snapshot" | sed 's/snapshot_//;s/.txt//;s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
    printf "  %b%3d.%b %s\n" "$GREEN" "$i" "$RESET" "$snap_date"
    ((i++))
  done

  printf "\n%bEnter snapshot number to rollback (or 0 to cancel): %b" "$YELLOW" "$RESET"
  read -r choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    printf "%bInvalid input: Not a number.%b\n" "$RED" "$RESET"
    return 1
  fi

  if [[ "$choice" -eq 0 ]]; then
    printf "%bRollback cancelled%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  if [[ "$choice" -lt 1 || "$choice" -gt ${#snapshots[@]} ]]; then
    printf "%bInvalid snapshot number%b\n" "$RED" "$RESET"
    return 1
  fi

  local selected_snapshot="${snapshots[$((choice - 1))]}"
  local snap_id=$(basename "$selected_snapshot" | sed 's/snapshot_//;s/.txt//')

  printf "\n%b!!! WARNING: Rollback to snapshot %s will attempt to match your package selection !!!%b\n" "$RED" "$snap_id" "$RESET"
  printf "%bContinue? (type 'YES' to confirm): %b" "$YELLOW" "$RESET"
  read -r confirm

  if [[ "$confirm" != "YES" ]]; then
    printf "%bRollback cancelled%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  printf "\n%bRolling back system package selection...%b\n" "$CYAN" "$RESET"

  dpkg --set-selections < "$selected_snapshot" 2>/dev/null

  printf "%bStarting dselect-upgrade to apply changes...%b\n" "$MAGENTA" "$RESET"
  apt-get dselect-upgrade -y > "$LOG_FILE" 2> "$ERR_FILE" &
  local pid=$!
  animate_progress "$pid" "$MAGENTA"
  wait "$pid"
  local apt_status=$?

  if [[ "$apt_status" -eq 0 ]]; then
    printf "%b✓ Rollback completed successfully%b\n" "$GREEN" "$RESET"
    log_operation "ROLLBACK" "$snap_id" "SUCCESS"
  else
    printf "%b✗ Rollback failed. Check %s and %s for details.%b\n" "$RED" "$LOG_FILE" "$ERR_FILE" "$RESET"
    log_operation "ROLLBACK" "$snap_id" "FAILED"
    return 1
  fi
}

list_snapshots() {
  if [[ ! -d "$HISTORY_DIR" ]]; then
    printf "%bNo snapshots directory found: %s%b\n" "$RED" "$HISTORY_DIR" "$RESET"
    return 1
  fi

  local snapshots=($(ls -t "$HISTORY_DIR"/snapshot_*.txt 2>/dev/null))

  if [[ ${#snapshots[@]} -eq 0 ]]; then
    printf "%bNo snapshots available%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  printf "%b%3s | %-20s | %-10s | %s%b\n" "$YELLOW" "No." "Date and Time" "Size" "Packages" "$RESET"
  printf "%b%s%b\n" "$BLUE" "$(printf '%.0s─' {60})" "$RESET"

  local i=1
  for snapshot in "${snapshots[@]}"; do
    local snap_date=$(basename "$snapshot" | sed 's/snapshot_//;s/.txt//;s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
    local snap_size=$(du -h "$snapshot" 2>/dev/null | awk '{print $1}')
    local pkg_count=$(wc -l < "$snapshot" 2>/dev/null)

    printf "%b%3d%b | %b%-20s%b | %b%-10s%b | %b%s%b\n" \
      "$GREEN" "$i" "$RESET" \
      "$CYAN" "$snap_date" "$RESET" \
      "$YELLOW" "${snap_size:-N/A}" "$RESET" \
      "$BLUE" "${pkg_count:-N/A}" "$RESET"
    ((i++))
  done

  printf "\n%bTotal snapshots: %d%b\n" "$CYAN" "$((i - 1))" "$RESET"
}

convert_to_kb() {
    local size_str="$1"
    local num
    local unit

    if [[ "$size_str" =~ ^([0-9]+)([kKmM]?B?)$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
    else
        echo "-1"
        return 1
    fi

    case "${unit^^}" in
        "KB"|"K")
            echo "$num"
            ;;
        "MB"|"M")
            echo $((num * 1024))
            ;;
        "GB"|"G")
            echo $((num * 1024 * 1024))
            ;;
        *)
            echo "$num"
            ;;
    esac
}

filtered_search() {
  if ! command -v fzf &> /dev/null; then
    printf "%bfzf is not installed. Install it first: sudo papt install fzf%b\n" "$RED" "$RESET"
    return 1
  fi

  if ! command -v batcat &> /dev/null && ! command -v cat &> /dev/null; then
      printf "%bError: Neither 'batcat' (for preview) nor 'cat' is available.%b\n" "$RED" "$RESET"
      return 1
  fi
  local preview_cmd='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null'

  local filter_options=("All Packages" "Installed Only" "Not Installed" "By Size (<1MB)" "By Size (1-10MB)" "By Size (>10MB)")

  local filter_choice=$(printf "%s\n" "${filter_options[@]}" | \
    command fzf --prompt='🔍 Select Filter ❯ ' \
        --header='↵ Select Filter | ESC Cancel' \
        --cycle \
        --border='rounded' \
        --pointer='➤ ' \
        --color='fg:#f8f8f2,bg:#282a36,hl:#bd93f9' \
        --color='fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9' \
        --color='info:#ffb86c,prompt:#50fa7b,pointer:#bd93f9,marker:#ff5555')

  if [[ -z "$filter_choice" ]]; then
    printf "%bNo filter selected%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  local package_list=""

  case "$filter_choice" in
    "All Packages")
      package_list=$(apt-cache pkgnames)
      ;;
    "Installed Only")
      package_list=$(dpkg -l | awk '/^ii/ {print $2}')
      ;;
    "Not Installed")
      package_list=$(comm -23 <(apt-cache pkgnames | sort) <(dpkg -l | awk '/^ii/ {print $2}' | sort))
      ;;
    "By Size (<1MB)")
      package_list=$(apt-cache pkgnames | while read pkg; do
        size=$(apt-cache show "$pkg" 2>/dev/null | grep "^Installed-Size:" | awk '{print $2}')
        if [[ -n "$size" ]] && (( size < 1024 )); then
          echo "$pkg"
        fi
      done)
      ;;
    "By Size (1-10MB)")
      package_list=$(apt-cache pkgnames | while read pkg; do
        size=$(apt-cache show "$pkg" 2>/dev/null | grep "^Installed-Size:" | awk '{print $2}')
        if [[ -n "$size" ]] && (( size >= 1024 )) && (( size <= 10240 )); then
          echo "$pkg"
        fi
      done)
      ;;
    "By Size (>10MB)")
      package_list=$(apt-cache pkgnames | while read pkg; do
        size=$(apt-cache show "$pkg" 2>/dev/null | grep "^Installed-Size:" | awk '{print $2}')
        if [[ -n "$size" ]] && (( size > 10240 )); then
          echo "$pkg"
        fi
      done)
      ;;
  esac

  if [[ -z "$package_list" ]]; then
    printf "%bNo packages found matching the filter%b\n" "$YELLOW" "$RESET"
    return 0
  fi

  local selected_packages=$(echo "$package_list" | command fzf --multi \
      --prompt="📦 $filter_choice ❯ " \
      --header='↵ Install | ESC Cancel' \
      --preview="$preview_cmd" \
      --preview-window='right:65%:wrap' \
      --cycle \
      --border='rounded' \
      --pointer='➤ ' \
      --marker='✓ ' \
      --color='fg:#f8f8f2,bg:#282a36,hl:#bd93f9' \
      --color='fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9' \
      --color='info:#ffb86c,prompt:#50fa7b,pointer:#bd93f9,marker:#ff5555,spinner:#ffb86c,header:#8be9fd')

  if [[ -n "$selected_packages" ]]; then
    local pkgs_to_install=$(echo "$selected_packages" | tr '\n' ' ')
    printf "\n%bInstalling selected packages: %s%b\n" "$GREEN" "$pkgs_to_install" "$RESET"
    install_packages "$pkgs_to_install"
  else
    printf "%bNo packages selected for installation.%b\n" "$YELLOW" "$RESET"
  fi
}

apt_search_wrapper() {
    local args=("$@")
    local size_filter=""
    local installed_only=0
    local apt_args=()
    local search_terms=()

    for arg in "${args[@]}"; do
        case "$arg" in
            --installed)
                installed_only=1
                ;;
            --size)
                size_filter="${args[i+1]}"
                i=$((i+1))
                ;;
            *)
                if [[ "$arg" != "--size" ]]; then
                    search_terms+=("$arg")
                fi
                ;;
        esac
    done

    local pkg_list
    if [[ "$installed_only" -eq 1 ]]; then
        pkg_list=$(dpkg -l | awk '/^ii/ {print $2}')
        printf "%bSearching installed packages...%b\n" "$CYAN" "$RESET"
    else
        pkg_list=$(apt-cache pkgnames)
        printf "%bSearching all packages...%b\n" "$CYAN" "$RESET"
    fi

    if [[ ${#search_terms[@]} -gt 0 ]]; then
        local search_pattern=$(IFS='|'; echo "${search_terms[*]}")
        pkg_list=$(echo "$pkg_list" | grep -E "$search_pattern")
    fi

    if [[ -n "$size_filter" ]]; then
        if ! [[ "$size_filter" =~ ^([<>])([0-9]+)([KMG]?B?)$ ]]; then
            printf "%bError: Invalid size filter format. Use e.g., <10MB, >500KB%b\n" "$RED" "$RESET"
            return 1
        fi

        local operator="${BASH_REMATCH[1]}"
        local threshold_kb=$(convert_to_kb "${BASH_REMATCH[2]}${BASH_REMATCH[3]}")

        if [[ "$threshold_kb" -eq -1 ]]; then
             printf "%bError: Invalid size filter value: %s%b\n" "$RED" "$size_filter" "$RESET"
             return 1
        fi

        printf "%bFiltering by size %s KB...%b\n" "$MAGENTA" "$operator $threshold_kb" "$RESET"

        pkg_list=$(echo "$pkg_list" | while read pkg; do
            local size=$(apt-cache show "$pkg" 2>/dev/null | grep "^Installed-Size:" | awk '{print $2}')
            if [[ -n "$size" ]]; then
                local should_print=0
                if [[ "$operator" == "<" ]] && (( size < threshold_kb )); then
                    should_print=1
                elif [[ "$operator" == ">" ]] && (( size > threshold_kb )); then
                    should_print=1
                fi

                if [[ "$should_print" -eq 1 ]]; then
                    echo "$pkg"
                fi
            fi
        done)
    fi

    if [[ -z "$pkg_list" ]]; then
        printf "%bNo packages found.%b\n" "$YELLOW" "$RESET"
        return 0
    fi

    if command -v fzf &> /dev/null; then
        local preview_cmd='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null'
        echo "$pkg_list" | command fzf --multi \
            --prompt="🔎 Search Results ❯ " \
            --header='↵ View Details/Install | ESC Cancel' \
            --preview="$preview_cmd" \
            --preview-window='right:65%:wrap' \
            --cycle \
            --border='rounded' \
            --pointer='➤ ' \
            --color='fg:#f8f8f2,bg:#282a36,hl:#bd93f9' \
            --color='fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9' \
            --color='info:#ffb86c,prompt:#50fa7b,pointer:#bd93f9,marker:#ff5555,spinner:#ffb86c,header:#8be9fd'
    else
        printf "%bUsing standard list (install fzf for interactive results):%b\n" "$YELLOW" "$RESET"
        apt-cache search "$search_terms"
    fi
}

compare_packages() {
  local pkg1="$1"
  local pkg2="$2"

  if [[ -z "$pkg1" || -z "$pkg2" ]]; then
    printf "%bUsage: papt compare <package1> <package2>%b\n" "$YELLOW" "$RESET"
    return 1
  fi

  local pkg1_info=$(apt-cache show "$pkg1" 2>/dev/null)
  local pkg2_info=$(apt-cache show "$pkg2" 2>/dev/null)

  if [[ -z "$pkg1_info" ]]; then
    printf "%bPackage '%s' not found or no information available%b\n" "$RED" "$pkg1" "$RESET"
    return 1
  fi

  if [[ -z "$pkg2_info" ]]; then
    printf "%bPackage '%s' not found or no information available%b\n" "$RED" "$pkg2" "$RESET"
    return 1
  fi

  get_pkg_field() {
    echo "$1" | grep "^$2:" | head -1 | cut -d: -f2- | xargs
  }

  local pkg1_version=$(get_pkg_field "$pkg1_info" "Version")
  local pkg2_version=$(get_pkg_field "$pkg2_info" "Version")

  local pkg1_size_kb=$(get_pkg_field "$pkg1_info" "Installed-Size")
  local pkg2_size_kb=$(get_pkg_field "$pkg2_info" "Installed-Size")

  local pkg1_size_human="${pkg1_size_kb} KB"
  local pkg2_size_human="${pkg2_size_kb} KB"

  local pkg1_desc=$(get_pkg_field "$pkg1_info" "Description")
  local pkg2_desc=$(get_pkg_field "$pkg2_info" "Description")

  local pkg1_deps=$(echo "$pkg1_info" | grep "^Depends:" | head -1 | cut -d: -f2- | tr -d ' ' | tr ',' '\n' | grep -v '^$' | wc -l)
  local pkg2_deps=$(echo "$pkg2_info" | grep "^Depends:" | head -1 | cut -d: -f2- | tr -d ' ' | tr ',' '\n' | grep -v '^$' | wc -l)

  local pkg1_installed="No"
  local pkg2_installed="No"

  if dpkg -l "$pkg1" 2>/dev/null | grep -q "^ii"; then
    pkg1_installed="${GREEN}Yes${RESET}"
  else
    pkg1_installed="${RED}No${RESET}"
  fi

  if dpkg -l "$pkg2" 2>/dev/null | grep -q "^ii"; then
    pkg2_installed="${GREEN}Yes${RESET}"
  else
    pkg2_installed="${RED}No${RESET}"
  fi

  printf "%b%-20s%b | %b%-35s%b | %b%-35s%b\n" "$YELLOW" "Property" "$RESET" "$CYAN" "$pkg1" "$RESET" "$CYAN" "$pkg2" "$RESET"
  printf "%b%s%b\n" "$BLUE" "$(printf '%.0s─' {93})" "$RESET"

  printf "%-20s | %-35s | %-35s\n" "Version" "${pkg1_version:-N/A}" "${pkg2_version:-N/A}"
  printf "%-20s | %-35s | %-35s\n" "Installed Size" "${pkg1_size_human:-N/A}" "${pkg2_size_human:-N/A}"
  printf "%-20s | %-35s | %-35s\n" "Dependencies" "${pkg1_deps:-0}" "${pkg2_deps:-0}"
  printf "%-20s | %-35b | %-35b\n" "Installed" "$pkg1_installed" "$pkg2_installed"

  printf "\n%bDescription (%s):%b\n%s\n" "$CYAN" "$pkg1" "$RESET" "$(echo "$pkg1_desc" | head -3 | sed 's/^/  /')"
  printf "\n%bDescription (%s):%b\n%s\n" "$CYAN" "$pkg2" "$RESET" "$(echo "$pkg2_desc" | head -3 | sed 's/^/  /')"
}

verify_package() {
  local pkg="$1"

  if [[ -z "$pkg" ]]; then
    printf "%bUsage: papt verify <package>%b\n" "$YELLOW" "$RESET"
    return 1
  fi

  if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
    printf "%bPackage '%s' is not installed%b\n" "$RED" "$pkg" "$RESET"
    return 1
  fi

  printf "%bVerifying package: %s%b\n\n" "$CYAN" "$pkg" "$RESET"

  printf "%b[1/4]%b Checking installation status... " "$BLUE" "$RESET"
  local install_status=$(dpkg -l "$pkg" 2>/dev/null | awk '/^ii/ {print "Installed"}')
  if [[ "$install_status" == "Installed" ]]; then
    printf "%b[ OK ]%b\n" "$GREEN" "$RESET"
  else
    printf "%b[ FAIL ]%b\n" "$RED" "$RESET"
    printf "  %b✗ Package installation is incomplete%b\n" "$RED" "$RESET"
  fi

  printf "%b[2/4]%b Checking file integrity... " "$BLUE" "$RESET"
  local verification=$(dpkg --verify "$pkg" 2>&1)
  if [[ -z "$verification" ]]; then
    printf "%b[ OK ]%b\n" "$GREEN" "$RESET"
  else
    printf "%b[ WARNING ]%b\n" "$YELLOW" "$RESET"
    printf "  %b✗ Some files have been modified or are missing:%b\n" "$YELLOW" "$RESET"
    echo "$verification" | head -10 | while read line; do
        printf "    %s\n" "$line" # Indented output
    done
    local mod_count=$(echo "$verification" | wc -l)
    if [[ $mod_count -gt 10 ]]; then
      printf "  %b... and %d more files (Run 'dpkg --verify %s' for full list)%b\n" "$YELLOW" "$((mod_count - 10))" "$pkg" "$RESET"
    fi
  fi
  printf "\n"

  printf "%b[3/4]%b Checking dependencies... " "$BLUE" "$RESET"
  local missing_deps=$(apt-cache depends "$pkg" 2>/dev/null | grep "Depends:" | awk '{print $2}' | sed 's/[<>]//g' | while read dep; do
    local base_dep=$(echo "$dep" | cut -d'(' -f1)
    if [[ -n "$base_dep" ]] && ! dpkg -l "$base_dep" 2>/dev/null | grep -q "^ii"; then
      echo "$base_dep"
    fi
  done | sort | uniq)

  if [[ -z "$missing_deps" ]]; then
    printf "%b[ OK ]%b\n" "$GREEN" "$RESET"
  else
    printf "%b[ FAIL ]%b\n" "$RED" "$RESET"
    printf "  %b✗ Missing dependencies (or not currently installed):%b\n" "$RED" "$RESET"
    echo "$missing_deps" | head -10 | while read dep; do
      printf "    - %s\n" "$dep"
    done
    local dep_count=$(echo "$missing_deps" | wc -l)
    if [[ $dep_count -gt 10 ]]; then
      printf "  %b... and %d more dependencies%b\n" "$RED" "$((dep_count - 10))" "$RESET"
    fi
  fi
  printf "\n"

  printf "%b[4/4]%b Package summary:\n" "$BLUE" "$RESET"
  local pkg_version=$(dpkg -l "$pkg" 2>/dev/null | awk '/^ii/ {print $3}')
  local pkg_arch=$(dpkg -l "$pkg" 2>/dev/null | awk '/^ii/ {print $4}')
  local pkg_status=$(dpkg -l "$pkg" 2>/dev/null | awk '/^ii/ {print $1}')

  printf "  %-15s: %b%s%b\n" "Status" "$CYAN" "$pkg_status" "$RESET"
  printf "  %-15s: %b%s%b\n" "Version" "$CYAN" "$pkg_version" "$RESET"
  printf "  %-15s: %b%s%b\n" "Architecture" "$CYAN" "$pkg_arch" "$RESET"

  printf "\n%b════════════════════════════════════════════════════════════════════════════════════════%b\n" "$CYAN" "$RESET"
  printf "%bVerification Complete%b\n" "$GREEN" "$RESET"
}

extract_repo_from_url() {
  local input="$1"

  input="${input%/}"

  if [[ "$input" =~ github\.com/([^/]+)/([^/]+)(\.git)?$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$input" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+(\.git)?$ ]]; then
    echo "$input" | sed 's/\.git$//'
    return 0
  fi

  return 1
}

github_install() {
  local url="$1"
  local repo_path

  if [[ -z "$url" ]]; then
    printf "%bUsage: papt github <github_url> OR <user/repo>%b\n" "$YELLOW" "$RESET"
    return 1
  fi

  repo_path=$(extract_repo_from_url "$url")

  if [[ $? -ne 0 || -z "$repo_path" ]]; then
    printf "%bError: Invalid GitHub URL or format '%s'. Expected format: user/repo or full URL.%b\n" "$RED" "$url" "$RESET"
    return 1
  fi

  local user=$(echo "$repo_path" | cut -d/ -f1)
  local repo=$(echo "$repo_path" | cut -d/ -f2)
  local clone_url="https://github.com/$repo_path.git"
  local temp_dir="/tmp/papt_github_install/$repo"

  printf "%bAttempting to install '%s' from GitHub...%b\n" "$CYAN" "$repo_path" "$RESET"

  if ! command -v git &> /dev/null; then
    printf "%bError: 'git' is required for GitHub installation. Install it first.%b\n" "$RED" "$RESET"
    return 1
  fi

  rm -rf "$temp_dir" 2>/dev/null
  mkdir -p "$temp_dir"

  printf "%b[1/3]%b Cloning repository from %s...\n" "$BLUE" "$RESET" "$clone_url"
  if ! git clone "$clone_url" "$temp_dir" 2> "$ERR_FILE"; then
    printf "%b✗ Error cloning repository. Check %s for details.%b\n" "$RED" "$ERR_FILE" "$RESET"
    return 1
  fi

  cd "$temp_dir" || {
    printf "%b✗ Error changing directory to %s%b\n" "$RED" "$temp_dir" "$RESET"
    return 1
  }

  printf "%b[2/3]%b Searching for installation script/instructions...\n" "$BLUE" "$RESET"

  local install_script=""
  if [[ -f "INSTALL.sh" ]]; then
    install_script="INSTALL.sh"
  elif [[ -f "install.sh" ]]; then
    install_script="install.sh"
  elif [[ -f "setup.py" ]]; then
    install_script="python setup.py install"
  elif [[ -f "Makefile" ]]; then
    install_script="make && make install"
  fi

  if [[ -z "$install_script" ]]; then
    printf "%b✗ Could not find a standard installation script (INSTALL.sh, install.sh, setup.py, Makefile).%b\n" "$RED" "$RESET"
    printf "%bManual review required in %s%b\n" "$YELLOW" "$temp_dir" "$RESET"
    return 1
  fi

  printf "%b[3/3]%b Executing installation: %s\n" "$BLUE" "$RESET" "$install_script"

  if [[ "$install_script" == "make && make install" ]]; then
    # Handle Makefiles
    if ! make 2> "$ERR_FILE" || ! make install 2> "$ERR_FILE"; then
      printf "%b✗ Installation failed (make/make install). Check %s.%b\n" "$RED" "$ERR_FILE" "$RESET"
      rm -rf "$temp_dir"
      return 1
    fi
  else
    if ! /bin/bash -c "$install_script" 2> "$ERR_FILE"; then
      printf "%b✗ Installation script failed. Check %s.%b\n" "$RED" "$ERR_FILE" "$RESET"
      rm -rf "$temp_dir"
      return 1
    fi
  fi

  printf "\n%b✓ '%s' installed successfully!%b\n" "$GREEN" "$repo" "$RESET"
  log_operation "GITHUB_INSTALL" "$repo_path" "SUCCESS"

  cd - >/dev/null
  rm -rf "$temp_dir"
}

run_apt_command() {
  local command="$1"
  shift
  local packages="$@"
  local color=$(get_color_for_command "$command")
  local apt_cmd="apt-get -y --allow-downgrades"

  if [[ "$command" == "install" || "$command" == "remove" ]]; then
    if [[ -z "$packages" ]]; then
      printf "%bError: '%s' command requires at least one package name.%b\n" "$RED" "$command" "$RESET" >&2
      show_help
      return 1
    fi

    if [[ "$command" == "install" || "$command" == "remove" ]]; then
        local snapshot_file=$(create_snapshot)
    fi
  fi

  if needs_progress_bar "$command"; then
    if [[ "$command" == "update" ]]; then
        apt-get update 2> "$ERR_FILE"
        local apt_status=$?
    else
        "$apt_cmd" "$command" "$packages" > "$LOG_FILE" 2> "$ERR_FILE" &
        local pid=$!
        animate_progress "$pid" "$color"
        wait "$pid"
        local apt_status=$?
    fi
  else
    if [[ "$command" == "search" ]]; then
        apt_search_wrapper "$@"
        local apt_status=$?
    else
        apt "$command" "$packages"
        local apt_status=$?
    fi
  fi

  if [[ "$command" == "show" || "$command" == "list" || "$command" == "search" ]]; then
    return 0
  fi

  if [[ "$apt_status" -eq 0 ]]; then
    printf "%b✓ %s operation completed successfully%b\n" "$GREEN" "$command" "$RESET"
    log_operation "$command" "$packages" "SUCCESS"
  else
    printf "%b✗ %s operation FAILED%b\n" "$RED" "$command" "$RESET"
    log_operation "$command" "$packages" "FAILED"
  fi

  return "$apt_status"
}

if [[ $EUID -ne 0 ]]; then
  case "$1" in
    install|reinstall|remove|purge|autoremove|update|upgrade|full-upgrade|dist-upgrade|rollback|github|edit-sources)
      printf "%bError: This command requires root privileges. Please run with 'sudo papt ...'%b\n" "$RED" "$RESET" >&2
      exit 1
      ;;
  esac
fi

init_history

COMMAND="$1"
shift

case "$COMMAND" in
  ""|-h|--help)
    show_help
    ;;
  -v|--version)
    show_version
    ;;
  history)
    show_history
    ;;
  rollback)
    rollback_snapshot
    ;;
  snapshots)
    list_snapshots
    ;;
  fsearch)
    filtered_search
    ;;
  compare)
    compare_packages "$@"
    ;;
  verify)
    verify_package "$1"
    ;;
  github)
    github_install "$1"
    ;;
  finstall)
    filtered_search
    ;;
  fremove)
    if ! command -v fzf &> /dev/null; then
        printf "%bfzf is not installed. Install it first: sudo papt install fzf%b\n" "$RED" "$RESET"
        exit 1
    fi
    selected_pkgs=$(dpkg -l | awk '/^ii/ {print $2}' | command fzf --multi \
        --prompt='🗑️ Select packages to REMOVE ❯ ' \
        --header='↵ Remove | ESC Cancel' \
        --preview='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null' \
        --preview-window='right:65%:wrap' \
        --marker='✓ ' \
        --color='fg:#f8f8f2,bg:#282a36,hl:#ff5555' \
        --color='fg+:#f8f8f2,bg+:#44475a,hl+:#ff5555')
    if [[ -n "$selected_pkgs" ]]; then
        pkgs_to_remove=$(echo "$selected_pkgs" | tr '\n' ' ')
        printf "\n%bRemoving selected packages: %s%b\n" "$RED" "$pkgs_to_remove" "$RESET"
        run_apt_command "remove" "$pkgs_to_remove"
    else
        printf "%bNo packages selected for removal.%b\n" "$YELLOW" "$RESET"
    fi
    ;;
  fshow)
    if ! command -v fzf &> /dev/null; then
        printf "%bfzf is not installed. Install it first: sudo papt install fzf%b\n" "$RED" "$RESET"
        exit 1
    fi
    local selected_pkg=$(apt-cache pkgnames | command fzf \
        --prompt='Select package to SHOW ❯ ' \
        --preview='apt-cache show {} 2>/dev/null | batcat --style=numbers --color=always -l yaml || apt-cache show {} 2>/dev/null' \
        --preview-window='right:65%:wrap')
    if [[ -n "$selected_pkg" ]]; then
        printf "\n%bPackage Details for %s:%b\n" "$CYAN" "$selected_pkg" "$RESET"
        apt-cache show "$selected_pkg"
    else
        printf "%bNo package selected.%b\n" "$YELLOW" "$RESET"
    fi
    ;;
  install|reinstall|remove|purge|autoremove|update|upgrade|full-upgrade|dist-upgrade|list|show|edit-sources|satisfy|search)
    run_apt_command "$COMMAND" "$@"
    ;;
  *)
    printf "%bError: Unknown command '%s'.%b\n" "$RED" "$COMMAND" "$RESET" >&2
    show_help
    exit 1
    ;;
esac
