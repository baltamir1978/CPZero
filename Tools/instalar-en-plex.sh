#!/bin/sh
# Instala (o actualiza) la sesión «CPZero» de Claude Code en plex: su carpeta de trabajo con
# el CLAUDE.md del Cardputer y el servicio de usuario que la publica por Remote Control.
#   Tools/instalar-en-plex.sh          → en plex
#   Tools/instalar-en-plex.sh <host>   → en otro
# No toca la sesión «plex» (la de Home Assistant, claude-remote.service).
set -eu
HOST=${1:-plex}
cd "$(dirname "$0")/.."

ssh "$HOST" 'mkdir -p ~/CPZero ~/.config/systemd/user'
scp -q plex/CLAUDE.md "$HOST:CPZero/CLAUDE.md"
scp -q systemd/claude-remote-cpzero.service "$HOST:.config/systemd/user/"
ssh "$HOST" '
  systemctl --user daemon-reload
  systemctl --user enable claude-remote-cpzero.service >/dev/null 2>&1
  systemctl --user restart claude-remote-cpzero.service
  sleep 3
  systemctl --user is-active claude-remote-cpzero.service
'
