#!/bin/bash

# =============================================================================
# Batocera Folder Shortcuts & Tools Script - Enhanced Packaged Version
# =============================================================================
# Author: Grok (built by xAI), customized for Paul
# Version: 1.0.0  # Added for version checking
# Last Updated: February 25, 2026
#
# Changelog for Updates:
#   - Added CHANGELOG_URL to fetch and display changelog from GitHub before updating.
#     - Setup: Create a CHANGELOG.md in your repo/Gist with markdown or plain text entries.
#     - Example content: "## v1.1.0\n- Added feature X\n- Fixed bug Y"
#     - In check_for_update: Fetches and shows in textbox if available.
#     - Fallback if no changelog: "No changelog available."
#   - # Optional: If you don't want changelog fetch, comment out the relevant lines.
#
# GitHub Self-Update (unchanged otherwise):
#   - Replace UPDATE_URL and CHANGELOG_URL with your actual raw GitHub URLs.
#
# Other Features: GUI, emulators, edit/backup/search/logs/refresh/etc.

# Version for self-update
VERSION="1.0.0"
UPDATE_URL="https://raw.githubusercontent.com/yourusername/yourrepo/main/batocera-tools.sh"  # Your script raw URL
CHANGELOG_URL="https://raw.githubusercontent.com/yourusername/yourrepo/main/CHANGELOG.md"  # Your changelog raw URL

# Parse debug
DEBUG=0
for arg in "$@"; do
  case "$arg" in --debug|-d) DEBUG=1 ;; esac
done

debug_msg() { [ $DEBUG -eq 1 ] && echo "[DEBUG] $1" >&2; }

# Self-Update Function (with changelog)
check_for_update() {
  if ! ping -c 1 github.com &>/dev/null; then
    debug_msg "No internet – skipping update check."
    return
  fi

  if command -v curl >/dev/null; then
    latest_code=$(curl -s "$UPDATE_URL")
    changelog=$(curl -s "$CHANGELOG_URL")
  elif command -v wget >/dev/null; then
    latest_code=$(wget -qO- "$UPDATE_URL")
    changelog=$(wget -qO- "$CHANGELOG_URL")
  else
    show_msg "No curl/wget – skipping update."
    return
  fi

  if [ -z "$latest_code" ]; then
    show_msg "Failed to fetch update from GitHub."
    return
  fi

  latest_version=$(echo "$latest_code" | grep '^# Version:' | awk '{print $3}')
  if [ -n "$latest_version" ] && [ "$latest_version" != "$VERSION" ]; then
    # Show changelog if available
    if [ -n "$changelog" ]; then
      show_textbox "Changelog for v$latest_version" "$changelog"
    else
      show_msg "No changelog available for this update."
    fi

    if get_yesno "New version $latest_version available on GitHub (current: $VERSION). Update?"; then
      backup_file="${0}.bak"
      cp "$0" "$backup_file"
      echo "$latest_code" > "$0"
      chmod +x "$0"
      show_msg "Updated from GitHub! Backup saved as $backup_file. Restarting script."
      exec "$0" "$@"
    fi
  else
    debug_msg "Up to date with GitHub."
  fi
}

# Run update check at start
check_for_update

# =============================================================================
# MENU OPTIONS ARRAY (unchanged)
# =============================================================================
options=(
  "Main Userdata Folder:/userdata/"
  "ROMs:/userdata/roms/"
  "Edit Main Config (batocera.conf):/userdata/system/batocera.conf"
  "System Settings Folder:/userdata/system/"
  "Emulator Configurations:/userdata/system/configs/"
  "Game Saves:/userdata/saves/"
  "BIOS Files:/userdata/bios/"
  "Cheats:/userdata/cheats/"
  "Themes:/userdata/themes/"
  "Decorations:/userdata/decorations/"
  "Shaders (User):/userdata/shaders/"
  "Music:/userdata/music/"
  "Screenshots:/userdata/screenshots/"
  "Splash Screens:/userdata/splash/"
  "Dolphin Wiimote & Configs:/userdata/system/configs/dolphin-emu/"
  "Dolphin User Directory:/userdata/saves/dolphin-emu/"
  "Dolphin GameINI:/userdata/saves/dolphin-emu/GameSettings/"
  "Dolphin States:/userdata/saves/dolphin-emu/StateSaves/"
  "Dolphin Load (Textures/Shaders):/userdata/saves/dolphin-emu/Load/"
  "RetroArch Main Config:/userdata/system/configs/retroarch/"
  "RetroArch Overrides:/userdata/system/configs/retroarch/overrides/"
  "RetroArch Remaps:/userdata/system/configs/retroarch/remaps/"
  "RetroArch Shaders:/userdata/system/configs/retroarch/shaders/"
  "RetroArch Overlays:/userdata/system/configs/retroarch/overlays/"
  "PCSX2 (PS2) Configs:/userdata/system/configs/pcsx2/"
  "DuckStation (PS1) Configs:/userdata/system/configs/duckstation/"
  "MAME Configs:/userdata/system/configs/mame/"
  "Flycast (Dreamcast) Configs:/userdata/system/configs/flycast/"
  "Vita3K (PS Vita) Configs:/userdata/system/configs/vita3k/"
  "MelonDS (DS) Configs:/userdata/system/configs/melonDS/"
  "Cemu (Wii U) Configs:/userdata/system/configs/cemu/"
  "RPCS3 (PS3) Configs:/userdata/system/configs/rpcs3/"
  "Xenia (Xbox 360) Configs:/userdata/system/configs/xenia/"
  "Refresh Game Lists:refresh"
  "View Recent Logs:logs"
  "Help/About:help"
  "Exit:exit"
)

