# Plan template

Copy this into the plan file and fill it in. Keep it short enough that a
reviewer reads all of it. Delete a section only if it truly has nothing to say.

```markdown
# Plan: <one-line title>

## Request
What was asked, in the user's words, and what you take it to mean. If it reads
two ways, say which reading you took.

## Findings
What exploration showed. File paths with line numbers.
- How the area works today:
- Existing code to reuse:
- Conventions to follow:
- Commands: typecheck `…`, lint `…`, build `…`, test `…`, run `…`

## Approach
The design in a few sentences, then why this and not the obvious alternative.

## Out of scope
What this change deliberately does not do.

## Steps
Ordered, each one bounded. Name the files.
1.
2.

## Tests
| Level | What it covers | File |
|-------|----------------|------|
| Unit | | |
| Integration | | |
| End-to-end | | |
For a level with no tests, write "n/a" and the reason.

## Acceptance criteria
Each one observable: a command with expected output, or a behaviour to watch.
- [ ] AC1:
- [ ] AC2:

## Evidence to capture
The screenshots, recording or terminal output that will prove each criterion.

## Risks and assumptions
What could be wrong, and what you are assuming without having verified.

## Challenge outcome
Filled in after gate 4. One line per objection: accepted (and what changed) or
rejected (and why).

## Deviations
Filled in during the build. What changed from the plan and why.
```
