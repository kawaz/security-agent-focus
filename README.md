# security-agent-focus

Auto-focus TouchID dialog on macOS when sudo prompts.

## Problem

When you run `sudo` in a terminal, macOS shows the TouchID authentication dialog, but it doesn't automatically receive keyboard focus. This means you have to manually click on the dialog or use your mouse to interact with it.

## Solution

This script monitors macOS system logs for SecurityAgent window events and automatically focuses the TouchID dialog when it appears.

## Requirements

- macOS (tested on macOS Sequoia)
- Accessibility permissions for `osascript` (System Settings > Privacy & Security > Accessibility)
- Automation permissions for `osascript` to control System Events

## Installation

### Using Nix

```bash
nix run github:kawaz/security-agent-focus -- register
```

### Manual

```bash
# Download the script
curl -o /usr/local/bin/security-agent-focus https://raw.githubusercontent.com/kawaz/security-agent-focus/main/security-agent-focus.sh
chmod +x /usr/local/bin/security-agent-focus

# Register as LaunchDaemon (runs at boot)
security-agent-focus register
```

## Usage

```bash
security-agent-focus <command>

Commands:
  register    Register as LaunchDaemon
  unregister  Unregister LaunchDaemon
  status      Show daemon status
  run         Run daemon (foreground)
```

## How it works

1. Runs as a LaunchDaemon (root) to access system logs
2. Uses `log stream` to monitor for SecurityAgent window events
3. When a TouchID dialog appears, uses AppleScript to focus it

## Uninstall

```bash
security-agent-focus unregister
rm /usr/local/bin/security-agent-focus
```

## License

MIT
