#!/usr/bin/env sh
# Takes as only argument the new fork git URL

git remote rename origin upstream
git remote add origin "$*"
git remote -v
