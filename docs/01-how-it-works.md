# How it works

Every rule in this system exists because a specific failure mode kept happening. This doc is the reasoning — read it if you want to modify things intelligently rather than by guesswork.

---

## The core problem: fluency is not knowledge

When you re-read a page, the second pass feels easier than the first. Your brain reads that ease as *"I know this."* It isn't. It's familiarity, and familiarity vanishes under exam conditions when the cue you were leaning on isn't there.

AI tutoring makes this dramatically worse, because a good explanation produces the strongest fluency signal available. Each sentence lands. Nothing feels confusing. You leave feeling taught — and you are, in the same way you are "taught" by watching someone else swim.

**The counter is retrieval practice**: producing the thing from memory, unaided, before you're shown it. It feels worse and works better. That's not a slogan, it's the [testing effect](https://en.wikipedia.org/wiki/Testing_effect), one of the most reliably replicated results in learning science.

Hence the system's first rule: **nothing is taught before retrieval is attempted.** A session opens by asking you to produce what you already have, cold. What you produce diagnoses the material; what you can't produce becomes the lesson.

---

## Why two stores

Facts are not all the same kind of thing, and treating them alike is how study systems go wrong.

**Derivable knowledge** can be rebuilt from a mechanism. *Why does a buffer resist pH change?* If you understand the equilibrium, you can reconstruct it forever. Carding this is actively harmful: it converts a thing you can *think your way to* into a thing you must *remember*, and remembering is the weaker, more fragile mode.

**Arbitrary knowledge** has no derivation. `-ectomy` means surgical removal because Greek, and no amount of reasoning gets you there. Avogadro's number is what it is. These *must* be memorised, and spaced repetition is the correct technology.

So:

| | **Obsidian vault** | **Anki** |
|---|---|---|
| Holds | Derivable understanding | Arbitrary atoms |
| Unit | A concept note | A card |
| Confidence signal | `last_unaided` + decay | FSRS retrievability |
| Grows by | Sessions | Sessions, sparsely |

**Never both.** A fact in both stores is a fact you'll review twice and trust half as much. The `anki` skill applies a two-part test before making anything: *no derivation* **and** *genuinely must-know*. Fail either and it goes to the vault, or nowhere.

The practical upshot most people find surprising: **most sessions produce zero cards, and that's correct.** A session on buffers should produce a rich concept note and no flashcards at all. Card count is not a productivity metric. Tools that generate 40 cards per chapter are giving you 40 things to forget.

---

## Why status decays

The vault is a map of what you know. A map that overstates your coverage is worse than no map, because you'll revise elsewhere.

So status is **earned by unaided production only**, and it **expires**:

| Status | Earned by | Review interval |
|---|---|---|
| `seen` | Encountered. No note yet — lives as an unresolved `[[link]]` | — |
| `learning` | Explained or solved partially; gaps remain | 1–2 days |
| `solid` | Explained back cleanly cold, **or** solved a representative problem cold | ~1 week |
| `mastered` | Done cold across a spaced interval, fuzzies closed | 3–4 weeks |

Two rules do the real work:

- **Re-*reading* a note updates `last_reviewed` and nothing else.** It never touches `last_unaided`, and it never promotes status. Reading your own notes is not retrieval.
- **Past `review_due` with no cold pass → treat the note one rung lower** until re-earned. A three-month-old `solid` is a claim, not a fact.

And a rule that sounds like bookkeeping but isn't: **a review only counts when its date advances.** If an item gets surfaced and drilled but nobody moves `review_due`, it stays permanently overdue, the queue fills with noise, and you start ignoring it. Every cold pass moves the date — forward on a pass, to tomorrow on a fail.

---

## Why the boring work goes first

Overdue reviews and due cards run at the **start** of a session, before new material.

This is not about discipline. It's that the end of a session is when you're tired, the interesting part is done, and "I'll do the reviews tomorrow" is maximally persuasive. Anything scheduled last is scheduled never. So the drill you'd skip is the drill that runs first, cold, while you still have attention to spend.

There's a second benefit: doing the overdue physics item before new biology means you find out *now* whether the foundation is still there.

---

## Why notes record your errors

A note that restates the textbook is worthless — the textbook exists and is better written. The valuable content is what's *not* in any book:

- **How you explained it** — your words, which is what you'll actually reconstruct from
- **Where you got corrected** — the specific broken link, and the fix
- **What made it click** — the analogy or number that turned it

Two months later, "you had this backwards: surface tension *reduces* the area, it doesn't maximise it" is worth more than three paragraphs of correct definition. It targets the thing your brain actually does wrong.

---

## Prerequisites, and the danger of a confident node

Notes link **downward** to what they rest on — including things you've never studied. Those are unresolved `[[wikilinks]]` with no file behind them, deliberately.

The empty link *is* the signal. If `[[Properties of Water]]` is `solid` and lists `[[Electronegativity]]` as a prerequisite with no note behind it, you're confident about something standing on a foundation you've never derived. That's the most dangerous state in the whole vault, because nothing about it feels wrong.

The system surfaces these and offers you the choice: derive the foundation now, or down-rank the note that depends on it.

This is also why **no empty stub files** are ever created. A stub looks like coverage in a folder listing. An unresolved link cannot be mistaken for anything.

---

## Why prose, not code

The entire system is three Markdown files. No database, no server, no scripts to break.

That's a deliberate trade. A coded system would enforce its rules perfectly and be far harder for you to argue with. This one is *read* by Claude each session — which means the rules bend where they should, and, more importantly, **you can open any of them and change your mind.** Disagree with the spacing intervals? Edit four numbers. Don't want automatic carding? Delete a paragraph.

The cost is that enforcement is soft. Claude follows the instructions well but not mechanically. If you push hard for reassurance, you can probably get it. The system is a structure for honesty, not a cage — and the person it has to be honest with is the one who can edit it.

---

Next: **[02 — Daily use](02-daily-use.md)**
