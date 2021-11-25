# Dotfiles

This is the config for my Arch Linux setup.

# Setup

Run `./link.sh` in the root of the repo to interactively choose what files to install.

If you just want to install all files, run `./link.sh -y`.

See `./link.sh -h` for more options.

Alternatively you can install the config using Ansible with `ansible-playbook ansible/user.yml`.

# Advanced

The `link.sh` script only handles trivial file symlinks inside the user's home directory, which is sufficient for most user settings.
More advanced configurations (e.g. system-wide settings and templated user configs) are managed using Ansible, for more info navigate to the `ansible` subdirectory.
