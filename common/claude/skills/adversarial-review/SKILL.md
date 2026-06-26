---
name: adversarial-review
description: >-
  Iterative adversarial review for any fact-heavy, checkable, act-on-it artifact
  — a note, a plan, live data, a spec, or code. Each round spawn a FRESH hostile
  reviewer with NO prior context, have it return structured CRITICAL/MAJOR/MINOR
  findings, YOU verify its external claims before applying, fix the source, log
  the round, and iterate until two consecutive rounds (or one + a confirm round)
  return zero CRITICAL and zero MAJOR. Use when the user says "adversarially
  review this", "run the review workflow", "tear this apart", "review until it
  converges", or when an artifact's numbers/claims may be wrong or stale and the
  user will act on them. Domain-specialized variants can delegate their loop here.
argument-hint: "[file/dir/diff path or plain-language description of what to review]"
---

# Adversarial Review — Iterative, Until Converged

A repeatable loop for any artifact where (a) accuracy matters, (b) claims are
checkable against external sources, and (c) being wrong has real-world cost.
Each round a **fresh** reviewer with **no prior context** attacks the artifact;
**you** (the orchestrator) verify and synthesize; you iterate until it converges.

This skill is self-contained — it runs in any project.

## When to run

The artifact has any of: tax/legal/regulatory claims, multi-step maths where one
wrong assumption cascades, authoritative cross-references a sceptic will
spot-check, or recommendations the user will act on. **Don't** bother for short
ideas, journals, status notes, or anything where being wrong costs nothing.

## Step 0 — Establish the target (ask only if ambiguous)

If the skill was invoked with an argument, **that argument is your target**: $ARGUMENTS

