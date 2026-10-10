---
name: ship-pr
description: End-to-end delivery workflow for any code change, where the definition of done is an open pull request with proof attached. Covers branching off the default branch, exploring the codebase, writing a plan, having an independent reviewer challenge that plan, implementing against a checklist with unit, integration and end-to-end tests, cross-checking the result against the plan, walking through the running app in a browser, and opening a PR with marked-up screenshots, plus a GIF or video when the user flow changes. Use this skill whenever the user asks to build, implement, add, fix, refactor or change something in a git repository and expects finished work, even when they never mention a PR, tests or a plan, and whenever they say "ship it", "open a PR", "make a PR" or "finish this ticket". Skip it only for questions, explanations, code review of someone else's work, and throwaway experiments the user says not to commit.
argument-hint: <task>
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/preflight.sh:*)
license: MIT
compatibility: Needs git, shell access and a forge CLI (gh, glab or equivalent). Browser automation (Playwright) and ffmpeg are used for UI evidence when available.
metadata:
  version: "1.0.0"
---

# ship-pr

A change is done when a reviewer can open one pull request, understand it
without asking you anything, and see proof that it works. Everything before
that is progress. This skill is the path from request to that PR.

Passing tests on a local branch is not the finish line, because nobody else can
see it, review it or merge it. Work that stops there gets lost or redone.

## The task

The task is the text the user gave with this skill: `/ship-pr add a tip field
to the bill form`, `$ship-pr fix the rounding bug`, or the request in the
message that triggered it. It can be a sentence, an issue number or URL, or a
ticket pasted in. If it is an issue reference, read the issue first. If no task
was given, ask for one in a single question before doing anything else.

## The gates

Seven gates, in order, and an eighth when the PR goes to an open-source
project. Each one produces something a person can inspect.

| # | Gate | What exists afterwards |
|---|------|------------------------|
| 1 | Branch | A work branch cut from the up-to-date default branch |
| 2 | Explore | Notes on what already exists and what can be reused |
| 3 | Plan | A written plan file with acceptance criteria |
| 4 | Challenge | An independent review of the plan, and the plan revised |
| 5 | Build | Code and tests, driven from a visible task checklist |
| 6 | Prove | Checks pass, plan cross-checked, app walked through, evidence captured |
| 7 | Publish | An open PR whose description carries the evidence |
| 8 | Contest | Open-source projects only: an independent review of the open PR, and the PR revised |

Do not describe the work as done, finished, complete or ready until the last
gate that applies (7, or 8 for an open-source project) has passed and you have
re-read the PR as a reviewer would. Before that, report
status honestly: "Gate 5 of 7: implementation finished, tests not yet run."
The word "done" tells the user they can stop paying attention, so using it
early costs them a broken handoff.

