Separate Help File Content (save as batocera-tools-help.txt)
Copy the text below into a file named batocera-tools-help.txt and place it in /userdata/system/scripts/ or wherever you keep docs. The script's Help/About shows a built-in version, but this file can be more detailed or updated separately.


Batocera Tools Script Help
==========================

Purpose
-------
Quick access to edit/view/backup important Batocera folders (configs, saves, etc.)
GUI with mouse support (Zenity if DISPLAY set), fallback to dialog/text.

Key Features
------------
• Browse & edit configs (Dolphin .ini, RetroArch .cfg/.opt, batocera.conf)
• Refresh game lists (restarts EmulationStation)
• View recent logs (es_launch_stderr.log, es_log.txt)
• Backup folders to /userdata/backups/
• Search files inside folders
• Open folder in file manager
• Copy path to clipboard
• Debug mode: run with --debug

How to Run
----------
From SSH/console: ./batocera-tools.sh [--debug]

Best Experience
---------------
• SSH with X forwarding (-X) → Zenity GUI + mouse clicks
• Install zenity if missing (if Batocera package manager allows)

Customization
-------------
Edit the 'options' array in the script to add/remove entries.
Example additions:
  "My Custom Folder:/userdata/myfolder/"
  "WiFi Settings:WiFi"  (then add case in code)

Troubleshooting
---------------
• No GUI? Check DISPLAY var; fallback is text.
• Commands fail? Test via SSH (e.g. batocera-es-swissknife --restart)
• Logs useful for launch issues.

Enjoy & tweak as needed!