- Use it directly — don't ask what to review. It may be a **path** (file, dir, or
  diff ref like `HEAD~3..HEAD`) or a **plain-language description** ("the auth
  module", "last night's migration"); resolve a description to the concrete
  file(s) / diff / live source before snapshotting.
- If the argument line above is blank (skill triggered by phrasing rather than a
  typed `/adversarial-review <target>`), fall back to detecting or confirming the
  target as below.

Adapt the loop to what's being reviewed. Detect or confirm:

- **Static document** (note, spec, markdown): the file *is* the snapshot.
  Fixes = edit the file.
- **Live data** (a budget plan, a config, anything behind an MCP/API): pull
  fresh data FIRST, build a reviewable snapshot at `/tmp/<thing>_snapshot.md`,
  and remember fixes touch **both** the live source AND the snapshot.
- **Code**: the diff or the file(s) are the artifact; fixes = edits + tests.

Also establish the **domain** (e.g. inheritance tax, property law, distributed
systems, applied cryptography) — the reviewer briefing must be domain-specific,
because a generic reviewer misses the domain's signature traps. And establish
**where to log** the rounds — a sibling `<Name> - Review Log.md` next to the
artifact, or a dated file under the project's notes/memory directory.

## The loop

1. **Snapshot.** Produce the single coherent artifact the reviewer attacks. For
   live data, reconcile it into ONE document with ONE figure per quantity (no
   "free cash is £X here and £Y there").
2. **Spawn ONE fresh reviewer** per round (a `general-purpose` sub-agent, no
   prior context) using the template below, customized with the domain briefing.
   Tell it the **TYPES** of issues already addressed in prior rounds — never the
   prior reviewer's findings verbatim (that biases it toward agreeing).
3. **Reviewer returns** structured findings (CRITICAL / MAJOR / MINOR /
   CONFIRMED CORRECT + verdict + convergence flag). It does **NOT** edit
   anything — that keeps you as the synthesizer and stops it making questionable
   changes.
4. **You verify, then apply.** Before applying any fact-correction, **verify it
   yourself** — especially statutory citations, manual IDs, rates, API facts.
   WebFetch the cited source and confirm it actually says what's claimed. Then
   fix the source (and the snapshot, if live data).
5. **Log the round** — round table (C/M/MINOR counts per round), findings→fixes,
   and headline shifts before/after.
6. **Iterate** with a fresh reviewer until **0 CRITICAL + 0 MAJOR**; run one
   confirm round, then mark the log converged.
7. **Separate USER decisions from findings.** When the review surfaces a genuine
   choice (trade-off, judgement call), present it to the user — don't silently
   resolve it as a "fix."

## Reviewer prompt template

Customize the bracketed parts per artifact. Keep the structure verbatim.

```
You are a brutal, adversarial reviewer with deep knowledge of <DOMAIN — be
specific, e.g. "UK inheritance tax + STEP practice", "distributed-systems
consistency", "applied cryptography">.

You have NO prior context. Treat this as a first-time review. Be hostile and
rigorous.

Review this: <ABSOLUTE PATH or pasted artifact>
Brief context: <2-3 sentences — what it's for and that the user will ACT on it>.
Already addressed in prior rounds (do NOT just re-confirm unless now wrong):
<bulleted TYPES of issues, not the prior reviewer's verbatim findings>.

Your job: find ANYTHING remaining. Be hostile. If genuinely no material issue
remains, SAY SO EXPLICITLY — that is the stopping signal; do NOT manufacture
findings.

Check specifically for:
1. Factual errors vs authoritative sources — use WebSearch/WebFetch. For every
   claim with a number or a specific rule, verify it. If a specific citation /
   manual ID / API guarantee is given, FETCH it and confirm it says what's
   claimed (bad citations are worse than none).
2. Arithmetic — recompute every load-bearing figure; show working on a
   discrepancy. Does the stated total actually reconcile?
3. Methodology — assumptions, framing, comparisons. Watch real-vs-nominal,
   gross-vs-net, per-X-vs-total, final-value-vs-gain, double-counting.
4. Internal consistency — do sections and cross-references agree? Do dates and
   figures match across the artifact?
5. Missing considerations — anything material left out.
6. Clarity — only where it materially affects understanding.

Return EXACTLY:
# Round N Findings — <Name>
## CRITICAL (factually wrong or arithmetically incorrect)
- [Finding]: <description>. Evidence/working: <...>. Suggested fix: <...>
## MAJOR (methodology or significant omission)
## MINOR (clarity, presentation, small omissions)
## CONFIRMED CORRECT
- [Item]: verified against <source/URL>
## SUMMARY
- Critical: X | Major: Y | Minor: Z | Confirmed: W
- Verdict: <sound as-is / needs minor fixes / needs major rework>
- Convergence: <CONVERGED (0+0) / NOT converged>

Cite source URLs for every external claim. Do NOT edit anything. No preamble,
no politeness — only the structured findings.
```

## Stopping criteria

Stop when **either**: a round returns 0 critical + 0 major (run one confirm
round, then finalize the minors), **or** rounds repeat the same findings without
converging — that signals the methodology needs rethinking, not more polish.

## Lessons (load-bearing — these were caught the hard way)

- **Bad citations are worse than no citations.** Manual IDs / statute refs added
  without fetching them got caught a round later and would have destroyed trust.
  Always WebFetch a cited page before trusting it.
- **Don't trust the reviewer's own facts either** — verify its corrections
  before applying, especially statutory/rate/API claims.
- **Unit errors reverse conclusions** — real-vs-nominal, gross-vs-net,
  per-recipient-vs-total, final-value-vs-gain. Restate both sides in the same
  basis before comparing.
- **Pass forward TYPES, not verbatim findings** — verbatim biases the next
  reviewer toward agreement.
- **One fresh reviewer per round.** Parallelize only across genuinely
  independent artifacts (`run_in_background`).
- **Keep snapshot + live source + any referencing hub in sync** — a fix that
  touches one but not the others becomes next round's "internal inconsistency."

## Building a domain specialization

For a recurring target with a fixed domain, write a thin companion skill instead
of re-customizing each time. It should (1) name its domain + authoritative
sources, (2) describe how to snapshot its specific target, (3) say "then run the
adversarial-review loop," and (4) add any domain disclaimer. Don't re-document
the loop — delegate to this skill.
