#!/usr/bin/env bash
# makepkg-goamd64.sh smudge|clean
# Detects x86-64 microarchitecture level for GOAMD64 in makepkg.conf
set -euo pipefail

case "$1" in
    smudge)
        level=$(/lib/ld-linux-x86-64.so.2 --help 2>/dev/null \
            | grep -oP 'x86-64-v\d(?= \(supported)' | sort -V | tail -1 \
            | sed 's/x86-64-//')
        sed "s/^GOAMD64=\"\"/GOAMD64=\"${level:-v1}\"/"
        ;;
    clean)
        sed 's/^GOAMD64="v[1-4]"/GOAMD64=""/'
        ;;
    *)
        cat
        ;;
esac
