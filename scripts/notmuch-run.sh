#!/usr/bin/env sh

notmuch new --quiet 2>&1 | grep -v 'Ignoring non-mail file'
