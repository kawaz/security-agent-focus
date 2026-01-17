#!/bin/bash
# SecurityAgent (TouchID dialog) auto-focus daemon
set -eu

LABEL="com.github.kawaz.security-agent-focus"
PLIST="/Library/LaunchDaemons/${LABEL}.plist"
SCRIPT="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

is_registered() {
  launchctl print "system/$LABEL" &>/dev/null
}

is_running() {
  launchctl print "system/$LABEL" 2>/dev/null | grep -q 'state = running'
}

case "${1:-}" in
  register)
    if is_running; then
      echo "Already running: $LABEL"
      exit 0
    fi
    is_registered && sudo launchctl unload "$PLIST"
    sudo tee "$PLIST" > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT}</string>
        <string>run</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
    sudo launchctl load "$PLIST"
    echo "Registered: $LABEL"
    ;;
  unregister)
    is_registered && sudo launchctl unload "$PLIST"
    sudo rm -f "$PLIST"
    echo "Unregistered: $LABEL"
    ;;
  status)
    if is_registered; then
      state=$(launchctl print "system/$LABEL" | grep -oE 'state = \w+' | cut -d' ' -f3)
      echo "Registered: $LABEL ($state)"
    else
      echo "Not registered"
    fi
    ;;
  run)
    # Main daemon loop
    log stream --predicate 'process == "SecurityAgent" AND eventMessage CONTAINS "order window front"' --style compact 2>/dev/null | while read -r _; do
      osascript \
        -e 'tell application "System Events" to tell process "SecurityAgent" to set frontmost to true' \
        -e 'tell application "System Events" to tell process "SecurityAgent" to perform action "AXRaise" of window 1' \
        2>/dev/null
    done
    ;;
  *)
    echo "Usage: $(basename "$0") <command>"
    echo ""
    echo "Commands:"
    echo "  register    Register as LaunchDaemon"
    echo "  unregister  Unregister LaunchDaemon"
    echo "  status      Show daemon status"
    echo "  run         Run daemon (foreground)"
    ;;
esac