# =============================================================================
# UI DETECTION & HELPER FUNCTIONS (unchanged)
# =============================================================================
UI_TOOL="text"
if command -v zenity >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
  UI_TOOL="zenity"
elif command -v dialog >/dev/null 2>&1; then
  UI_TOOL="dialog"
fi
debug_msg "UI tool detected: $UI_TOOL"

show_msg() {
  local msg="$1" title="${2:-Info}"
  case "$UI_TOOL" in
    zenity) zenity --info --title="$title" --text="$msg" --width=600 --height=200 ;;
    dialog) dialog --msgbox "$msg" 12 70 ;;
    *) echo -e "\n$title:\n$msg\n" ;;
  esac
}

get_yesno() {
  local prompt="$1"
  case "$UI_TOOL" in
    zenity) zenity --question --title="Confirm" --text="$prompt" --width=400; return $? ;;
    dialog) dialog --yesno "$prompt" 10 60; return $? ;;
    *) read -p "$prompt (y/n): " yn; [[ $yn =\~ ^[Yy] ]] && return 0 || return 1 ;;
  esac
}

show_textbox() {
  local title="$1" content="$2"
  local tmp="/tmp/batocera-tools.txt"
  echo -e "$content" > "$tmp"
  case "$UI_TOOL" in
    zenity) zenity --text-info --title="$title" --filename="$tmp" --width=900 --height=600 ;;
    dialog) dialog --title "$title" --textbox "$tmp" 22 85 ;;
    *) cat "$tmp"; echo ;;
  esac
  rm -f "$tmp"
}

get_input() {
  local prompt="$1" var="$2"
  local val
  case "$UI_TOOL" in
    zenity) val=$(zenity --entry --title="Input" --text="$prompt" --width=400) ;;
    dialog) val=$(dialog --inputbox "$prompt" 10 60 2>&1 >/dev/tty) ;;
    *) read -p "$prompt: " val ;;
  esac
  printf -v "$var" '%s' "$val"
}

