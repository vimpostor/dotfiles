#!/usr/bin/env bash

# Usage: ./get-gitignore.sh c++ cmake

GITIGNORES="$*"
curl -s "https://toptal.com/developers/gitignore/api/${GITIGNORES// /,}" >> .gitignore
