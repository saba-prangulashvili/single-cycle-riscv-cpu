#!/bin/bash

cd "$(dirname "$0")"

cd ../software
cat \
    kernel.s \
    > main.s


cd ../assembler
python3 assembler.py ../software/main.s

mv -f main.txt ../quartus_scc/main.txt