A gate that truly does not apply (no UI, so no browser walkthrough) is passed
by saying so in the PR with the reason. A gate that applies but could not be
completed is a blocker: open the PR as a draft, state what is missing, and
report the work as not done. See [When a gate cannot pass](#when-a-gate-cannot-pass).

### The repository's own rules win

Before starting, read what the repo says about contributing: `AGENTS.md`,
`CLAUDE.md`, `CONTRIBUTING.md`, the PR template, branch naming, commit style.
Where those conflict with this skill, follow the repo. This skill supplies the
order of work and the bar for proof; the repo supplies its conventions.

### Keep working files out of the diff

The plan, the challenge report and raw evidence are working files. Unless the
repo already has a home for plans, keep them in a directory git will not track:

```bash
WORK="$(git rev-parse --path-format=absolute --git-path ship-pr)"; mkdir -p "$WORK"
```

This lives inside `.git`, so it is never committed, and each worktree gets its
own. It needs git 2.31 or later.

### Scale depth, never skip gates

A one-line fix and a new feature go through the same gates; what changes
is how much each gate takes. For a small change, exploration may be one search,
the plan ten lines, the challenge a short review, the evidence one test run.
What does not shrink: the branch, the tests that prove it, and the PR.

Use `$WORK/plan.md`, `$WORK/challenge.md` and `$WORK/evidence/` throughout. If
your harness has its own plan file or plan mode, use that for the plan instead.

## Gate 0: Preflight

The dependency check runs before anything else. In Claude Code it already ran
when this skill loaded, and its result is here:

!`bash ${CLAUDE_SKILL_DIR}/scripts/preflight.sh`

If the line above still shows the command rather than its output, your agent
did not run it: run it yourself from the repository root, with the path
resolved to this skill's folder:

```bash
bash <skill-dir>/scripts/preflight.sh
```

Run it again with `--ui` once the plan shows the change touches a UI, since
that makes the browser-evidence tools required.

It prints `ok`, `warn` or `MISSING` per tool, each with the fix command, and
exits 1 when something required is missing.

- On exit 1, stop and show the user the `MISSING` lines with their fix
  commands. Ask before running any of them: installing software changes their
  machine. Run the check again after they are fixed.
- Project-level installs the repo already expects, such as
  `npx playwright install chromium` in a repo that has Playwright as a
  dependency, you may run without asking.
- `warn` lines do not block, but each one becomes a gap you must name in the
  PR if it stops a gate from passing.

The check takes seconds, and a missing `gh` found here costs a minute. Found
at gate 7, after an hour of work, it costs the evidence.

## Gate 1: Branch

```bash
git fetch origin
DEFAULT="$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')"
git switch -c <type>/<short-topic> "origin/$DEFAULT"
```

If `origin/HEAD` is unset, run `git remote set-head origin --auto` first.
Name the branch the way the repo already names them (look at
`git branch -r`); otherwise `feat/…`, `fix/…`, `chore/…`.

Check the working tree before switching. If there are uncommitted changes you
did not make, stop and ask; they belong to someone. Never commit to the
default branch, because the PR is the review step and a direct commit skips it.

Two setups need a different start:

- **No remote.** Branch from the local default branch and tell the user now
  that gate 7 cannot pass until a remote exists.
- **No push access to the repo (a fork workflow).** Push the branch to your
  fork and open the PR against upstream with `gh pr create --repo <upstream>`.
  Some media upload methods need push access to the base repo; see
  [references/evidence.md](references/evidence.md).

One branch carries one reviewable change. If the request is several unrelated
changes, or too large to review in one sitting, split it into slices that each
deliver one complete user flow, and take each slice through every gate.

## Gate 2: Explore

Read before you design. The most common waste is writing something the
codebase already has. Find out:

- How the affected area works today, traced from entry point to effect.
- What already exists that you can call or extend: helpers, components,
  hooks, services, types, fixtures, test utilities.
- The conventions in force: structure, naming, error handling, how tests are
  written and run.
- The real commands for typecheck, lint, build, test and running the app.
  Read them from the manifest, Makefile or CI config. Do not assume.
- For any library or API you will touch, the current documentation for the
  installed version, not what you remember.

Use read-only search subagents for wide searches if your harness has them, so
the main context keeps the conclusions and not the file dumps.

Write the findings at the top of the plan. If exploration shows the request
rests on a wrong premise, or a much cheaper route exists, tell the user now.

## Gate 3: Plan

Write `$WORK/plan.md` using [references/plan-template.md](references/plan-template.md).
The plan is what you will be checked against at gate 6, so its acceptance
criteria must be observable: a command and its expected output, or a behaviour
someone can watch happen.

Design to these principles. Full reasoning and examples are in
[references/design-principles.md](references/design-principles.md).

- **YAGNI.** Build what the request needs. No options, layers or extension
  points for requirements nobody has stated.
- **Reuse first.** Prefer, in order: what the codebase has, the standard
  library, the platform, an installed dependency, a new dependency, new code.
- **DRY.** One piece of knowledge lives in one place.
- **High cohesion, low coupling.** Each module does one thing; modules know
  as little about each other as they can.
- **Right tool for the job.** Use what the stack already provides for the
  problem before building around it.

Ask the user only what exploration could not answer: choices that depend on
their priorities, or changes to existing behaviour others rely on.

## Gate 4: Challenge

A plan reviewed only by its author keeps the author's blind spots. Hand it to
a reviewer that has none of your context and whose job is to find what is
wrong with it.

- The reviewer runs on the same model as you or a stronger one, in a fresh
  context: a subagent, a second session, or a different agent CLI.
- Give it the plan file and read access to the repo. Do not give it your
  reasoning or tell it what you expect; a reviewer handed a conclusion tends
  to return it confirmed.
- Use the brief in [references/challenge-brief.md](references/challenge-brief.md).
- Save its report to `$WORK/challenge.md`.

Then go through every objection and either change the plan or write one line
saying why not. Add the outcome to the plan under "Challenge outcome". Accepting
everything without thought is as weak as dismissing everything.

If no independent reviewer is possible in your environment, write the
adversarial review yourself against the same brief, and say in the PR that the
challenge was not independent. Do not present a self-review as an independent one.

## Gate 5: Build

Before editing any code, turn the plan into a task checklist in your harness's
task or todo tool (or a checklist in `$WORK/plan.md` if there is none). One
item per bounded step, tests included as their own items, one item in progress
at a time, each ticked as it finishes. The checklist is how the user sees
where you are without asking, and how you avoid dropping a step.

While building:

- Follow the plan. If reality forces a deviation, update the plan file and
  note why. A plan that no longer matches the code cannot be cross-checked.
- Touch only what the change needs. Note unrelated problems for the PR's
  follow-ups section; do not fix them in this diff.
- Match the surrounding code's style and comment density.
- Commit in logical steps with messages that describe the change.

### Tests

Write tests at every level the change reaches. Which levels apply, and how to
write each, is in [references/testing.md](references/testing.md). In short:

| Level | Write it when the change… |
|-------|---------------------------|
| Unit | adds or alters logic with branches, calculations, parsing or edge cases |
| Integration | crosses a boundary: database, HTTP handler, queue, another module or service |
| End-to-end | alters something a user does through the interface |

Use the repo's existing test framework and helpers. A bug fix gets a test that
fails before the fix and passes after it. If a level does not apply, the PR
says which and why; "not applicable" is a claim a reviewer can check, silence
is not.

## Gate 6: Prove

Four checks. Paste real output; "should work" proves nothing.

**1. Project checks.** Run typecheck, lint, build and the full test suite using
the repo's real commands. Fix what your change broke. Failures that were
already there before your branch are listed in the PR as pre-existing, with
evidence (the same failure on the default branch), not folded into your diff.

**2. Cross-check against the plan.** Open `$WORK/plan.md` and go down it line by
line against `git diff "origin/$DEFAULT"...HEAD`:

- Each acceptance criterion: met, with the evidence that shows it.
- Each planned step: implemented, or deliberately dropped with a reason.
- Each changed file: accounted for by the plan. Unplanned changes are either
  justified in the plan or reverted.

Record the result in `$WORK/plan.md`; a short summary goes into the PR's
collapsed proof block.

**3. Run it.** Start the application locally and use the change the way a user
would. For anything with a UI, drive a real browser through the affected flow
with Playwright (the Playwright MCP tools, or a script), including the setup
steps a user would do, plus at least one failure path. Follow
[references/evidence.md](references/evidence.md) to capture screenshots as you
go, each with a red box around what changed, and a recording when the change
alters the user flow. For a change with no UI, the evidence is terminal output:
the command, and what it printed, before and after.

If the walkthrough finds a bug, fix it, re-run the checks, and capture again.
Evidence must show the final code.

**4. Clean up.** Stop servers you started, remove temporary files and debug
output, and confirm `git status` shows only what you intend to ship.

## Gate 7: Publish

Push the branch and open the PR against the default branch. Write the
description from [references/pr-template.md](references/pr-template.md), unless
the repo has its own template, in which case fill that in and add the evidence
and the collapsed proof block to it.

Keep it short and plain: a few sentences on what changed for the user and why,
then the evidence. Test results and the plan cross-check go in a collapsed
block at the end. No implementation walkthrough.

Attaching media from a terminal differs by forge and CLI version;
[references/evidence.md](references/evidence.md) has the working method for
each and the fallbacks. After the PR is open, fetch it and confirm the images
and any recording actually render. An upload that returned success but shows a
broken image is not evidence.

Then re-read the PR as a stranger would, fix what is unclear, and check CI if
the repo has it. Do not merge; merging is the reviewer's decision.

## Gate 8: Contest

This gate applies when the PR's base repository is public
(`gh repo view <base> --json visibility`). Otherwise skip it; nothing needs
saying in the PR.

A maintainer of an open-source project owes you nothing and has minutes for a
stranger's PR. Each problem they find costs a review round that may never
come. Find those problems first: hand the open PR to a reviewer that has none
of your context and whose job is to reject it.

- The reviewer runs on the highest-tier model your harness can reach, in a
  fresh context: a subagent with its model set explicitly, a second session,
  or a different agent CLI. Do not let it default to a cheaper model. Say in
  your report which model reviewed.
- Give it the PR and read access to the code. Do not give it your reasoning,
  the plan or the gate 4 report.
- It is read-only and stays local: no commits, no pushes, no comments or
  reviews posted on the forge.
- Use the brief in [references/contest-brief.md](references/contest-brief.md).
- Save its report to `$WORK/contest.md`.

Then go through every finding and either fix it or write one line saying why
not. Fixes are new commits on the same branch, re-proved as in gate 6; do not
rewrite pushed history. Update the PR description where a fix changes what it
says, and re-read the PR once more. A finding that turns on something only the
user can decide goes to the user before you act on it.

Run one round, and a second only when the fixes changed the design.

## Reporting

Only now say the work is done. The final message gives, in this order: the PR
link, one or two sentences on what now works, how it was verified, and
anything the reviewer should know (skipped gates with reasons, follow-ups,
pre-existing failures). After gate 8, add what the contest found: what was
fixed, and what was rejected and why.

### When a gate cannot pass

Things that block: no push access, no forge CLI auth, the app cannot be run
locally, a required secret is missing, a test environment is down.

1. Try to get past it with what you have: read the setup docs, check for a
   documented alternative, retry transient failures.
2. If it stays blocked, do every gate that is still possible. Open the PR as a
   draft when you can, with a "Not verified" section naming what was not
   proven and why.
3. Report it as not done, name the blocked gate, and say exactly what the user
   needs to do to unblock it.

Never fake a gate: no invented output, no screenshots of something other than
the final code, no "tests pass" without a run. A clearly reported gap can be
fixed by the user in minutes; a hidden one is found in production.

## Reference files

- [references/plan-template.md](references/plan-template.md): the plan file. Read at gate 3.
- [references/design-principles.md](references/design-principles.md): what each principle means in practice and when it is misapplied. Read at gate 3.
- [references/challenge-brief.md](references/challenge-brief.md): the reviewer's prompt. Read at gate 4.
- [references/testing.md](references/testing.md): choosing and writing tests per level. Read at gate 5.
- [references/evidence.md](references/evidence.md): capturing and attaching screenshots and recordings. Read at gates 6 and 7.
- [references/pr-template.md](references/pr-template.md): the PR description. Read at gate 7.
- [references/contest-brief.md](references/contest-brief.md): the PR reviewer's prompt. Read at gate 8.
- [references/origin.md](references/origin.md): the original statement of this workflow.
