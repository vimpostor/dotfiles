#!/usr/bin/env bash

diff --color=auto -y --suppress-common-lines -- <(cat $(find . -type f -name packages.txt) <(pacman -Qgq base-devel) | sort -u) <(cat <(pacman -Qqe) <(echo base-devel) | sort -u)
