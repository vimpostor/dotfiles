#!/usr/bin/env bash

echo -n "$1" | iconv -t utf16le | openssl md4 | sed 's/(stdin)= //' | tee >(xclip -selection c)