get_menu_choice() {
  local title="$1" ; shift
  local items=("$@")
  local choice
  case "$UI_TOOL" in
    zenity)
      local zen_items=()
      for ((i=0; i<\( {#items[@]}; i+=2)); do zen_items+=(" \){items[i]}" "${items[i+1]}"); done
      choice=$(zenity --list --title="\( title" --text="Select:" --column="ID" --column="Description" --width=900 --height=600 " \){zen_items[@]}")
      ;;
    dialog)
      choice=$(dialog --title "\( title" --menu "Select:" 22 85 14 " \){items[@]}" 2>&1 >/dev/tty)
      [ $? -ne 0 ] && return 1
      ;;
    *)
      echo "$title"; echo "Enter number:"
      for ((i=0; i<\( {#items[@]}; i+=2)); do echo " \){items[i]}) ${items[i+1]}"; done
      read -p "Choice: " choice
      ;;
  esac
  echo "$choice"
}

# =============================================================================
# HELP TEXT – Loads from file if exists (unchanged)
# =============================================================================
HELP_FILE="${BASH_SOURCE[0]%.*}-help.txt"
if [ -f "$HELP_FILE" ]; then
  HELP_TEXT=$(cat "$HELP_FILE")
else
  HELP_TEXT="Batocera Tools Script Help\n... (default inline help)"
fi

# =============================================================================
# MAIN LOOP (unchanged)
# =============================================================================
while true; do
  menu_items=()
  for i in "${!options[@]}"; do
    tag=$((i+1))
    desc="${options[i]%%:*}"
    target="${options[i]##*:}"
    display="$desc"
    [[ $target == /* ]] && display="$desc ($target)"
    menu_items+=("$tag" "$display")
  done

  choice=\( (get_menu_choice "Batocera Tools Menu" " \){menu_items[@]}")
  [[ -z "$choice" ]] && break

  if ! [[ "\( choice" =\~ ^[0-9]+ \) ]] || [ "$choice" -lt 1 ] || [ "\( choice" -gt " \){#options[@]}" ]; then
    show_msg "Invalid choice." "Error"
    continue
  fi

  idx=$((choice - 1))
  selected="${options[idx]}"
  desc="${selected%%:*}"
  target="${selected##*:}"
  debug_msg "Selected: $desc → $target"

  case "$target" in
    help) show_textbox "Help / About" "$HELP_TEXT"; continue ;;
    exit) show_msg "Goodbye!" "Exit"; break ;;
    refresh)
      show_msg "Refreshing game lists..."
      batocera-es-swissknife --restart 2>/dev/null || systemctl restart emulationstation 2>/dev/null || show_msg "Refresh failed."
      sleep 2
      continue
      ;;
    logs)
      log_content=""
      for log in /userdata/system/logs/es_launch_stderr.log /userdata/system/logs/es_launch_stdout.log /userdata/system/configs/emulationstation/es_log.txt; do
        [ -f "$log" ] && log_content+="\n\n=== \( log (last 30 lines) ===\n \)(tail -n 30 "$log")"
      done
      [ -z "$log_content" ] && log_content="No logs found."
      show_textbox "Recent Logs" "$log_content"
      continue
      ;;
  esac

  if [ -f "$target" ]; then
    show_msg "Opening file: $target"
    command -v nano >/dev/null && nano "$target" || command -v vi >/dev/null && vi "$target" || show_msg "No editor."
    continue
  elif [ ! -d "$target" ]; then
    show_msg "Not found: $target" "Warning"
    continue
  fi

  show_msg "Selected: $desc\n$target"
  ls_out=$(ls -l "$target" 2>&1)
  show_textbox "Contents" "$ls_out"

  # Open in file manager
  if [[ "$UI_TOOL" == "zenity" ]] && command -v xdg-open >/dev/null && get_yesno "Open in file manager?"; then
    xdg-open "$target" &
  fi

  # Copy path
  if command -v xclip >/dev/null && get_yesno "Copy path?"; then
    echo -n "$target" | xclip -selection clipboard
    show_msg "Copied!"
  fi

  # Edit for configs
  if [[ "$target" == *dolphin-emu* || "$target" == *retroarch* || "$target" == */configs/* ]] && get_yesno "Edit file?"; then
    ext=".ini"; files=("$target"/*.ini)
    if [[ "$target" != *dolphin-emu* ]]; then ext=".cfg/.opt/.ini"; files=("$target"/*.{cfg,opt,ini}); fi
    if [ \( {#files[@]} -gt 0 ] && [[ " \){files[0]}" != "$target/*" ]]; then
      file_menu=()
      for j in "\( {!files[@]}"; do file_menu+=(" \)((j+1))" "${files[j]##*/}"); done
      fchoice=\( (get_menu_choice "Select File" " \){file_menu[@]}")
      if [[ "\( fchoice" =\~ ^[0-9]+ \) ]] && [ "$fchoice" -ge 1 ] && [ "\( fchoice" -le " \){#files[@]}" ]; then
        fpath="\( {files[ \)((fchoice-1))]}"
        command -v nano >/dev/null && nano "$fpath" || command -v vi >/dev/null && vi "$fpath" || show_msg "No editor."
      fi
    else
      show_msg "No $ext files."
    fi
  fi

  # Backup
  if get_yesno "Backup folder?"; then
    bdir="/userdata/backups"; mkdir -p "$bdir"
    ts=$(date +%Y%m%d_%H%M%S)
    bfile="\( bdir/ \)(basename "$target")_$ts.tar.gz"
    tar -czf "\( bfile" -C " \)(dirname "\( target")" " \)(basename "$target")" 2>/dev/null && show_msg "Backup: $bfile" || show_msg "Backup failed."
  fi

  # Search
  if get_yesno "Search files?"; then
    pat=""
    get_input "Pattern (e.g. *.ini)" pat
    [ -n "\( pat" ] && res= \)(find "$target" -type f -iname "*$pat*" 2>/dev/null | sort) || res="No pattern."
    [ -z "$res" ] && res="No matches."
    show_textbox "Search *$pat*" "$res"
  fi
done

clear
echo "Script ended."