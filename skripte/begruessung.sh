#!/bin/bash
# Linux CI — Beispielcode, MIT (siehe LICENSE-CODE.txt)

NAME="$1"

if [ -z "$NAME" ]; then
  NAME="Unbekannt"
fi

echo "Hallo, $NAME!"
echo "Heute ist $(date +%A)."

echo "Ich zähle bis 3:"
for i in 1 2 3; do
  echo "  -> $i"
done
