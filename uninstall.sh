#!/bin/bash
# Remove LidAwake completely and put sleep back to normal.
set -uo pipefail

osascript -e 'quit app "LidAwake"' 2>/dev/null
pkill -x LidAwake 2>/dev/null

echo "Restoring normal sleep and removing the sudoers rule (asks for your password)..."
sudo /usr/bin/pmset -a disablesleep 0
sudo rm -f /etc/sudoers.d/lidawake

rm -rf "${HOME}/Applications/LidAwake.app" /Applications/LidAwake.app
defaults delete local.lidawake 2>/dev/null

echo "Gone. Your Mac will sleep when you close the lid again. Like an animal."
