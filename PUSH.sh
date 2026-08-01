#!/usr/bin/env bash
# One-shot: initialise this folder as a git repo and push to GitHub.
# Run from inside the cold-recall folder:  ./PUSH.sh
set -euo pipefail

REMOTE="https://github.com/Hamza-Xoho/cold-recall.git"

[ -f README.md ] && [ -d skills ] || {
  echo "Run this from inside the cold-recall folder." >&2; exit 1; }

# regenerate the demo locally if it's missing (needs pillow)
if [ ! -f assets/demo.gif ]; then
  echo "assets/demo.gif missing — regenerating…"
  python3 assets/make_demo.py
fi

git init -b main 2>/dev/null || git init
git add -A
git commit -m "Initial release: cold-recall study system" || echo "nothing to commit"
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"
git branch -M main
git push -u origin main
echo
echo "Pushed → https://github.com/Hamza-Xoho/cold-recall"
