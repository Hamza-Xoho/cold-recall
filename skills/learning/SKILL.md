---
name: learning
description: "Run a structured learning session over source material and maintain the permanent, cross-domain Obsidian second brain at __VAULT_PATH__. Use whenever the user is learning, studying, revising, or being taught a topic and wants it retained and linked in the vault. Triggers on \"let's learn\", \"teach me\", \"study session\", \"revise\", or naming a subject + resource folder. Coordinates with the `anki` skill: derivable understanding goes to the vault, arbitrary must-know atoms are harvested to Anki automatically."
---

# Learning Session Skill

Runs a session that (1) teaches the material with the pedagogy that fits it, (2) confirms learning by retrieval, and (3) writes reconciled, honest notes into the Obsidian vault so a **single permanent graph across all subjects and all time** grows with every session — while (4) harvesting any genuinely arbitrary atoms into Anki as it goes, without being asked.

- **Vault root:** `__VAULT_PATH__`
- **Folders:** `/Concepts` `/Methods` `/Sources` `/Maps` `/Sessions` `/Library`
- **Library:** source PDFs (textbooks, papers). Never read whole — addressed by page range via that book's map note in `/Maps`. Keeping PDFs inside the vault is what makes `source_ref` clickable from a concept note straight through to the page.
- **Templates:** `/Templates/concept.md`, `/Templates/session.md`, `/Templates/textbook-map.md`
- **Anki:** the `anki` skill owns arbitrary/factual atoms via the AnkiMCP server. **This skill invokes it automatically — when any trigger below fires, read the `anki` SKILL.md and follow it rather than improvising Anki actions from memory.** No slash and no explicit request from the user is needed. Auto-invoke the `anki` skill when:
  - Step 1 diagnoses today's material as arbitrary/factual;
  - the atom watch harvests genuine must-know atoms at commit (Step 3.6);
  - read-back needs Anki due-count or retrievability state (Step 0);
  - the user asks anything card-related mid-session — make/refine cards, what's due, quiz me on X, a card keeps failing.

This is not exam-scoped. It is one lifelong vault. A concept studied for one purpose (e.g. fluid physics for an entrance exam) must connect to the same phenomenon met later in another domain (e.g. the physiology of blood flow). **Making those non-obvious cross-subject connections is a primary goal of this skill, not a bonus.**

## The non-negotiables (why this skill exists)
1. **Reconcile, don't duplicate.** Always search before writing; update the existing note, never spawn a second. This spans both stores: an atom is never in both the vault and Anki — derivable → vault, arbitrary → Anki.
2. **Capture the user's understanding, not the textbook.** The distinctive value is *their* explanation, *their* errors, *their* click-moment — not a definition available anywhere.
3. **Read back, don't just write.** Every session opens by reading the vault *and* Anki state. A write-only vault is a diary.
4. **Earn the word "learned" — and it decays.** Status/confidence come from unaided retrieval, not nodding along, and they expire on schedule. An over-generous *or* a stale vault is a false confidence map.
5. **Link across domains, and downward to foundations.** The graph's value compounds when a note wires to the same idea in another subject *and* to the concepts it structurally rests on.
6. **Card only what can't be derived, and do it proactively.** Genuine must-know atoms are harvested to Anki automatically at commit time — the learner should not have to ask. But nothing derivable is ever carded, and many sessions correctly produce zero cards.

## Step −1 — Source resolution (before read-back)
Resolve the named material to the **smallest readable unit** before doing anything else. This step decides how much source material enters context, and it is the difference between a session with room to teach and one that runs out of it.

- **Folder of markdown/text** → read today's files only, as before.
- **PDF in `/Library`** → find the map note in `/Maps` that names that PDF.
  - **Map exists** → read *only* the page range for today's section, using the map's **PDF page** column, never printed page numbers (see the offset rule below). A section is 4–10 pages. **Never read a whole chapter to teach one section, and never read the chapter "for context" before reading the section.**
  - **No map** → **this session is the mapping session.** Build the map, commit it, log the session, stop. Teaching starts next session. Say this plainly at the top so the learner knows today produces navigation, not concepts.
- **Nothing readable** — the PDF returns empty or garbled text → it is a scan with no text layer. Say so, name the file, and stop. It needs OCR (`ocrmypdf` or equivalent) before this system can use it. **Never infer, reconstruct, or supply content for a source that returned no text.**

