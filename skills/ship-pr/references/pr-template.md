# PR description

Short and plain. A reader should know what changed and see it working in under
a minute. Proof that the work was checked goes in a collapsed block at the end.

If the repo has a PR template, fill that in the same way and add the evidence and
the collapsed proof block.

## Title

One line saying what changes for the user or the system, in the repo's commit
style. "Add CSV export to the orders table", not "Update OrdersTable.tsx".

## Body

```markdown
<One to three sentences: what a user can do now, or what was broken and now
works, and why. Link the issue.>

![Short description](path-or-url)

<What the red box shows, in one line.>

<Recording, only when the user flow changed:>

path-or-url-on-its-own-line

**Try it:** 1. … 2. … 3. …

**Note:** <only when there is one: a risk, a deploy step, a migration, a
config change, something not verified.>

<details>
<summary>Tests and plan check</summary>

- Unit: 12 passed. Integration: 4 passed. End-to-end: 2 passed.
- Typecheck, lint, build: clean.
- Each acceptance criterion from the plan is met; proof for each: AC1
  screenshot above, AC2 `orders.e2e.ts`.
- Any level marked n/a, any deviation from the plan, and pre-existing
  failures, each with one line of why.

</details>
```

For a change with no UI, the evidence is the command and its output in a code
block, in place of the screenshot.

## Rules

- No headings above the evidence. The summary and the screenshot are the first
  thing on the page.
- Plain words. No file names, function names or class names in the summary;
  say what it does, not where it lives.
- Leave out how it was built unless a reviewer would question a decision. Then
  one sentence in the Note, with the reason.
- No describing your own process outside the collapsed block: no "I
  explored", "the plan was challenged".
- Everything outside the collapsed block fits on one screen.
- Leave out Try it and Note when they have nothing to say. The evidence and the
  collapsed block always appear.

## Before opening

- Someone outside the team could say what this PR does from the first lines.
- Every claim ("tests pass", "works on mobile") has output or an image behind
  it.
- No secrets, tokens, internal hostnames or personal data in text or images.
- The diff contains only this change.

## Draft or ready

Open as ready for review when every gate passed. Open as a draft when a gate
is blocked, with one line at the top saying what is missing.
