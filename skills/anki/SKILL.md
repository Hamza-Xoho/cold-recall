---
name: anki
description: "Own the arbitrary/factual half of learning — atoms with no derivation (medical terminology prefixes/suffixes, must-know values, named reactions, drug-class stems, mnemonics) — by authoring well-formed Anki cards through the AnkiMCP server, reading FSRS memory state so the system knows what is actually retained, and repairing failing cards by giving them a reconstruction hook. Use when the user asks to make/refine flashcards, drill or memorise arbitrary facts, review or check due cards, or see flashcard progress; and whenever the `learning` skill diagnoses material as arbitrary/factual. Never card a concept that can be derived."
---

# Anki Skill

Anki is the externalised home of **one** material type: the arbitrary/factual atoms that have no derivation chain and simply must be known. Everything that can be *reconstructed* stays in the vault as a concept and gets **no** card. This skill exists to make **few, good** cards, to let the system see real retention via FSRS, and to repair rote failure by turning it into understanding — not to push flashcards. The learner does not love flashcards; that restraint is a feature of this skill, not a limitation to work around.

- **Server:** AnkiMCP addon (AnkiWeb code `124672614`), MCP over HTTP at `http://127.0.0.1:3141/`. Requires **Anki 25.07+** running.
- **Scheduler:** FSRS. Memory state (stability / difficulty / **retrievability**) is the honest, earned, decaying confidence signal for atoms — the analogue of the vault's `last_unaided`/decay for concepts.
- **Vault:** `__VAULT_PATH__`. This skill and the vault are **complementary and non-overlapping**: derivable → vault, arbitrary → Anki. An atom is never duplicated into both.

## The boundary — what gets a card (apply before making anything)
A fact becomes a card **only if both hold**: **(i)** it has *no derivation* — you cannot reconstruct it from a rule, mechanism, or etymology you already hold; **AND (ii)** it is genuinely a must-know for the goal (exam-relevant, clinically load-bearing). If it can be derived, it belongs in the vault as a concept — do **not** card it, and do **not** make a hollow vault note for it either.
- **Cards (arbitrary atoms):** `-ectomy = surgical removal`; `-itis = inflammation`; `-pril = ACE inhibitor`, `-olol = beta blocker`; Avogadro's number; a named reaction's reagents/conditions; normal lab reference ranges; cranial-nerve names and order; unit prefixes.
- **Not cards (→ vault concepts):** why an ACE inhibitor lowers blood pressure; how a buffer resists pH change; the mechanism of the Na⁺/K⁺ pump; anything with a "why" you rebuild.
- **Edge — procedures:** an executed procedure (quadratic formula, stoichiometry) is drilled with cold reps in the vault's *procedural* mode, not here. Anki is for pure recall atoms only.
- **Err toward fewer cards.** If a fact is on the derivation side of the line, leave it to the vault. Over-carding is a failure exactly like over-linking the graph.

## Connection & recommended tool trim
The addon exposes 27 tools; most are irrelevant here and cost context tokens. In the addon config (`Tools → Add-ons → AnkiMCP Server → Config`), set `disabled_tools` to hide what this workflow never uses — keep authoring, FSRS, stats, tags, sync, and the few lifecycle actions used for repair:
```json
{ "disabled_tools": [
  "gui_browse","gui_add_cards","gui_edit_note","gui_current_card",
  "gui_show_question","gui_show_answer","gui_select_card","gui_deck_browser","gui_undo",
  "store_media_file","get_media_files_names","delete_media_file",
  "model_styling","update_model_styling","create_model",
  "card_management:reposition","card_management:bury","card_management:unbury","card_management:set_flag"
] }
```
If exposing Anki to Claude.ai via a tunnel, set a secret `http_path` and keep the media hardening defaults — never expose the root endpoint openly.

