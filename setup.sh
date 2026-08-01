#!/usr/bin/env bash
#
# cold-recall setup
#
# Creates your vault, points the skills at it, and (optionally) installs the
# skills for Claude Code. Safe to re-run — it never overwrites existing notes.
#
set -euo pipefail

BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
RED=$'\033[31m'; BLUE=$'\033[34m'; RESET=$'\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/build"

say()  { printf '%s\n' "$*"; }
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
die()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }
hdr()  { printf '\n%s%s%s\n' "$BOLD" "$*" "$RESET"; }

# Portable in-place substitution (BSD sed on macOS vs GNU sed on Linux differ).
subst() { # subst <token> <replacement> <file>
  local tmp; tmp="$(mktemp)"
  TOKEN="$1" REPL="$2" awk '
    { n = index($0, ENVIRON["TOKEN"])
      while (n > 0) {
        $0 = substr($0, 1, n-1) ENVIRON["REPL"] substr($0, n + length(ENVIRON["TOKEN"]))
        n = index($0, ENVIRON["TOKEN"])
      }
      print }
  ' "$3" > "$tmp" && mv "$tmp" "$3"
}

cat <<'BANNER'

  ┌─────────────────────────────────────────────┐
  │   cold-recall — setup                       │
  │   a study system that won't flatter you     │
  └─────────────────────────────────────────────┘

BANNER

command -v awk >/dev/null 2>&1 || die "awk not found. This script needs awk."

# ── 1. Where does the vault live? ────────────────────────────────────────────
hdr "1. Where should your vault live?"
say "${DIM}This is the Obsidian folder your notes are written into.${RESET}"
say "${DIM}Press Enter to accept the default.${RESET}"
printf '\n  Vault path [%s]: ' "$HOME/Documents/Brain"
read -r VAULT_INPUT || true
VAULT_PATH="${VAULT_INPUT:-$HOME/Documents/Brain}"

# Expand a leading ~ and resolve to an absolute path (MCP tools need absolute).
case "$VAULT_PATH" in
  "~/"*) VAULT_PATH="$HOME/${VAULT_PATH#\~/}" ;;
  "~")   VAULT_PATH="$HOME" ;;
esac
case "$VAULT_PATH" in
  /*) : ;;
  *)  VAULT_PATH="$(pwd)/$VAULT_PATH" ;;
esac
VAULT_PATH="${VAULT_PATH%/}"

case "$VAULT_PATH" in
  *__VAULT_PATH__*) die "That path contains the placeholder text. Pick a real folder." ;;
esac

say ""
ok "Vault will be: ${BOLD}$VAULT_PATH${RESET}"

# ── 2. Build the vault ───────────────────────────────────────────────────────
hdr "2. Creating vault folders"
for d in Concepts Methods Sources Maps Sessions Templates; do
  if [ -d "$VAULT_PATH/$d" ]; then
    say "  ${DIM}exists${RESET}  $d/"
  else
    mkdir -p "$VAULT_PATH/$d"
    say "  ${GREEN}created${RESET} $d/"
  fi
done

for t in concept session; do
  src="$REPO_DIR/vault-template/Templates/$t.md"
  dst="$VAULT_PATH/Templates/$t.md"
  [ -f "$src" ] || die "Missing $src — are you running this from inside the repo?"
  if [ -f "$dst" ]; then
    warn "Templates/$t.md already exists — left untouched."
  else
    cp "$src" "$dst"
    say "  ${GREEN}created${RESET} Templates/$t.md"
  fi
done
ok "Vault ready."

# ── 3. Point the skills at the vault ─────────────────────────────────────────
hdr "3. Preparing your personalised skills"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/skills/learning" "$BUILD_DIR/skills/anki"
cp "$REPO_DIR/skills/learning/SKILL.md" "$BUILD_DIR/skills/learning/SKILL.md"
cp "$REPO_DIR/skills/anki/SKILL.md"     "$BUILD_DIR/skills/anki/SKILL.md"
cp "$REPO_DIR/project-instructions.md"  "$BUILD_DIR/project-instructions.md"

for f in "$BUILD_DIR/skills/learning/SKILL.md" \
         "$BUILD_DIR/skills/anki/SKILL.md" \
         "$BUILD_DIR/project-instructions.md"; do
  subst "__VAULT_PATH__" "$VAULT_PATH" "$f"
done

# Verify no placeholder survived — a silent miss here breaks the whole system.
if grep -rq "__VAULT_PATH__" "$BUILD_DIR"; then
  grep -rn "__VAULT_PATH__" "$BUILD_DIR" >&2
  die "Placeholder substitution failed (see above). Please open an issue."
fi
ok "Skills point at your vault."

# ── 4. Install for Claude Code (optional) ────────────────────────────────────
hdr "4. Install skills for Claude Code?"
say "${DIM}Copies them into ~/.claude/skills/ so Claude Code picks them up.${RESET}"
say "${DIM}Say no if you only use Claude Desktop or claude.ai — see step 5.${RESET}"
printf '\n  Install to ~/.claude/skills/? [y/N]: '
read -r INSTALL_ANSWER || true

case "${INSTALL_ANSWER:-n}" in
  [Yy]*)
    mkdir -p "$HOME/.claude/skills"
    for s in learning anki; do
      if [ -d "$HOME/.claude/skills/$s" ]; then
        warn "~/.claude/skills/$s already exists."
        printf '    Overwrite it? [y/N]: '
        read -r OW || true
        case "${OW:-n}" in
          [Yy]*) rm -rf "$HOME/.claude/skills/$s" ;;
          *) say "    ${DIM}skipped${RESET}"; continue ;;
        esac
      fi
      mkdir -p "$HOME/.claude/skills/$s"
      cp "$BUILD_DIR/skills/$s/SKILL.md" "$HOME/.claude/skills/$s/SKILL.md"
      say "  ${GREEN}installed${RESET} ~/.claude/skills/$s/"
    done
    ok "Installed. Claude Code picks up skill changes without a restart."
    ;;
  *)
    say "  ${DIM}Skipped.${RESET}"
    ;;
esac

# ── 5. What's left ───────────────────────────────────────────────────────────
hdr "Done. Two things left, and they're manual:"
cat <<EOF

  ${BOLD}A. Your personalised files are in:${RESET}
     ${BLUE}$BUILD_DIR${RESET}

     • ${BOLD}build/project-instructions.md${RESET}
       Paste into your Claude Project's custom-instructions box.

     • ${BOLD}build/skills/${RESET}
       For claude.ai: zip each skill folder and upload it under
       Settings → Capabilities → Skills.
       For Claude Code: already done if you answered yes above.

  ${BOLD}B. Connect Obsidian + Anki${RESET}
     Follow ${BLUE}README.md § Setup${RESET} — it covers the filesystem
     connector (so Claude can read/write your vault) and the AnkiMCP
     add-on (so it can see your cards).

  ${BOLD}Then start a session by naming three things:${RESET}
     ${DIM}"Biology, ~/Resources/Bio/Topic 1, Molecules of Life"${RESET}

EOF
ok "Setup complete."
