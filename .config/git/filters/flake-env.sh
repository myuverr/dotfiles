#!/usr/bin/env bash
# flake-env.sh smudge|clean
# Detects system/username for flake.nix (repo stores empty, worktree fills local values)
set -euo pipefail

detect_nix_system() {
    local sys
    if sys=$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null); then
        case "$sys" in
            *-linux) echo "$sys" && return ;;
        esac
    fi
    case "$(uname -m)" in
        i?86) echo i686-linux ;;
        ppc64le | powerpc64le) echo powerpc64le-linux ;;
        *) echo "$(uname -m)-linux" ;;
    esac
}

case "$1" in
    smudge)
        sys=$(detect_nix_system)
        user=$(whoami)
        sed -e 's/^\(\s*system = "\)[^"]*\("\);/\1'"$sys"'";/' \
            -e 's/^\(\s*username = "\)[^"]*\("\);/\1'"$user"'";/'
        ;;
    clean)
        sed -e 's/^\(\s*system = "\)[^"]*\("\);/\1\2;/' \
            -e 's/^\(\s*username = "\)[^"]*\("\);/\1\2;/'
        ;;
    *)
        cat
        ;;
esac
