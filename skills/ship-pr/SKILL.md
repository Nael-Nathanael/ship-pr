---
name: ship-pr
description: End-to-end delivery workflow for any code change, where the definition of done is an open pull request with proof attached. Covers branching off the default branch, exploring the codebase, writing a plan, having an independent reviewer challenge the plan (or, for a small change, the finished PR), implementing against a checklist with unit, integration and end-to-end tests, cross-checking the result against the plan, walking through the running app in a browser, and opening a PR with marked-up screenshots, plus a GIF or video when the user flow changes. Use this skill whenever the user asks to build, implement, add, fix, refactor or change something in a git repository and expects finished work, even when they never mention a PR, tests or a plan, and whenever they say "ship it", "open a PR", "make a PR" or "finish this ticket". Skip it only for questions, explanations, code review of someone else's work, and throwaway experiments the user says not to commit.
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/preflight.sh:*)
license: MIT
compatibility: Needs git, shell access and a forge CLI (gh, glab or equivalent). Browser automation (Playwright) and ffmpeg are used for UI evidence when available.
metadata:
  version: "1.1.0"
---

# ship-pr

A change is done when a reviewer can open one pull request, understand it
without asking you anything, and see proof that it works. Everything before
that is progress. This skill is the path from request to that PR.

## The task

The task is the text the user gave with this skill: `/ship-pr add a tip field
to the bill form`, `$ship-pr fix the rounding bug`, or the request in the
message that triggered it. It can be a sentence, an issue number or URL, or a
ticket pasted in. If it is an issue reference, read the issue first, then
claim it before gate 1. If no task was given, ask for one in a single question
before doing anything else.

### Claim the issue first

When the task comes from an issue, claim it before any other work, so nobody
else starts the same thing:

1. **Already taken?** If the issue has an assignee other than you, or a recent
   comment from someone saying they are on it, stop and ask the user.
2. **The repo's way.** If the repo documents a claim command (a `/claim`
   comment, a bot, a label), use it. Check `CONTRIBUTING.md`, the issue
   templates and `.github/workflows/` for it.
