#!/usr/bin/env bash
# Source this with the only argument being a directory pointing to the mesa install root
# to setup an environment using a self-compiled mesa,
# much inspired by https://github.com/nix-community/nixGL
# Assumes a /usr prefix, make sure to pass --prefix=/usr to meson:
# meson setup build --prefix=/usr

MESAROOT="$(realpath "$@")"

export GBM_BACKENDS_PATH="$MESAROOT/usr/lib/gbm" VDPAU_DRIVER_PATH="$MESAROOT/usr/lib/vdpau" __EGL_VENDOR_LIBRARY_FILENAMES="$MESAROOT/usr/share/glvnd/egl_vendor.d/50_mesa.json" LIBVA_DRIVERS_PATH="$MESAROOT/usr/lib/dri" LIBGL_DRIVERS_PATH="$MESAROOT/usr/lib/dri" LD_LIBRARY_PATH="$MESAROOT/usr/lib"
