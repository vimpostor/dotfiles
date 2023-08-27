#!/usr/bin/env bash

diff --color=auto -y --suppress-common-lines -- <(cat $(find . -type f -name packages.txt) | sort -u) <(cat <(pacman -Qqe) <(echo base-devel) | sort -u)
