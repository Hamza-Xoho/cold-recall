# Contributing

## The most useful contribution

**Session transcripts from subjects this hasn't been tested on.**

The system has been run hard on biology, physics, chemistry, and medical terminology. The pedagogy should be subject-agnostic — but "should be" is doing a lot of work in that sentence. Law, languages, history, music theory, and pure maths will each stress it differently, and nobody knows where it breaks until someone runs it.

If you use it for something new, open an issue with:

- The subject and material type
- What worked
- **What the loop got wrong** — where the diagnosis mismatched, where grading felt off, where carding misfired
- Any wording change that fixed it

A paragraph of honest friction is worth more than a polished PR.

## Changing the skills

The skills are prose, so PRs are prose edits. Two things to keep in mind:

1. **Every rule in there is load-bearing.** Most exist because a specific failure kept recurring — [docs/01-how-it-works.md](docs/01-how-it-works.md) explains the reasoning. If you're removing a rule, say which failure mode you think it was guarding against and why that's no longer a concern.
2. **Test before proposing.** Run at least one real session with your change. Skill edits are easy to write and hard to predict.

## Keeping it accessible

A lot of readers here are students, not developers. When editing docs:

- Spell out steps rather than assuming a terminal is familiar
- Name the exact menu item, not "the settings"
- Say what success looks like, so people can tell whether it worked
- Avoid jargon where a plain word exists

## Scope

**In scope:** the loop, the two stores, docs, subject adaptations, setup friction.

**Out of scope:** turning this into an app, a hosted service, or a database. The whole design bet is that it stays three Markdown files anyone can open and argue with. Features that require code to maintain lose that.

## Code of conduct

Be decent. Assume good faith. This is a study tool made by people who'd rather be studying.