**Building a map.**
1. Read the PDF's embedded outline if it has one; otherwise read its printed contents pages (usually within the first 20 PDF pages).
2. **Establish the page offset.** Printed page 1 is almost never PDF page 1 — front matter shifts it, typically by 10–30 pages. Read one page from the middle of the book, compare its printed number to its PDF index, and record the offset. Every subsequent read uses PDF pages. Getting this wrong means every session silently reads the wrong pages.
3. Write `/Maps/<Book> — <Author> <edition>.md` from `/Templates/textbook-map.md`. Entries are **sections**, not chapters — a chapter is 40–60 pages and is not one session's worth.
4. Leave the `Concept` and `Status` columns empty. They fill as sessions commit notes, which turns the map into the subject's coverage view over time.

**After teaching**, record the range in the concept note's `source_ref` and add that note's wikilink to the matching row of the map, so the map doubles as an honest record of what the book has actually been mined for.

## Step 0 — Read back (before teaching anything)
Read the source material resolved in Step −1 — *today's section only*, never the whole subject folder, chapter, or book.
Then read the vault:
- List `/Concepts` and `/Methods` notes with matching `subject`.
- Identify what's already `solid`/`mastered` → **skip re-teaching it** — but treat `solid` as *decaying*: if `today − last_unaided` exceeds the item's interval, it is **provisionally decayed**; surface it for a cold pass and don't trust the written `status` until re-earned.
- Identify anything `review_due` on or before today, any item still `learning`, any non-empty "Still fuzzy" → **these run first (Step 2), before new material.** Don't defer them to the end — the end is where they get skipped.
- When scanning `prerequisites:`, check whether a file exists at each `[[link]]`. **A `[[link]]` with no file is an *outstanding prerequisite* — an unstudied foundation, not coverage.** Never count it as a learned note.
Then read Anki:
- Query `stats_today` and, for this subject's tag, `get_card_memory_state`. Report cards due today and any atoms below ~0.85 retrievability — weak-and-earned, front-loaded like any due drill. (Routine reps happen in the Anki app; see the `anki` skill.)
- **Also scan other subjects and `tags`** for concepts today's topic may connect to, so the connection surfaces *during* teaching.

Open by telling the user what's due (vault + Anki), what's still open, any decayed `solid`, and any prior note from another subject that today's material links to.

## Step 0.5 — Foundations & synthesis check (when the review queue is light, or on request)
Turn the accumulated graph back on the learner — a *teaching mode*, not a build. No dashboards, no MOCs.
- Scan `prerequisites:` across this subject's `solid`/`mastered` notes. If a `solid` note rests on an **outstanding prerequisite** (a `[[link]]` with no file), surface it: *"You have Properties of Water at solid, but it stands on [[Electronegativity]], which you've never derived. Derive it now, or we down-rank the note."* A confident node on an unexamined foundation is the most dangerous silent failure.
- Where two notes across subjects touch the same idea, pose one synthesis question spanning them.
- If asked "what should I learn next?", search `prerequisites:` fields for unresolved targets, rank by how many notes depend on each, and name the top few.

## Step 1 — Diagnose the material type
Pick the mode per topic (a session can mix them), and keep a running **atom watch** throughout (see Step 2):
- **Conceptual** (mechanisms, "why") → **Feynman/Socratic.** Explain back in plain language, build an analogy, probe the gap, return to source.
- **Procedural** (calculation, method) → **worked example → they try → error analysis → reps.** Build speed and reliability. Don't merely Feynman-explain a method; make them do problems cold. A known procedural weakness gets cold reps at the *start* of the session.
- **Arbitrary/factual** (terminology, values, named reactions, stems, mnemonics — no reasoning to derive it) → **invoke the `anki` skill** (read its SKILL.md and follow it). Arbitrary atoms become Anki cards, not vault notes. Do **not** write a hollow vault note for pure atoms.

## Step 2 — Teach, then test by retrieval
The unifying mechanism across all modes is **retrieval practice**: explaining-, solving-, and recalling-unaided are the same act. It confirms learning, generates the note content, and sets the confidence level. Do not accept recognition ("yeah, that makes sense") as evidence — ask for the unaided production.

**Vary the retrieval format** — never let it collapse into one predictable move. Beyond explain-back / solve-cold / recall-cold, use where the material allows: **transfer** (apply to a new domain), **counterexample**, **predict-then-verify**, **spot-the-deliberate-error**.

**Atom watch (runs alongside the teaching, all modes).** As you teach, notice arbitrary atoms embedded in the material — the terminology, values, drug/enzyme stems, or must-know phrases that meet the `anki` skill's boundary test (no derivation AND genuinely must-know). Note them silently; do **not** stop mid-explanation to make cards, exactly as vault notes aren't written mid-explanation. They are harvested at commit (Step 3.6). A conceptual session on buffers may yield zero atoms — that is correct; do not manufacture atoms to justify a card.

