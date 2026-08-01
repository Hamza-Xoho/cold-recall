<div align="center">

# cold-recall

**A study system that refuses to flatter you.**

Claude runs the session. Obsidian keeps your understanding.
Anki keeps the rote. Nothing is marked *learned* until you produce it cold.

<img src="assets/demo.gif" alt="A session: read-back, cold retrieval, a wrong route caught, notes committed" width="780">

[Setup](#setup) · [How it works](docs/01-how-it-works.md) · [Daily use](docs/02-daily-use.md) · [Troubleshooting](docs/03-troubleshooting.md)

</div>

---

## The problem this solves

You finish a study session feeling like it went well. Three weeks later, on the exam, it turns out it didn't.

That gap has a specific cause: **feeling fluent is not the same as being able to produce something cold.** Re-reading a chapter, following a video, nodding at an explanation — all of it generates the sensation of learning while generating very little of the thing itself. Worse, when you ask an AI to teach you, the default failure mode is that it explains beautifully, you understand each sentence as it arrives, and you leave with nothing you can reconstruct unaided.

There's a second, quieter failure. In maths and physics, reasoning badly produces a wrong number and you get caught. In biology, medicine, history, law — **reasoning badly produces a right-sounding sentence and sails straight through.** You can arrive at "ice floats" via completely broken physics and nobody notices, least of all you.

cold-recall is built against both.

## What it actually is

Three small pieces of plain text, plus two apps you may already have:

| Piece | What it is | What it does |
|---|---|---|
| `learning` skill | one Markdown file | Runs the session: reads your vault, drills what's due, teaches, tests by retrieval, writes honest notes |
| `anki` skill | one Markdown file | Owns arbitrary facts only. Authors few, good cards; reads FSRS retention; repairs cards that keep failing |
| project instructions | one Markdown file | The standing contract Claude follows in every chat |

No server to run. No account to make. No code to maintain. **The whole system is prose that Claude reads.** That's deliberate — you can open any of it, disagree with it, and edit it in a text editor.

## The three ideas it's built on

**1. Two stores, strictly separated.**
Anything you can *rebuild from a mechanism* goes to Obsidian as a concept. Anything genuinely arbitrary — `-ectomy = surgical removal`, Avogadro's number, cranial nerve order — goes to Anki as a card. Never both, never the wrong one. Most AI flashcard tools happily card "how a buffer resists pH change," which converts understanding into rote and makes you worse. This system refuses. **A session that produces zero cards is a normal, correct outcome.**

**2. Status is earned, and it decays.**
A note is only `solid` once you've explained it back unaided or solved a representative problem cold. Re-*reading* a note updates `last_reviewed` and nothing else. And if a `solid` note hasn't been produced cold in longer than its interval, it's treated as decayed until you re-earn it. The vault is a confidence map, and a confidence map that lies to you is worse than none.

**3. The boring work runs first.**
Overdue items and due cards are drilled at the *start* of the session, cold, before anything new. The end of a session is where good intentions go to die.

## See it work

Real output, lightly trimmed. The learner gave a genuinely strong answer about why ice floats — and got caught anyway, because the route was broken.

<details open>
<summary><b>The session opens by reading, not teaching</b></summary>

> **Read-back before we start**
>
> **Vault state:** No Biology notes exist yet — Topic 1 is a clean slate. Physics has five notes, four `solid`, one still open.
>
> **One overdue loop from Physics:** `[[Significant Figures and Scientific Notation]]` is sitting at `learning (2)` with a cold check queued since 4 July — that's 8 days overdue.
>
> **Cross-link already waiting for us:** in the Physics unit-conversion work you used water's density as your sanity anchor. Today's material is the *reason* water behaves that way.

</details>

<details open>
<summary><b>It refuses to teach before it knows what's missing</b></summary>

> **Retrieval first — cold, no notes, no looking anything up.**
>
> I'm not teaching a thing until I know what's actually missing. **"I don't know" is a valid and useful answer** — a wrong guess dressed up as knowledge is the only thing that hurts here.
>
> A water molecule is one oxygen and two hydrogens. Describe what's going on *electrically* — then, from that description alone, derive as many consequences as you can. Why does sweating cool you? Why does ice float? I want the causal chain — *structure → property → consequence* — not a list of adjectives.

</details>

<details open>
<summary><b>The right answer, via the wrong route — caught</b></summary>

The learner said ice floats because *"at 0 °C, stronger hydrogen bonds can form."* Correct conclusion. Broken mechanism.

> No. And this one matters, because it means your model of what a hydrogen bond *is* has a hole in it.
>
> What physically determines the strength of a single hydrogen bond? The size of the δ⁻ and δ⁺ charges and the distance between them. **Does cooling the room change the electronegativity of oxygen?** Obviously not. **Bond strength is a property of the bond, not of the temperature.**
>
> So if the bonds don't get stronger, what actually changes when you cool water? You were one word away — you said it yourself and walked past it: *"the molecules are vibrating less."* Finish the thought.

Note what it does *not* do: it doesn't re-explain hydrogen bonding from scratch, and it doesn't accept the right answer. It isolates the exact broken link and hands it back.

</details>

<details open>
<summary><b>Then it commits — and it is not generous</b></summary>

> **7 files written.**
>
> | Note | Status | Why |
> |---|---|---|
> | `[[Hydrogen Bonding]]` | learning **(2)** | Keystone. Strength ratio landed; *what changes on cooling* was taught, not derived. |
> | `[[Properties of Water]]` | learning **(2)** | Solvent + evaporative cooling self-derived. Thermal buffering shaky. |
> | `[[Surface Tension and Pulmonary Surfactant]]` | learning **(1)** | Weakest note in the vault. Zero retrieval — you had it backwards, then said "I don't know." |
>
> **Nothing is `solid`.** That will look stingy given how well you reasoned today — and you *did* reason well. But every conclusion you reached unaided either arrived by a flawed route or sat next to a corrected error. **The vault is not going to flatter you.**
>
> **The pattern I logged:** in physics, a wrong route produces a wrong number and gets caught. In biology, a wrong route produces a right-sounding sentence and sails through. From here, retrieval in this subject asks for the **chain**, never the conclusion.

</details>

That last paragraph is the thing. It noticed a *failure pattern across subjects* and wrote it down, so the next session inherits it.

**[→ Read the full annotated session](examples/session-biology-molecules-of-life.md)**

---

# Setup

**About 20 minutes, once.** No coding experience assumed. If something fails, [docs/03-troubleshooting.md](docs/03-troubleshooting.md) has the fix.

## First: which Claude?

This determines the rest of the setup, so pick before you start.

| | **Claude Desktop** | **Claude Code** | **claude.ai (browser)** |
|---|---|---|---|
| Who it suits | **Most students — start here** | Comfortable in a terminal | Only if you can't install apps |
| Reads your vault | Yes, via a connector | Yes, built in | No — needs a tunnel |
| Talks to Anki | Yes | Yes | Only via a tunnel |
| Difficulty | Easy | Easy if you know the terminal | Hardest |

> **Recommended: Claude Desktop.** Obsidian and Anki both live on your computer, and Desktop can reach them directly. The browser version can't reach your own machine without tunnelling — real work with real security consequences, and out of scope here.

Everything below assumes **Claude Desktop**, and flags the differences for the other two.

---

## Step 1 — Obsidian

[Obsidian](https://obsidian.md) is a free notes app that stores everything as plain Markdown files in a normal folder on your computer. Nothing is locked in — if you ever stop using it, you still have your notes.

1. **Download and install [Obsidian](https://obsidian.md).** Free, no account needed.
2. Don't create a vault yet — Step 2 makes the folder for you.

> **Why Obsidian and not Notion/OneNote?** Two reasons. Its files are plain Markdown in a folder, which is what lets Claude read and write them directly. And it renders `[[wikilinks]]` and a graph view, which is what turns a pile of notes into a connected map of what you know.

---

## Step 2 — Get the files and run setup

Open a terminal (**Terminal** on macOS, **WSL** or **Git Bash** on Windows) and run:

```bash
git clone https://github.com/Hamza-Xoho/cold-recall.git
cd cold-recall
./setup.sh
```

<details>
<summary><b>No git installed? Click here</b></summary>

Click the green **Code → Download ZIP** button at the top of this page, unzip it, then open a terminal in that folder and run `./setup.sh`.

If `./setup.sh` says *permission denied*, run `chmod +x setup.sh` first.

</details>

The script asks **where your vault should live.** Press Enter for the default (`~/Documents/Brain`) or type your own path. It then:

- creates the vault folders and note templates
- writes your vault path into the skills
- optionally installs the skills for Claude Code

It's safe to re-run and it never overwrites existing notes.

**Write down the full vault path it prints** — e.g. `/Users/yourname/Documents/Brain`. You'll need it twice more.

Now in **Obsidian: Open folder as vault** → choose that folder. You should see `Concepts`, `Methods`, `Sources`, `Maps`, `Sessions`, `Templates`.

<details>
<summary><b>Doing it by hand instead of running the script</b></summary>

Create those six folders yourself, copy `vault-template/Templates/concept.md` and `session.md` into `Templates/`, then open `skills/learning/SKILL.md`, `skills/anki/SKILL.md` and `project-instructions.md` and replace every `__VAULT_PATH__` with your vault's **full, absolute** path. Four occurrences in total.

</details>

---

## Step 3 — Let Claude read and write your vault

Claude can't touch your files until you allow it. This is the **filesystem connector**.

### Claude Desktop

The easiest route is a **desktop extension**, which installs a local connector without editing any config files. Open **Settings → Extensions**, find a filesystem / file-access extension, install it, and **choose your vault folder** when prompted.

<details>
<summary><b>No extension available? Manual setup (5 min)</b></summary>

1. Install **[Node.js](https://nodejs.org)** (the LTS version) if you don't have it. Check with `node --version`.

2. In Claude Desktop: **Settings → Developer → Edit Config**. That opens `claude_desktop_config.json`.
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`

3. Paste this, replacing the path with **your vault path**:

   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-filesystem",
           "/Users/yourname/Documents/Brain"
         ]
       }
     }
   }
   ```

   > If the file already has an `"mcpServers"` section, add `"filesystem"` **inside** it. Two `mcpServers` keys is invalid JSON and Claude will silently fail to start.

4. **Fully quit Claude Desktop** — `Cmd+Q` on macOS, or quit from the tray on Windows. Closing the window is not enough; the config only loads at startup. Reopen it.

5. **Check it.** Open the connectors menu near the message box and confirm `filesystem` is listed. Or just ask Claude: *"List the folders in my vault."*

</details>

> ⚠️ **The filesystem connector can write and overwrite files.** Point it at your vault, not your whole home folder. Obsidian vaults are plain Markdown, so back yours up with git, iCloud, Dropbox, or Obsidian Sync.

### Claude Code

Nothing to do — it already reads and writes files in directories you give it. Start it in or above your vault, or pass `--add-dir /path/to/your/vault`.

### claude.ai in the browser

The browser can't reach your computer. **Use Claude Desktop instead.**

---

## Step 4 — Connect Anki *(optional but recommended)*

Skip this if you don't use flashcards. Everything else still works; the system just won't card anything and will say so.

[Anki](https://apps.ankiweb.net/) is a free spaced-repetition flashcard app. It schedules reviews using **FSRS**, an algorithm that models how fast you forget each individual card — which is what lets this system read *real* retention instead of guessing.

1. **Install [Anki](https://apps.ankiweb.net/)** — version **25.07 or newer**. Check under **Help → About**.

2. **Install the AnkiMCP add-on.** In Anki: **Tools → Add-ons → Get Add-ons…** and enter this code:

   ```
   124672614
   ```

3. **Restart Anki.** The add-on runs a small local server automatically whenever Anki is open, at `http://127.0.0.1:3141/`. On first launch it downloads a ~2 MB dependency, so give it a moment.

4. **Check it:** **Tools → AnkiMCP Server Settings…** should show it running.

5. **Tell Claude Desktop about it.** Reopen the config file from Step 3 and add an `anki` entry *alongside* `filesystem`:

   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/yourname/Documents/Brain"]
       },
       "anki": {
         "url": "http://127.0.0.1:3141/"
       }
     }
   }
   ```

6. **Fully quit and reopen Claude Desktop.**

> **Anki must be running** for any card operation. If it's closed, the connection fails — that's expected, not a bug.

<details>
<summary><b>Optional: trim the add-on's tool list</b></summary>

The add-on exposes 27 tools; this system uses about a third, and the rest cost context on every message. In **Tools → Add-ons → AnkiMCP Server → Config**, the `disabled_tools` list given in [`skills/anki/SKILL.md`](skills/anki/SKILL.md) turns off the ones that never get used. Purely an optimisation — skip it if you're not sure.

</details>

<details>
<summary><b>Using Anki with claude.ai in the browser</b></summary>

The add-on is tunnel-friendly (Cloudflare Tunnel, ngrok), so it *can* be reached from the browser. If you go this route, set a secret `http_path` in the add-on config and keep the media-hardening defaults — **never expose the root endpoint openly.** Details in [`skills/anki/SKILL.md`](skills/anki/SKILL.md).

</details>

---

## Step 5 — Create the Claude Project and load the skills

### 5a. The project

In Claude Desktop or claude.ai, create a **new Project** — call it *Learning*, or anything.

Open its **custom instructions** box and paste the entire contents of **`build/project-instructions.md`** — the version `setup.sh` generated, with your real vault path in it. *Not* the one in the repo root, which still has the placeholder.

Check the path in §1 is actually yours before saving.

### 5b. The two skills

**Claude Code** — done already if you answered *yes* during setup. Otherwise:

```bash
mkdir -p ~/.claude/skills
cp -r build/skills/learning ~/.claude/skills/
cp -r build/skills/anki     ~/.claude/skills/
```

Claude Code watches these folders and picks up changes without a restart. Run `/skills` to confirm both are listed.

**Claude Desktop / claude.ai** — skills upload as `.zip` files:

```bash
cd build/skills
zip -r learning.zip learning
zip -r anki.zip anki
```

Then in Claude's **Settings**, find the **Skills** section (under Capabilities or Features, depending on your version) and upload both zips. They're available in your conversations immediately.

<details>
<summary><b>Can't find the Skills section?</b></summary>

Your plan or app version may not expose it yet — check [Anthropic's skills documentation](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) for the current location.

**Fallback that always works:** paste the contents of both `SKILL.md` files into the project's custom instructions, underneath the project instructions. Less elegant and it spends context every turn, but it works fine.

</details>

---

## Step 6 — Verify, then start

Ask Claude, inside your project:

> Check your setup: list the folders in my vault, read `Templates/concept.md`, and tell me how many Anki cards are due today.

| Result | Means |
|---|---|
| Folders listed | Filesystem connector works |
| Template read back | Vault path is correct |
| Due count returned | Anki works *(Anki must be open)* |
| Mentions read-back or the standing loop | Skills and instructions loaded |

Anything failing → **[docs/03-troubleshooting.md](docs/03-troubleshooting.md)**

### Your first session

Open a new chat **inside the project** and name three things — subject, where the material lives, today's topic:

```
Biology, ~/Resources/Bio/Topic 1, Molecules of Life
```

That's the whole interface. No commands, no slash prefixes.

**What should happen:** Claude reads your vault (empty on day one, so it'll say so), reads your source material, and then asks you to answer questions **cold, before it teaches anything.**

**That's the system working.** Resisting the urge to be taught first is the entire point. "I don't know" is a genuinely useful answer; a confident guess is the only one that costs you.

**→ [docs/02-daily-use.md](docs/02-daily-use.md)** for how to run sessions well.

---

## What ends up in your vault

```
Brain/
├── Concepts/     # one note per idea — your words, your errors, your click-moments
├── Methods/      # procedures you execute rather than explain
├── Sources/      # what you learned it from
├── Maps/         # per-subject index notes
├── Sessions/     # a log per session: what stuck, what didn't, where you stopped
└── Templates/    # the note skeletons
```

A concept note records **your understanding, the precise version, where you got corrected, what made it click, and what's still fuzzy.** The middle three are the ones no textbook contains — and they're what makes revision two months later actually work.

Notes link *downward* to the foundations they rest on, including foundations you haven't studied yet. An unresolved `[[Electronegativity]]` link is a real signal: something you're confident about is standing on something you've never derived. The system surfaces those.

## Honest limitations

- **It's opinionated about pedagogy.** Cold retrieval, spaced review, honest grading. If you want a study buddy that tells you you're doing great, this is the wrong repo.
- **It is slower than reading the chapter.** That's the trade. Retrieval practice feels worse and works better; this is [a well-replicated finding](https://en.wikipedia.org/wiki/Testing_effect), not a design preference.
- **Setup has real friction.** Budget 20 minutes once.
- **Anki must be running** for card operations. If it's closed, the session continues and notes the gap.
- **Long sessions get expensive in context.** One topic per chat is the intended rhythm, and it's also better spacing.
- **It can still be wrong about your subject.** It's Claude with good instructions, not an oracle. The vault records *your* reasoning so you can catch it later — use that.

## Adapting it

Everything is prose. To change the system, edit the prose:

- **Different subject?** Nothing is subject-specific. Tested on biology, physics, chemistry and medical terminology; law, languages and history fit the same loop.
- **Not studying for an exam?** Delete `exam_weight` from the template.
- **Don't want automatic flashcards?** Add *"propose first"* to your project instructions.
- **Different review spacing?** The intervals live in one section of `skills/learning/SKILL.md` — change the numbers.
- **Hate a rule?** Delete it. It's your file.

**→ [docs/04-adapting.md](docs/04-adapting.md)**

## Documentation

| | |
|---|---|
| **[Setup](#setup)** | ↑ above |
| **[01 — How it works](docs/01-how-it-works.md)** | The design rationale, and why each rule exists |
| **[02 — Daily use](docs/02-daily-use.md)** | Running sessions, reviews, and what to say |
| **[03 — Troubleshooting](docs/03-troubleshooting.md)** | When Claude can't see your vault or Anki |
| **[04 — Adapting](docs/04-adapting.md)** | Making it yours |
| **[Example session](examples/session-biology-molecules-of-life.md)** | An annotated real transcript |

## Contributing

Issues and PRs welcome — especially **transcripts from subjects this hasn't been tested on.** The pedagogy is generic in principle; real sessions in law, languages or the humanities are the fastest way to find where it isn't. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Credits

Built on [Anthropic's Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview), [Obsidian](https://obsidian.md), [Anki](https://apps.ankiweb.net/), and the [AnkiMCP add-on](https://github.com/ankimcp/anki-mcp-server-addon).

The pedagogy is standard cognitive science, not invention: retrieval practice, spaced repetition, the [Feynman technique](https://en.wikipedia.org/wiki/Learning_by_teaching), and desirable difficulty. The contribution here is wiring them into a loop that runs without willpower.

## License

MIT — see [LICENSE](LICENSE). Take it, fork it, make it yours.
