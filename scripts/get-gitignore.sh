#!/usr/bin/env bash

# Usage: ./get-gitignore.sh c++ cmake

GITIGNORES="$*"
curl -s "https://www.toptal.com/developers/gitignore/api/${GITIGNORES// /,}" >> .gitignore