## Step 3 — Commit (end of topic, not mid-explanation)
Only write once retrieval has revealed true confidence.

For each concept/method learned:
1. **Reconcile.** Search `/Concepts` (or `/Methods`) by title. **Exists** → update (deepen "My understanding" only for genuine new nuance; bump `status`/`confidence`/`last_reviewed`; update `last_unaided` only on an unaided cold pass; set new `review_due`; add the session link; clear resolved fuzzies). **New** → create from `/Templates/concept.md`. **If the concept was previously an unresolved `[[link]]` (a prerequisite stub), the new note's title must equal that link target verbatim**, so existing backlinks resolve onto it.
2. **Fill the body honestly** — My understanding (their words), The precise version, Where I got stuck/corrected, What made it click, Connects to, Still fuzzy.
3. **Set frontmatter** per the status ladder and the YAML rules below, including `tags` and — where the material came from a PDF — `source_ref` with the exact section and PDF page range. Then add this note's wikilink to the matching row of the book's map in `/Maps`.
4. **Link — outward across subjects, and downward to foundations.**
   - **Cross-domain (outward):** search the whole vault, all subjects, for concepts this note connects to; wire with `related` wikilinks + shared `tags`.
   - **Foundations (downward) — the prerequisite-stub rule:** for every concept in this note's derivation chain, apply the **two-part test** — **(i)** a real future study target in its own right? **AND (ii)** does deleting it break this note's chain? **If both, add it as a wikilink in `prerequisites:` — even if no note exists yet.** Do **not** create a file; the unresolved wikilink *is* the node, and having no file is what stops read-back mistaking it for coverage. **Qualifies:** electronegativity, specific heat capacity, latent heat, redox, ion–dipole, covalent bonding. **Does not:** primitive vocabulary (gas, mass, energy), descriptive phrases (tetrahedral lattice), examples (a specific hot afternoon). Prerequisites go in `prerequisites:`; downstream topics the note feeds *into* (`[[Fluid Dynamics]]`, `[[Cellular Respiration]]`) stay in `related:`/body. **Err toward under-linking.**
   - Ensure the subject Map links to the note.
