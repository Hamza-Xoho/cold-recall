# Troubleshooting

---

## Claude says it can't access my files

**Symptom:** *"I don't have the ability to access your file system."*

Work through these in order:

1. **Did you fully quit Claude Desktop?** Closing the window isn't enough — the config only loads at startup. `Cmd+Q` on macOS; quit from the tray on Windows. This is by far the most common cause.

2. **Is the connector actually listed?** Open the connectors menu near the message box. If `filesystem` isn't there, the config didn't load.

3. **Is your JSON valid?** One misplaced comma kills it silently. Paste the file into [jsonlint.com](https://jsonlint.com). The classic error is two separate `"mcpServers"` blocks — there must be exactly one, with all servers inside it.

4. **Is the path absolute and real?**
   - ✅ `/Users/yourname/Documents/Brain`
   - ❌ `~/Documents/Brain` — tilde often isn't expanded
   - ❌ `Documents/Brain` — relative paths fail
   - Check for typos: `cd "/Users/yourname/Documents/Brain" && ls`

5. **Is Node.js installed?** The filesystem server needs it. `node --version` should print something.

6. **Sometimes it just needs a nudge.** The connector can be connected while Claude still says it's sandboxed. Try: *"You have a filesystem connector — use it to list my vault folders."*

---

## Claude can't see Anki

1. **Is Anki actually open?** The server lives inside Anki. Closed Anki, no connection.
2. **Is the add-on installed?** Anki → **Tools → Add-ons** should list AnkiMCP Server. Reinstall with code `124672614` if not.
3. **Is it running?** **Tools → AnkiMCP Server Settings…** shows status. On first launch it downloads a small dependency — give it a minute and restart Anki.
4. **Is Anki new enough?** Needs **25.07+**. Check **Help → About**.
5. **Is it in Claude's config?** There must be an `"anki"` entry with `"url": "http://127.0.0.1:3141/"`, then a full restart of Claude.
6. **Port conflict?** If something else uses 3141, change it in the add-on config and update Claude's config to match.

---

## The session doesn't follow the loop

**Symptom:** it just explains the topic, without read-back or cold retrieval.

- **Are you inside the Project?** Skills and instructions only apply within it. A chat outside the project is a normal chat.
- **Did the project instructions actually save?** Reopen the settings and confirm the text is there.
- **Are the skills loaded?** Claude Code: `/skills`. Desktop/web: check the Skills section in Settings.
- **Did you name all three things?** "Teach me biology" is vague enough to get a generic answer. Subject + material + topic triggers it reliably.
- **Nuclear option:** paste both `SKILL.md` files directly into the project's custom instructions. Uses context every turn, but it always works.

---

## It's writing notes to the wrong place

The vault path is written in **three** places. If you moved your vault, fix all of them:

```bash
grep -rn "Documents/Brain" ~/.claude/skills/learning/SKILL.md ~/.claude/skills/anki/SKILL.md
```

Plus your project instructions in the Claude UI. Or just re-run `./setup.sh` with the new path and re-paste.

---

## It created a duplicate note

The skill reconciles by title, so duplicates usually mean a **title mismatch** — `Hydrogen Bonding` vs `Hydrogen Bonds`. Merge them by hand in Obsidian, keep one title, and tell Claude which is canonical.

Also check the note is in `Concepts/` or `Methods/`. Notes elsewhere may not be found on read-back.

---

## Empty notes appearing at my vault root

Obsidian auto-creates a file when you click an unresolved `[[link]]`. Those links are *meant* to stay unresolved — they mark foundations you haven't studied.

Delete the empty file. Don't click links for concepts you haven't learned yet.

---

## It's making too many cards

It shouldn't — the boundary test is strict and most sessions correctly produce zero. If it's over-carding:

- Add **"propose first"** to your project instructions to require approval.
- Ask: *"Justify each of these cards against the boundary test."* Anything derivable should be pulled.
- Delete freely. Over-carding is a failure, not productivity.

---

## It's making too few cards

Usually correct — most material *is* derivable. But if you're studying genuinely arbitrary content (terminology, drug stems, dates) and getting nothing, say so explicitly:

```
This topic is mostly arbitrary terminology. Diagnose it as factual and card the atoms.
```

---

## It's grading me too harshly

Read [docs/02-daily-use.md § When it feels too harsh](02-daily-use.md#when-it-feels-too-harsh) first — usually the grade is right and the reason is specific. Ask `why is this only learning?` and judge the evidence.

If you want a genuinely different standard, edit the status ladder in `skills/learning/SKILL.md`. Don't argue Claude into inflating individual notes; that quietly turns the map back into a diary.

---

## Sessions run out of context

- **One topic per chat.** Long sessions degrade.
- **Point at narrower material** — a topic, not a whole folder.
- **Commit early:** *"Commit what we have so far, then continue."* Written notes survive the chat ending.

---

## Still stuck?

[Open an issue](https://github.com/Hamza-Xoho/cold-recall/issues) with: your OS, which Claude surface (Desktop/Code/web), what you expected, what happened, and the relevant chunk of your config with personal paths removed.
