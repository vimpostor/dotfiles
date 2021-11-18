#!/usr/bin/env bash

set -e

function grep_srcinfo() {
	grep "^\s*$*" .SRCINFO | sed "s/^\s*$* = //"
}

makepkg -s
makepkg --printsrcinfo > .SRCINFO

PKGNAME="$(grep_srcinfo pkgname)"
PKGVER="$(grep_srcinfo pkgver)"
PKGREL="$(grep_srcinfo pkgrel)"
git add PKGBUILD .SRCINFO
git commit -m "upgpkg: $PKGNAME $PKGVER-$PKGREL"
