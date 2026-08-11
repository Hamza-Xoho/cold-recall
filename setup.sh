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

# Git Bash reports /c/Users/... but Claude and its connectors need C:\Users\...
# We keep the Unix form for our own file operations and hand the native form to
# anything Claude will read. See README § Part 5.
IS_WINDOWS=0
case "$(uname -s 2>/dev/null || echo unknown)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac

to_native() { # /c/Users/x  ->  C:\Users\x   (identity everywhere but Git Bash)
  if [ "$IS_WINDOWS" -eq 1 ]; then
    printf '%s' "$1" | awk '
      { if (match($0, /^\/[A-Za-z]\//)) {
          drive = toupper(substr($0, 2, 1))
          $0 = drive ":" substr($0, 3)
        }
        gsub(/\//, "\\")
        print }'
  else
    printf '%s' "$1"
  fi
}

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g'; }

# ── 1. Where does the vault live? ────────────────────────────────────────────
hdr "1. Where should your vault live?"
say "${DIM}This is the folder Obsidian opens as your vault, and the same folder${RESET}"
say "${DIM}you pointed the filesystem connector at in README Part 2a.${RESET}"
say "${DIM}Press Enter to accept the default.${RESET}"

while :; do
  printf '\n  Vault path [%s]: ' "$HOME/Documents/Brain"
  read -r VAULT_INPUT || true
  VAULT_PATH="${VAULT_INPUT:-$HOME/Documents/Brain}"

  # Accept a Windows-style path too, and convert it back for shell use.
  case "$VAULT_PATH" in
    [A-Za-z]:[/\\]*)
      DRIVE="$(printf '%s' "${VAULT_PATH%%:*}" | tr 'A-Z' 'a-z')"
      VAULT_PATH="/$DRIVE$(printf '%s' "${VAULT_PATH#?:}" | tr '\\' '/')"
      ;;
  esac

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
    *__VAULT_PATH__*)
      warn "That path contains the placeholder text. Type a real folder."
      continue ;;
    "$HOME"|/)
      warn "Refusing to use your whole home folder as a vault. Pick a subfolder."
      continue ;;
    "$REPO_DIR"|"$REPO_DIR"/*)
      warn "Don't put the vault inside the cold-recall repo — it'll get mixed up"
      warn "with the project's own files. Pick somewhere like ~/Documents/Brain."
      continue ;;
  esac

  # A folder that doesn't exist is usually a typo, because README Part 2a had
  # you create it already. Creating it silently is how people end up with a
  # connector pointing at one folder and notes written into another.
  if [ ! -d "$VAULT_PATH" ]; then
    say ""
    warn "That folder does not exist yet:"
    say "    $(to_native "$VAULT_PATH")"
    say "${DIM}  If you already made it in README Part 2a, you've likely mistyped it.${RESET}"
    say "${DIM}  Check the exact path, or say y to create it here.${RESET}"
    printf '\n  Create it? [y/N]: '
    read -r MK || true
    case "${MK:-n}" in
      [Yy]*) mkdir -p "$VAULT_PATH" || die "Could not create $VAULT_PATH" ;;
      *)     say "  ${DIM}Let's try again.${RESET}"; continue ;;
    esac
  fi

  break
done

VAULT_NATIVE="$(to_native "$VAULT_PATH")"
VAULT_JSON="$(json_escape "$VAULT_NATIVE")"

say ""
ok "Vault will be: ${BOLD}$VAULT_NATIVE${RESET}"

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
  subst "__VAULT_PATH__" "$VAULT_NATIVE" "$f"
done

# Verify no placeholder survived — a silent miss here breaks the whole system.
if grep -rq "__VAULT_PATH__" "$BUILD_DIR"; then
  grep -rn "__VAULT_PATH__" "$BUILD_DIR" >&2
  die "Placeholder substitution failed (see above). Please open an issue."
fi
ok "Skills point at your vault."

# ── 4. Zip the skills for upload ─────────────────────────────────────────────
# Claude Desktop / claude.ai take skills as .zip. Doing it here saves the user a
# command they'd otherwise have to get exactly right (zip the folder, not the
# SKILL.md inside it).
hdr "4. Packaging skills for upload"
ZIPS_READY=0
if command -v zip >/dev/null 2>&1; then
  ( cd "$BUILD_DIR/skills" && zip -qr learning.zip learning && zip -qr anki.zip anki )
  ZIPS_READY=1
  say "  ${GREEN}created${RESET} build/skills/learning.zip"
  say "  ${GREEN}created${RESET} build/skills/anki.zip"
  ok "Ready to upload."
else
  warn "No 'zip' command found — you'll zip the two folders by hand."
  say "${DIM}  In your file manager, open build/skills/, then compress the${RESET}"
  say "${DIM}  'learning' and 'anki' FOLDERS (not the SKILL.md files inside).${RESET}"
fi

# ── 5. Install for Claude Code (optional) ────────────────────────────────────
hdr "5. Install skills for Claude Code?"
say "${DIM}Copies them into ~/.claude/skills/ so Claude Code picks them up.${RESET}"
say "${DIM}Say no if you use Claude Desktop — the .zip files above are for you.${RESET}"
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

# ── 6. Check the parts you set up before running this ────────────────────────
# README Parts 2–4 (connectors, Obsidian, Anki) happen before this script. This
# section reports on them so a mistake there surfaces now rather than mid-session.
hdr "6. Checking Parts 2–4"

case "$(uname -s 2>/dev/null || echo unknown)" in
  Darwin) CLAUDE_CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json" ;;
  MINGW*|MSYS*|CYGWIN*) CLAUDE_CFG="$HOME/AppData/Roaming/Claude/claude_desktop_config.json" ;;
  *) CLAUDE_CFG="$HOME/.config/Claude/claude_desktop_config.json" ;;
esac

NEED_FS=1; NEED_ANKI=1; NEED_OBSIDIAN=1

# Obsidian writes a .obsidian/ folder the first time it opens a folder as a vault.
if [ -d "$VAULT_PATH/.obsidian" ]; then
  ok "Obsidian has opened this folder as a vault. ${DIM}(Part 3)${RESET}"
  NEED_OBSIDIAN=0
else
  warn "Obsidian hasn't opened this folder yet. ${DIM}(Part 3)${RESET}"
fi

if [ -f "$CLAUDE_CFG" ]; then
  if grep -qF "$VAULT_JSON" "$CLAUDE_CFG" 2>/dev/null; then
    ok "Claude's filesystem connector points at this vault. ${DIM}(Part 2)${RESET}"
    NEED_FS=0
  else
    warn "Claude's config exists but does not mention this vault path. ${DIM}(Part 2)${RESET}"
    say "${DIM}  If you used a one-click filesystem extension instead, ignore this.${RESET}"
    say "${DIM}  Otherwise the connector and your notes point at different folders.${RESET}"
  fi
  if grep -qF '3141' "$CLAUDE_CFG" 2>/dev/null; then
    ok "Claude's config has an Anki entry. ${DIM}(Part 4)${RESET}"
    NEED_ANKI=0
  else
    warn "No Anki entry in Claude's config. ${DIM}(Part 4 — fine if you skipped Anki)${RESET}"
  fi
else
  warn "No Claude Desktop config found at:"
  say  "    $CLAUDE_CFG"
  say  "${DIM}  Expected if you use Claude Code, or a one-click extension.${RESET}"
fi

# The Anki add-on's server only runs while Anki is open.
if command -v curl >/dev/null 2>&1; then
  if curl -fsS --max-time 2 "http://127.0.0.1:3141/" >/dev/null 2>&1; then
    ok "Anki is running and reachable on port 3141."
  else
    say "  ${DIM}Anki isn't answering on port 3141 — it just needs to be open.${RESET}"
  fi
fi

command -v node >/dev/null 2>&1 || warn "Node.js not found — the filesystem connector needs it (README Part 2b)."

# ── 7. What's left ───────────────────────────────────────────────────────────
hdr "Done. Here's exactly what's left:"
cat <<EOF

  ${BOLD}1. Paste your project instructions${RESET}  ${DIM}(README Part 6a)${RESET}
     In Claude: Projects → your project → custom instructions.
     Open this file and copy ALL of it:

       ${BLUE}$BUILD_DIR/project-instructions.md${RESET}

     ${DIM}Use that file, not the one in the repo root — the root copy${RESET}
     ${DIM}still has the __VAULT_PATH__ placeholder in it.${RESET}
EOF

if [ "$ZIPS_READY" -eq 1 ]; then
cat <<EOF

  ${BOLD}2. Upload the two skills${RESET}  ${DIM}(README Part 6b)${RESET}
     In Claude: Customize → Skills → + → Create skill → Upload a skill.
     Upload each of these:

       ${BLUE}$BUILD_DIR/skills/learning.zip${RESET}
       ${BLUE}$BUILD_DIR/skills/anki.zip${RESET}

     ${DIM}No "Upload a skill" option? Turn on Settings → Capabilities →${RESET}
     ${DIM}"Code execution and file creation" first. (README Part 1c)${RESET}
EOF
else
cat <<EOF

  ${BOLD}2. Zip and upload the two skills${RESET}  ${DIM}(README Part 6b)${RESET}
     Compress these two FOLDERS, then upload each .zip in Claude under
     Customize → Skills → + → Create skill → Upload a skill:

       ${BLUE}$BUILD_DIR/skills/learning${RESET}
       ${BLUE}$BUILD_DIR/skills/anki${RESET}
EOF
fi

if [ "$NEED_FS" -eq 1 ] || [ "$NEED_ANKI" -eq 1 ] || [ "$NEED_OBSIDIAN" -eq 1 ]; then
  say ""
  say "  ${BOLD}${YELLOW}3. Unfinished from earlier parts${RESET}"
  if [ "$NEED_FS" -eq 1 ];       then say "     • Point Claude's filesystem connector at your vault ${DIM}(Part 2)${RESET}"; fi
  if [ "$NEED_OBSIDIAN" -eq 1 ]; then say "     • Obsidian → Open folder as vault → this folder ${DIM}(Part 3)${RESET}"; fi
  if [ "$NEED_ANKI" -eq 1 ];     then say "     • Add the Anki connector, or skip Anki deliberately ${DIM}(Part 4)${RESET}"; fi
  say ""
  say "     ${DIM}Your vault path, ready to paste:${RESET}"
  say "     ${BLUE}$VAULT_NATIVE${RESET}"
  say "     ${DIM}Inside the JSON config file it must look like this:${RESET}"
  say "     ${BLUE}\"$VAULT_JSON\"${RESET}"
fi

cat <<EOF

  ${BOLD}After any config change: fully QUIT Claude Desktop and reopen it.${RESET}
  ${DIM}Cmd+Q on macOS, tray icon → Quit on Windows. Closing the window${RESET}
  ${DIM}is not enough — this is the #1 reason setup appears not to work.${RESET}

  ${BOLD}Then verify${RESET} ${DIM}(README Part 7)${RESET} — ask Claude, inside your project:
     ${DIM}"List the folders in my vault and read Templates/concept.md"${RESET}

  ${BOLD}Then start a session by naming three things:${RESET}
     ${DIM}"Biology, ~/Resources/Bio/Topic 1, Molecules of Life"${RESET}

  ${DIM}Stuck? docs/03-troubleshooting.md${RESET}

EOF
ok "Setup complete."
