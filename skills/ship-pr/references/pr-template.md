# PR description

If the repo has a PR template, fill that in and add the Evidence, Testing and
Plan cross-check sections from below. Otherwise use this.

## Title

One line saying what changes for the user or the system, in the repo's commit
style. "Add CSV export to the orders table", not "Update OrdersTable.tsx".

## Body

Write for someone who has not seen the ticket and does not know this part of
the code. Plain words first, detail after. No filler, no describing your own
process.

```markdown
## What and why
Two to four sentences. What a user or developer can do now that they could
not before, or what was broken and now works. Why it was needed. Link the
issue or ticket.

## Evidence
![Short description of the screenshot](path-or-url)

Recording of the full flow:

path-or-url-on-its-own-line

| Before | After |
| --- | --- |
| ![Before](path-or-url) | ![After](path-or-url) |

For non-UI changes, the command and its output in a code block.

## How it works
The approach in a short paragraph or a few bullets: what was added or changed,
what existing code it reuses, and any decision a reviewer might question, with
the reason.

## Testing
| Level | What is covered | Result |
| --- | --- | --- |
| Unit | … | 12 passed |
| Integration | … | 4 passed |
| End-to-end | … | 2 passed |
| Manual walkthrough | Flow walked in a browser, including <failure path> | See evidence |

Checks run: `<typecheck>`, `<lint>`, `<build>`, `<test>`, with the summary
line of each. For any level marked n/a, the reason.

## Plan cross-check
| Acceptance criterion | Status | Proof |
| --- | --- | --- |
| AC1: … | Met | Screenshot 2, `orders.e2e.ts` |

Deviations from the plan, and why. Whether the plan was challenged by an
independent reviewer, and the changes that came from it.

## How to review
Where to start reading, and steps to try it locally:
1. …

## Notes
Anything not verified and why. Risks, migrations, config or environment
changes needed on deploy. Follow-ups noticed but left out of this change.
Pre-existing failures, with proof they exist on the default branch.
```

Leave out a section that has nothing to say, except Evidence, Testing and Plan
cross-check, which always appear.

## Before opening

- A person outside the team could say what this PR does after reading the
  first section.
- Evidence appears in the first screenful or just below it.
- Every claim ("tests pass", "works on mobile") has output or an image behind it.
- No secrets, tokens, internal hostnames or personal data in text or images.
- The diff contains only this change.

## Draft or ready

Open as ready for review when every gate passed. Open as a draft when a gate
is blocked, with what is missing at the top of the description.
