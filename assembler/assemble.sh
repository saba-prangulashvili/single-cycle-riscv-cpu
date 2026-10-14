#!/bin/bash
set -e

cd "$(dirname "$0")"

{
    cat ../software/start.s
    echo
    for f in ../software/*.s; do
        [ "$f" = "../software/start.s" ] && continue
        cat "$f"
        echo
    done
} > main.s

python3 assembler.py main.s
rm -f main.s

mv -f main.txt ../quartus_scc/main.txt