## Card-authoring principles (the reason this skill beats "dump cards")
Auto-generated cards are usually bad cards. Every card obeys these:
- **Minimum information principle.** One atom per card. "List the 12 cranial nerves" is not a card; twelve ordered cloze deletions are.
- **Atomic & unambiguous.** The prompt must have exactly one correct answer. Rewrite "What is -lysis?" (ambiguous) to "Suffix -lysis → ?" with answer "breakdown / destruction / loosening".
- **Cloze for embedded facts and sequences.** Use the Cloze model for reactions, ranges, and mnemonics ("Glycolysis nets {{c1::2}} ATP and {{c2::2}} NADH"). Prefer cloze over Basic when the fact lives inside a phrase.
- **Direction deliberately.** Term→meaning is the default (Basic). Add the reverse (meaning→term, Basic (and reversed card)) **only** when the learner must produce the term from the meaning too (e.g. drug-class stems). Don't reverse by reflex — it doubles reviews.
- **No lists-as-one-card, no ambiguous images, no interference pairs** batched together (space near-identical stems so they don't compete on the same day).
- Keep answers terse. A card is a retrieval cue, not a note — the *understanding* lives in the vault; link to it (tag) rather than restating it on the card.

## Step 1 — Reconcile before adding (no duplicate cards)
Mirror the vault's reconcile-don't-duplicate. Before creating anything, `find_notes` for the atom by its tag namespace and/or field text. If a card exists, `update_note_fields` it; never spawn a duplicate. Re-running a session over the same material must not multiply cards — the stable tag scheme (below) makes prior cards findable.

## Step 2 — Generate the cards
1. `model_names` / `model_field_names` to confirm available note types (default to shipped **Basic**, **Basic (and reversed card)**, **Cloze**).
2. Choose the deck: `Subject::Topic` (e.g. `Medicine::Terminology::Renal`). `create_deck` if absent.
3. Author the atoms per the principles above.
4. `add_notes` (batch, atomic undo, partial-success) with the tag scheme below.
5. Report back plainly: N cards added to which deck, and which (if any) were skipped as reconciled duplicates.

## Step 3 — Read FSRS state (the honesty layer, used at session open)
This is how the system *sees* the memorisation half without duplicating it into the vault:
- `stats_today` / `stats_forecast` — how many cards are due today / this week, per deck.
- `find_notes` by the subject tag + `get_card_memory_state` — retrievability per card for the topic in play. **Surface atoms below ~0.85 retrievability as weak** — the earned, decaying "you don't actually know this right now" signal, exactly parallel to a decayed `solid` in the vault.
- Report at the start of a session: due-count and the specific weak atoms for today's subject. These are front-loaded like any other due drill — the boring reps go first, not last.

## Step 4 — Review, deliberately scoped
Routine daily reps happen in the **Anki app** — it is faster and purpose-built; grinding a full due queue through chat is admin, not learning, and fails the system's own test. Claude runs cards (`get_due_cards` → `present_card` → `rate_card`) in only two cases:
- **Interleaving:** during a *concept* (vault) session, pull the linked atoms via `find_notes tag:<subject>` and quiz a handful as front-loaded, context-relevant retrieval ("before today's renal physiology, produce these five suffixes cold"). Rate honestly so FSRS stays true.
- **Targeted weak-card quizzing:** when the learner explicitly asks for active retrieval on their lowest-retrievability atoms.
Never bulk-grind through chat.

## Step 5 — Repair failing cards (leech → derive)
A card that keeps failing is a signal it should not be pure memorisation. When `notes_info`/FSRS shows a leech or a persistently low-retrievability atom:
1. Surface the reconstruction hook Claude can supply that Anki cannot — etymology (`-ectomy` ← Greek *ek-tomē*, "a cutting out"; `-pnea` ← *pnein*, "to breathe"), a mechanism, or a mnemonic that ties the atom to something already solid in the vault.
2. Rewrite the card to carry the hook, or split an overloaded card into atoms, via `update_note_fields` / `add_notes` + `delete_notes`.
3. If the hook is rich enough that the fact is now *derivable*, promote it to the vault as a concept and `suspend` or `delete_notes` the card — it graduated out of rote. This is the anti-memorisation ethos operating as card maintenance.
`optimize_fsrs_params` occasionally (after enough review history) to keep intervals honest; `set_fsrs_params` to raise desired retention on a high-stakes deck if warranted (default 0.90).

## Tag & deck schema (the vault↔Anki join)
- **Deck:** `Subject::Topic` (hierarchical), e.g. `Medicine::Terminology::Renal`.
- **Tags (the join key to the graph):**
  - `subject::<subject>` and `topic::<topic>` — mirror the vault subject/topic so read-back can correlate cards to what's being studied.
  - `src::<YYYY-MM-DD-session>` — provenance, so a session's cards are traceable (parallels the vault's session links).
  - Optional `system::<body-system>` or theme tag for cross-domain grouping (the Anki equivalent of the vault's cross-domain links; atoms are mostly leaves, so keep this light).
- A vault concept that genuinely leans on a specific atom set may name the deck/tag in an optional `anki:` frontmatter field — but only when it helps; do not create vault notes solely to point at Anki.

## Do NOT
- Do not card anything derivable — that belongs in the vault as a concept.
- Do not create a hollow vault note for an atom set — atoms live in Anki, and read-back sees them via FSRS, not via a stub note.
- Do not duplicate a card — reconcile with `find_notes` first.
- Do not over-generate — few, good, atomic cards; err toward fewer.
- Do not reverse cards by reflex, or batch interfering near-duplicates on the same day.
- Do not bulk-grind reviews through chat — reps happen in the Anki app.
- Do not build custom note types unless Basic/Cloze genuinely cannot express the atom.
