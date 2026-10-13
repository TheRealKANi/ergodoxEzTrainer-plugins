#!/usr/bin/env bash
# Copyright (C) 2026 TheRealKANi · SPDX-License-Identifier: GPL-3.0-or-later
#
# Pack every plugin in src/ that has a new version, write index.toml, and sign it all.
#   ./release.sh
# Needs: ergodoxEzTrainer (or $EZTRAINER), minisign, python3, and the secret key
# ($MINISIGN_KEY, default ~/.minisign/ergodoxEzTrainer.key). Commit and push yourself.
#
# A released zip is never rebuilt: change a plugin -> raise its version in plugin.toml.
set -euo pipefail
cd "$(dirname "$0")"

EZ="${EZTRAINER:-ergodoxEzTrainer}"
KEY="${MINISIGN_KEY:-$HOME/.minisign/ergodoxEzTrainer.key}"
command -v "$EZ" >/dev/null || { echo "ergodoxEzTrainer not found (set EZTRAINER=/path/to/ergodoxEzTrainer)" >&2; exit 1; }
command -v minisign >/dev/null || { echo "minisign not found (pacman -S minisign)" >&2; exit 1; }
[[ -f "$KEY" ]] || { echo "secret key not found: $KEY (make one: minisign -G -p minisign.pub -s $KEY)" >&2; exit 1; }
[[ -f minisign.pub ]] || { echo "minisign.pub missing next to repo.toml" >&2; exit 1; }
grep -q "$(sed -n 2p minisign.pub)" repo.toml || { echo "repo.toml public_key is not the key in minisign.pub" >&2; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p plugins
new=()

# same plugin inside two zips? (file names and contents, not zip timestamps)
same_zip() {
  python3 - "$1" "$2" <<'PY'
import sys, zipfile
a, b = (zipfile.ZipFile(p) for p in sys.argv[1:3])
ca = {n: a.read(n) for n in a.namelist() if not n.endswith("/")}
cb = {n: b.read(n) for n in b.namelist() if not n.endswith("/")}
sys.exit(0 if ca == cb else 1)
PY
}

for dir in src/*/; do
  dir="${dir%/}"
  "$EZ" plugin check "$dir"
  "$EZ" plugin pack "$dir" -o "$tmp/out.zip" >/dev/null
  id="$(sed -n 's/^id *= *"\(.*\)"/\1/p' "$dir/plugin.toml" | head -1)"
  ver="$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$dir/plugin.toml" | head -1)"
  zip="plugins/$id-$ver.zip"
  if [[ -f "$zip" ]]; then
    same_zip "$zip" "$tmp/out.zip" || { echo "$dir changed, but $zip is already released: raise the version in $dir/plugin.toml" >&2; exit 1; }
    continue
  fi
  mv "$tmp/out.zip" "$zip"
  new+=("$zip")
  echo "new: $zip"
done

"$EZ" plugin index . >/dev/null
if [[ ${#new[@]} -eq 0 ]] && [[ -f index.toml.minisig ]] && minisign -Vq -p minisign.pub -m index.toml 2>/dev/null; then
  echo "Nothing new to release."
  exit 0
fi
echo "Signing ${#new[@]} new zip(s) and index.toml (one passphrase prompt)"
minisign -S -s "$KEY" -m "${new[@]}" index.toml

for f in "${new[@]}" index.toml; do
  minisign -Vq -p minisign.pub -m "$f"
done
echo "Done. Review with lazygit, commit and push."
