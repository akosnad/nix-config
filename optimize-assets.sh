#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.svgo scour
set -o pipefail
set -o errexit

while read -r f; do
  echo optimizing "$f"...
  tmp=$(mktemp)
  scour --enable-viewboxing -i "$f" -o "$tmp"
  svgo -i "$tmp" -o "$f"
  rm "$tmp"
done <<<"$(find ./assets -type f -name '*.svg')"