5. **Advance the schedule (a review isn't done until its date moves).** Passed unaided → bump `status`/`confidence`, longer `review_due`, set `last_unaided` today. Failed/partial → keep `learning`, `review_due` = tomorrow, record the error in "Still fuzzy", don't touch `last_unaided`. Never leave a surfaced item with a lapsed date and no new one. Same `learning` item surfaced-but-unclosed across **two** prior sessions → mandatory first item next session.
6. **Harvest atoms → Anki (the proactive card step).** Take the atoms noticed during the atom watch. For each, apply the boundary test and reconcile against Anki (`find_notes` — skip anything already carded, and skip anything that is actually a vault concept). Create the **minimal** remaining set by invoking the `anki` skill — read its SKILL.md and apply its card-authoring principles and tag scheme (`add_notes`, tagged `subject::` / `topic::` / `src::<session>` so they join the graph). Then report plainly: *"Carded 4 atoms to Medicine::Terminology::Renal — nephr- , -uria, -lithiasis, oliguria. Say the word to prune."* Default is create-and-report; if the user prefers to approve first, propose the list instead of creating. **Zero atoms is a valid, common outcome — never card to fill a quota.**

## Step 4 — Log the session (always, even on a zero-commit session)
Create/update one `/Sessions` note from `/Templates/session.md`: date, subject, scope, concepts committed (as links), atoms carded (deck + count), and — critically — where we stopped and what's still fuzzy/open. **A session that ended mid-correction is the one whose log matters most.** "Nothing was solid enough to commit" is itself a required entry. If a due/`learning` item was surfaced but not closed, record it. **No session ends with zero vault writes.**

## The status ladder (single source of truth)
- **seen** — encountered, not engaged. No file; a load-bearing future target lives as an unresolved `[[link]]` in another note's `prerequisites:`, never as a stub file.
- **learning** — explained/solved partially, gaps remain. `confidence` 1–2.
- **solid** — explained back cleanly unaided, OR solved a representative problem cold. `confidence` 3–4.
- **mastered** — did it cold across a spaced interval, fuzzies closed. `confidence` 5, long `review_due`.

Promotion is earned by unaided retrieval only, recorded in `last_unaided`. Status **decays**: past `review_due` without a cold pass, treat the note one rung lower until re-earned. Re-*reading* a note updates `last_reviewed` only — never `last_unaided` or status. Spacing: learning ≈ 1–2 days, solid ≈ 1 week, mastered ≈ 3–4 weeks.

## Frontmatter schema (every concept/method note)
```yaml
type: concept                            # or method
subject: "Chemistry"
status: learning                         # seen | learning | solid | mastered
confidence: 2                            # 1–5, honest
tags: [acids-bases, equilibrium]         # cross-domain connective tissue
first_learned: 2026-08-12
last_reviewed: 2026-08-12                # any contact, including a re-read
last_unaided: 2026-08-12                 # last cold, UNAIDED pass — the only thing that earns/renews status
review_due: 2026-08-14
source_ref: "Ch12 §3, PDF pp. 253–265"    # where in the source this came from
sources: ["[[Avery — Oral Histology 3e]]"]
sessions: ["[[2026-08-12 Chemistry — T3: Acids]]"]
prerequisites: ["[[Electronegativity]]", "[[Covalent Bonding]]"]   # foundations this note rests on — INCLUDING unresolved links to not-yet-studied concepts
related: ["[[Buffer Systems]]"]          # cross-subject links and downstream topics
anki: "Chemistry::T3"                    # optional: deck/tag if this concept leans on a specific atom set
exam_weight: 30
```

### YAML rules (non-negotiable — malformed frontmatter corrupts the note)
1. **Every wikilink inside frontmatter is a quoted string.** Write `["[[X]]"]`, never `[[X]]`. Unquoted `[[X]]` is a nested sequence in YAML, not a link — Obsidian renders it broken and rewrites or strips it the next time properties are touched in the UI.
2. **Quote any value containing `:`, `#`, `—`, or a leading `[`.** Session and chapter titles routinely contain colons, and a colon-plus-space inside an unquoted scalar is a hard parse error that breaks the note's entire frontmatter block.
3. **Tags are single lowercase hyphenated tokens.** `molecules-of-life`, never `Molecules of Life` — Obsidian tags cannot contain spaces, and a spaced value silently becomes several junk tags.
4. **Never emit an empty key.** Omit the line, or write `null`. A bare `subject:` is a null value that read-back cannot filter on.
5. **Verify after writing.** Having written or updated any note, re-read its frontmatter and confirm every field parsed as the intended type. If a list came back nested, a wikilink was unquoted — fix it before continuing. Do not batch this check to the end of the session.

*(`/Templates/concept.md` carries `last_unaided:`, `source_ref:` and, if used, `anki:`.)*

## Scaling note — the read-back index (do NOT build yet)
Read-back's control data lives in per-note frontmatter, readable only by opening each note. Cheap now; keep it un-built while cheap. **Only** when a single subject exceeds ~25 concept/method notes, introduce one `/Maps/_index-<subject>.md` (row per note: title, `status`, `review_due`, `has_open_fuzzy`, `outstanding_prereqs`), written at the commit step, read first on read-back, opening full bodies only for flagged items. It is a *cache, never a source of truth* — cross-check its row count against a directory listing each read-back; on mismatch, fall back and rebuild. Adding prerequisite links never raises read cost.

**This restriction concerns the read-back index only.** Textbook maps in `/Maps` are a different artifact entirely — navigation for *source material*, not a cache of vault state — and are built on first contact with any PDF source, regardless of vault size.

## Do NOT
- Do not write to the vault mid-explanation, before confidence is known.
- Do not create a new note when one exists — reconcile.
- Do not create empty stub files — use unresolved `[[links]]` in `prerequisites:`.
- Do not card anything derivable, and do not manufacture atoms to justify making cards — zero cards is a valid outcome.
- Do not duplicate across the vault and Anki — derivable → vault, arbitrary → Anki.
- Do not link primitive vocabulary or note-specific descriptive phrases — err toward under-linking.
- Do not inflate status/confidence, and do not keep a stale `solid` — decay it.
- Do not defer a due drill to the end of a session — front-load it.
- Do not read or ingest an entire subject folder — today's material only.
- Do not read a whole chapter, or a whole PDF, to teach one section.
- Do not split, convert, or pre-process a PDF — read page ranges from it in place.
- Do not use printed page numbers as read offsets — use the map's PDF page column.
- Do not supply content for a PDF that returned no text. Report the OCR gap and stop.
- Do not write an unquoted `[[wikilink]]` into frontmatter — quote it, or the note breaks.
- Do not bulk-grind Anki reviews through chat — reps happen in the app.
- Do not build the read-back index, theme MOCs, or other machinery before the vault's size forces it.
