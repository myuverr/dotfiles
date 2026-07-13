#!/usr/bin/env bash
# smudge-merge.sh <local-file-path>
# Repo content from stdin + local file → deep merge (repo wins)
set -euo pipefail

LOCAL="$1"
REPO=$(cat)

if [ -f "$LOCAL" ]; then
    jq -n --argjson repo "$REPO" --slurpfile local "$LOCAL" '
        def rmerge(a; b):
            if   a == null then b
            elif b == null then a
            elif (a|type == "object") and (b|type == "object") then
                reduce (b|keys_unsorted[]) as $k (a; .[$k] = rmerge(.[$k]; b[$k]))
            elif (a|type == "array") and (b|type == "array") then
                (a + b) | unique
            else b end;
        rmerge($local[0]; $repo)'
else
    echo "$REPO"
fi
