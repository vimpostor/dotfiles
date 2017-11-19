#!/usr/bin/env bash

paccache -rk 1
journalctl --vacuum-size=10M
