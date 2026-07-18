#!/usr/bin/env bash

# clean root
sudo -s -- <<EOF
journalctl --vacuum-size=10M
paccache -rk 1
EOF

# clean user
podman system prune -af
nix-collect-garbage --quiet -d
