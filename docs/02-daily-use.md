# Daily use

---

## Starting a session

Open a new chat **inside your Claude Project** and name three things:

```
Biology, ~/Resources/Bio/Topic 1, Molecules of Life
```

**Subject** · **where the material lives** · **today's topic**. No commands, no slash prefixes.

**Be narrow.** "Molecules of Life" beats "Biology." "Topic 3, meiosis only" beats "the cell cycle." A narrow pointer makes the read-back sharper and stops the session sprawling across three hours of material you won't retain.

**One topic per chat.** Two reasons: long chats degrade as context fills, and separate sessions give you natural spacing.

### If you have no source folder

Fine — name the subject and topic and say so:

```
Chemistry, no source folder, just the topic: Le Chatelier's principle
```

### Not sure what to study?

```
What should I work on today?
```

It'll read your vault, check what's overdue, look for `solid` notes standing on underived foundations, and tell you.

---

## What a session looks like

**1. Read-back.** It reads your vault and Anki, then reports: what's overdue, what's still open from last time, any `solid` note that's decayed, and any note from another subject today's material connects to. *Nothing has been taught yet.*

**2. Cold retrieval.** It asks you to produce what you already have — unaided, no notes, no searching. This diagnoses the gaps.

> **"I don't know" is the most useful answer you can give.** A confident guess is the only one that costs you, because it hides the gap.

**3. Teaching, matched to the material.** Concepts get Socratic questioning. Procedures get worked examples and reps. Arbitrary facts get carded rather than explained.

**4. Testing.** Explain-back, solve-cold, transfer to a new domain, spot-the-deliberate-error, predict-then-verify. Rotated so you can't pattern-match the format.

**5. Commit.** At end-of-topic — never mid-explanation — it writes notes reflecting your *actual* demonstrated confidence, harvests any genuine atoms to Anki, and logs the session.

---

## Things worth saying

| Say this | To get |
|---|---|
| `Just drill me on what's due.` | Review-only session, no new material |
| `Propose first.` | Approval before any card is created |
| `I don't know.` | Honest diagnosis instead of a wasted correction |
| `Test me on this cold.` | Unaided retrieval attempt |
| `Why is this note only `learning`?` | The specific evidence behind a grade |
| `Commit what we have and log it.` | Clean stop mid-topic |
| `Be brief.` | Shorter replies — teaching intact |
| `What am I weakest on in this subject?` | Honest gap ranking |
| `This card keeps failing.` | Card rewritten with a reconstruction hook |

---

## Ending well

**Always end deliberately.** A session that dies when you close the tab loses its log, and the log is what the next session reads.

If you're stopping mid-topic:

```
Let's stop here. Commit what's earned and log where we stopped.
```

The log records where you stopped and what's still open. Sessions that ended mid-correction are exactly the ones whose logs matter most — that's the note that stops you silently dropping a half-fixed misconception.

---

## The rhythm

- **Every session**: due items first, then one topic.
- **Anki reps happen in the Anki app**, not in chat. Grinding a due queue through conversation is slow and it's admin, not learning. Claude touches cards for two things only: a handful of interleaved atoms at session start, and repairing cards that keep failing.
- **Every few weeks**: `Give me a synthesis check across this subject` — questions spanning two notes at once, plus any confident node standing on an underived foundation.

---

## Reading your vault

Open Obsidian and look at:

- **Graph view** — clusters are what you understand; isolated nodes are things you learned but never connected.
- **`Sessions/`** — the honest history. Where you stopped, what was still open.
- **`Maps/`** — per-subject index.
- **Any note's "Still fuzzy"** — the fastest revision list you own.

**A note with an empty "Where I got corrected" section is suspicious.** It usually means the topic was accepted rather than tested.

---

## When it feels too harsh

It will grade you lower than you expect, especially early. Before overriding it, check *why*: ask `why is this only learning?` and look at the evidence. Usually it's one of

- you reached a right answer by a wrong route,
- you were told the thing rather than deriving it, or
- you were corrected on that same point in the same session.

All three are real reasons not to call something solid.

If you genuinely disagree, say so — it's your vault and you can edit any note by hand. But the value of the map is exactly its refusal to flatter you. Overriding it often makes it a diary again.

---

Next: **[03 — Troubleshooting](03-troubleshooting.md)** · **[04 — Adapting](04-adapting.md)**
