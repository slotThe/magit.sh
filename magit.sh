#!/bin/bash

# Copyright (C) 2020  Adam Porter

# Author: Adam Porter <adam@alphapapa.net>
# URL: https://github.com/alphapapa/magit.sh

# * Commentary:

# Run a standalone Magit editor!  To improve startup speed, this
# script ignores the user's Emacs init files and only loads the Emacs
# libraries Magit requires.

# Note that this does NOT install any packages.  Magit and its
# dependencies must already be installed in ~/.emacs.d.

# * License:

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# * Code:

dependencies=(magit async dash with-editor git-commit transient)

function load_paths {
    # Echo the "-L PATH" arguments for Emacs.  Since multiple versions
    # of a package could be installed, and we want the latest one, we
    # sort them and take the top one.
    for package in "$@"
    do
        find ~/.emacs.d/elpa -maxdepth 1 -type d -iname "$package-2*" \
            | sort -r | head -n1 | \
            while read path
            do
                printf -- '-L %q ' "$path"
            done
    done
}

function usage {
    cat <<EOF
It's Magit!

magit.sh [OPTIONS] [PATH]

Options:
  -h, --help  This.
  -x, --no-x  Display in terminal instead of in a GUI window.
EOF
}

# * Args

args=$(getopt -n "$0" -o hx -l help,no-x -- "$@") || { usage; exit 1; }
eval set -- "$args"

while true
do
    case "$1" in
        -h|--help)
            usage
            exit
            ;;
        -x|--no-x)
            gui="-nw"
            ;;
        --)
            # Remaining args (required; do not remove)
            shift
            rest=("$@")
            break
            ;;
    esac

    shift
done

# * Main

[[ -d $1 ]] && cd "$1"

emacs -q $gui \
      $(load_paths "${dependencies[@]}") \
      -l magit -f magit-status \
      --eval "(local-set-key \"q\" #'kill-emacs)" \
      -f delete-other-windows
