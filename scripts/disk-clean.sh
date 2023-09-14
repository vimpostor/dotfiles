#!/usr/bin/env bash

journalctl --vacuum-size=10M
paccache -rk 1
