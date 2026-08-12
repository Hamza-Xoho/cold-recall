# Adapting it

Everything here is prose. To change the system, edit the prose — there's no code path to break.

**The three files that matter:**

| File | Controls |
|---|---|
| `skills/learning/SKILL.md` | Session procedure, status ladder, note schema, linking rules |
| `skills/anki/SKILL.md` | What gets carded, card style, deck/tag scheme |
| `project-instructions.md` | The standing contract, pasted into your Claude Project |

After editing, re-run `./setup.sh` and re-install / re-paste.

---

## Different subjects

Nothing is subject-specific. It's been run on biology, physics, chemistry, and medical terminology; the loop is generic. Some notes on fit:

**Languages.** Vocabulary is arbitrary → Anki. Grammar *rules* are derivable → vault. Idioms are arbitrary. Expect a much higher card-to-note ratio than a science subject, and that's correct.

**Law.** Doctrine and reasoning → vault. Case names, dates, statute sections → Anki. The "wrong route, right answer" failure mode is severe here — a correct conclusion from bad reasoning is worth zero marks — so this system's core catch matters more than usual.

**History.** Causal chains and historiographical debates → vault. Dates and names → Anki, sparingly. Ask for **transfer** retrieval (*"apply this causal pattern to a different revolution"*) rather than recall.

**Mathematics.** Mostly procedural. Expect worked-example-then-reps, not Feynman explanation. Very few cards — a formula you can derive should not be carded. Consider raising the "solid" bar to *two* cold problems rather than one.

**Programming.** Concepts and patterns → vault. API signatures → don't card; look them up. Most of this is procedural and wants reps.

---

## Common tweaks

<details>
<summary><b>Stop automatic flashcards</b></summary>

Add to your project instructions:

> Never create Anki cards without proposing them first and waiting for approval.

Or say `propose first` in any session for one-off behaviour.

</details>

<details>
<summary><b>Turn Anki off entirely</b></summary>

In `project-instructions.md`, delete the "Arbitrary facts live in Anki" bullet in §5 and the Anki clause in §4 step 4. In `skills/learning/SKILL.md`, remove the Anki auto-invoke block near the top and Step 3.6.

The vault half works standalone. You'll lose the arbitrary-fact channel, so decide where those go instead.

</details>

<details>
<summary><b>Change review spacing</b></summary>

In `skills/learning/SKILL.md`, find the status ladder:

> Spacing: learning ≈ 1–2 days, solid ≈ 1 week, mastered ≈ 3–4 weeks.

Change the numbers. Shorten if you're near an exam; lengthen for long-horizon study.

</details>

<details>
<summary><b>Make "solid" harder or easier to earn</b></summary>

Same ladder. The current bar is *"explained back cleanly unaided, OR solved a representative problem cold."*

Harder: require two separate cold passes on different days. Easier: allow a pass with one minor correction. Whatever you choose, keep it **unaided** — the moment status can be earned with hints, the map stops meaning anything.

</details>

<details>
<summary><b>Drop the exam framing</b></summary>

Remove `exam_weight` from `vault-template/Templates/concept.md` and delete the field from the schema in `skills/learning/SKILL.md`.

</details>

<details>
<summary><b>Change the folder layout</b></summary>

Update the **Folders** line in `skills/learning/SKILL.md` and rename the folders in your vault. Keep `Templates/` — the skill reads `concept.md`, `session.md` and `textbook-map.md` from it.

</details>

<details>
<summary><b>Add a new note section</b></summary>

Add the heading to `vault-template/Templates/concept.md` and mention it in Step 3.2 of `skills/learning/SKILL.md` so the skill knows to fill it. Both, or it'll be created empty and stay empty.

</details>

<details>
<summary><b>Different vault app</b></summary>

Nothing here is Obsidian-specific except `[[wikilinks]]`. Logseq handles them natively. For plain Markdown editors everything still works; you lose the graph and backlinks, which is where the cross-domain value lives.

</details>

---

## Bigger changes

**Multiple vaults per subject.** Possible but discouraged — cross-domain linking is the compounding benefit, and it dies at a vault boundary. Use `subject:` frontmatter and folders instead.

**Sharing a vault between people.** The vault records *one person's* understanding and errors. Two people's confidence maps in one vault makes both useless. Share the *skills*, not the vault.

**As the vault grows past ~25 notes in one subject**, read-back gets slow because it opens every note's frontmatter. There's a designed-but-deliberately-unbuilt solution in `skills/learning/SKILL.md` under **"Scaling note — the read-back index."** Don't build it early; it's a cache, and a cache that can disagree with the truth is a liability until the read cost genuinely hurts.

---

## If you change something that works well

Please [open a PR or issue](https://github.com/Hamza-Xoho/cold-recall/issues) — especially subject-specific adaptations. The pedagogy is generic in principle, but only real sessions in untested subjects will show where it isn't.