3. **Otherwise assign yourself:** `gh issue edit <n> --add-assignee @me`
   (or the forge's equivalent).
4. **No permission to assign** (a project you do not maintain): comment on the
   issue that you are working on it, and follow any rule the project has
   about asking first.

Confirm the claim took: re-read the issue's assignees or the bot's reply.
Link the issue in the PR so the claim closes with it.

## The gates

Eight gates, in order. Gates 4 and 8 depend on the lane, chosen after gate 2
(see [Pick the lane](#pick-the-lane-after-gate-2)). Each one produces
something a person can inspect.

| # | Gate | What exists afterwards |
|---|------|------------------------|
| 1 | Branch | A work branch cut from the up-to-date default branch |
| 2 | Explore | Notes on what already exists and what can be reused |
| 3 | Plan | A written plan file with acceptance criteria |
| 4 | Challenge | Full lane: an independent review of the plan, and the plan revised |
| 5 | Build | Code and tests, driven from a visible task checklist |
| 6 | Prove | Checks pass, plan cross-checked, app walked through, evidence captured |
| 7 | Publish | An open PR whose description carries the evidence |
| 8 | Contest | Light lane, and open-source projects you do not maintain: an independent review of the open PR, and the PR revised |

Do not describe the work as done, finished, complete or ready until the last
gate that applies (7, or 8 when gate 8 applies) has passed and you have
re-read the PR as a reviewer would. Before that, report
status honestly: "Gate 5: implementation finished, tests not yet run."
The word "done" tells the user they can stop paying attention, so using it
early costs them a broken handoff.

A gate that truly does not apply (no UI, so no browser walkthrough) is passed
by saying so in the PR with the reason. A gate that applies but could not be
completed is a blocker: see [When a gate cannot pass](#when-a-gate-cannot-pass).

### The repository's own rules win

Before starting, read what the repo says about contributing: agent
instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
`.github/copilot-instructions.md`, `.cursor/rules/`), `CONTRIBUTING.md`, the
PR template, branch naming, commit style.
Where those conflict with this skill, follow the repo. This skill supplies the
order of work and the bar for proof; the repo supplies its conventions. The
user's own global instructions win over this skill the same way.

### Keep working files out of the diff

The plan, the challenge report and raw evidence are working files. Unless the
repo already has a home for plans, keep them in a directory git will not track:

```bash
WORK="$(git rev-parse --path-format=absolute --git-path ship-pr)"; mkdir -p "$WORK"
```

This lives inside `.git`, so it is never committed, and each worktree gets its
own. It needs git 2.31 or later.

### Pick the lane after gate 2

The written plan and its review are most of this workflow's cost. A small,
contained change does not earn that back, so it gets its one independent
review on the finished diff instead of on a plan. Choose the lane once
exploration shows what the change touches, tell the user which lane and why
in one line, and name the lane in the PR's collapsed proof block.

**Light lane**, when all of these hold:

- 50 changed lines of non-test code or fewer, in one directory or feature.
- No change to: a data schema or migration; authentication or permissions;
  money; secrets or cryptography; personal data; deleting or overwriting
  stored data; input handling at a trust boundary; dependencies; CI, build or
  deploy config; or a public interface (an exported function, CLI flag, HTTP
  route, config key, file format or event that code outside the change, or
  other people, rely on).
- The request reads one way, and exploration found no surprise.
- You maintain the base repository: `viewerPermission` is `WRITE`, `MAINTAIN`
  or `ADMIN`. Elsewhere a rejected approach costs a review round that may
  never come, so the plan is reviewed first.
- An independent reviewer is available for gate 8, which does not accept
  self-review.

**Full lane** for everything else, and whenever you are unsure.

What the light lane changes:

- Gate 3: the plan holds only Findings (a few lines: the commands, and why
  this lane), Request, Steps, Tests and Acceptance criteria, plus Deviations
  if the build departs from them.
- Gate 4 does not run.
- Gate 8 runs, so the review reads the real diff.

Nothing else changes: the branch, tests that fail without the change, every
check in gate 6, and the PR. If a light-lane condition stops holding during
the build, stop, complete the plan, run gate 4 on it, and continue in the full
lane. The gate 6 cross-check tests the finished diff against these conditions
once more.

Within a lane, depth scales with the change: exploration may be one search,
the plan ten lines, the challenge a short review, the evidence one test run.

Use `$WORK/plan.md`, `$WORK/challenge.md` and `$WORK/evidence/` throughout. If
your harness has its own plan file or plan mode, use that for the plan instead.

## Gate 0: Preflight

The dependency check runs before anything else. In Claude Code it already ran
when this skill loaded, and its result is here:

!`bash ${CLAUDE_SKILL_DIR}/scripts/preflight.sh || true`

If the line above still shows the command rather than its output, run
`bash <skill-dir>/scripts/preflight.sh` yourself from the repository root, and
again with `--ui` once the plan shows a UI change (it makes the
browser-evidence tools required).

It prints `ok`, `warn` or `MISSING` per tool, each with the fix command, and
ends with `preflight: FAILED` (exit 1) when something required is missing.

- On `FAILED`, stop and show the user the `MISSING` lines with their fix
  commands. Ask before running any of them: installing software changes their
  machine. Run the check again after they are fixed.
- Project-level installs the repo already expects, such as
  `npx playwright install chromium` in a repo that has Playwright as a
  dependency, you may run without asking.
- `warn` lines do not block, but each one becomes a gap you must name in the
  PR if it stops a gate from passing.

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
did not make, stop and ask; they belong to someone. If the checkout is shared,
live (a tool runs from it) or used by another session, work in a worktree on
disk instead of switching it, and remove the worktree once the branch merges:

```bash
git worktree add <disk-path>/<repo>/<branch> -b <type>/<short-topic> "origin/$DEFAULT"
```

Never commit to the
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

- Whether someone is already doing this work. Search open and recently
  closed PRs and issues for the feature, the bug and the files involved
  (`gh pr list --state all --search "<terms>"`, `gh issue list --search
  "<terms>"`, or the forge's equivalent). After PRs nobody reviews,
  duplicates are the most common reason agent PRs go unmerged.
  If you find one, stop and tell the user before planning.
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

Write `$WORK/plan.md` using [references/plan-template.md](references/plan-template.md);
in the light lane, only the sections it marks as always needed. The plan is
what you will be checked against at gate 6, so its acceptance
criteria must be observable: a command and its expected output, or a behaviour
someone can watch happen.

Design to YAGNI, reuse first, DRY, high cohesion with low coupling, and the
right tool for the job, as set out in
[references/design-principles.md](references/design-principles.md).

Ask the user only what exploration could not answer: choices that depend on
their priorities, or changes to existing behaviour others rely on.

## Gate 4: Challenge

Full lane only. A plan reviewed only by its author keeps the author's blind
spots. Hand it to
a reviewer with none of your context, whose job is to find what is wrong with
it. [references/challenge-brief.md](references/challenge-brief.md) has who may
review, the prompt, and how to handle the report. Give the reviewer no
conclusion of yours; one handed a conclusion tends to return it confirmed.
Save its report to `$WORK/challenge.md`.

Then go through every objection and either change the plan or write one line
saying why not. Add the outcome to the plan under "Challenge outcome". Accepting
everything without thought is as weak as dismissing everything.

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

Write tests at every level the change reaches (unit, integration, end-to-end).
Which levels apply, and how to write each, is in
[references/testing.md](references/testing.md). Use the repo's existing test framework and helpers. A bug fix gets a test that
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

In the light lane, also check the finished diff against the light-lane
conditions; if one no longer holds, run gate 4's review on the plan and the
diff now.

Write the result once, in the PR's collapsed proof block: the proof for each
criterion, and the unplanned files or "none".

**3. Run it.** Start the application locally and use the change the way a user
would. For anything with a UI, drive a real browser through the affected flow
with Playwright (the Playwright MCP tools, or a script), including the setup
steps a user would do, plus at least one failure path. Follow
[references/evidence.md](references/evidence.md) to capture screenshots as you
go, each with a red box around what changed, and a recording when the change
alters the user flow. For a change with no UI, the evidence is terminal output:
the command, and what it printed, before and after; of evidence.md you then
need only "What to capture" and the attaching section for your forge.

If the walkthrough finds a bug, fix it, re-run the tests that cover the fix,
and capture again whatever the fix changed on screen. When the walkthrough is
clean, run check 1 once more if any code changed since its last run: the
results in the PR must come from the final code.

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

This gate applies in two cases. In the light lane, where it is the change's
one independent review. And when the PR's base repository is public and the
user is not one of its maintainers:
`gh repo view <base> --json visibility,viewerPermission` shows `PUBLIC` and a
permission of `READ`, `TRIAGE` or none. Otherwise skip it; nothing needs
saying in the PR.

A review of the open PR that the harness or the user's own rules already
require counts as this gate, with no second one, only when it meets the same
bar: it runs before your final report, in a fresh context, on the same model
as you or a stronger one, with the contest prompt or an equivalent, and you
handle its findings as contest-brief.md says. An automatic bot review does
not count.

A maintainer of an open-source project owes you nothing and has minutes for a
stranger's PR. Each problem they find costs a review round that may never
come. Find those problems first: hand the open PR to a reviewer that has none
of your context and whose job is to reject it.

[references/contest-brief.md](references/contest-brief.md) has who may review
(same model as you, never a cheaper default; name it in your report), the
read-only prompt, and how to handle the report. Do not give the reviewer your
reasoning, the plan or the gate 4 report. Save its report to `$WORK/contest.md`.

Then go through every finding and either fix it or write one line saying why
not. Fixes are new commits on the same branch; do not rewrite pushed history.
Re-run the tests that cover each fix and recapture the evidence it changed;
after the last fix, run gate 6's check 1 once on the final code and update
the results in the PR. Re-read the PR only if its description changed. A finding that turns on
something only the user can decide goes to the user before you act on it.

Run one round, and a second only when the fixes changed the design.

## Reporting

The final message gives, in this order: the PR
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
