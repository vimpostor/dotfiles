#!/usr/bin/env bash

diff --color=auto -y --suppress-common-lines -- <(cat $(find . -type f -name packages.txt) | sort) <(pacman -Qqe)
