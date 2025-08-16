#!/usr/bin/env bash

tee /proc/sys/kernel/yama/ptrace_scope <<< 0
