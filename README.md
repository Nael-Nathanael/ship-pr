# ship-pr

An agent skill for delivering code changes. The agent counts a task as done
only when there is an open pull request that a reviewer can understand without
asking questions, with screenshots, a recording or terminal output showing the
change works.

It works with any agent that reads the [Agent Skills](https://agentskills.io)
format: Claude Code, Codex CLI, Gemini CLI, Cursor, GitHub Copilot, OpenCode,
Windsurf and Antigravity.

## What the agent does

| # | Gate | Result |
|---|------|--------|
| 1 | Branch | Work branch cut from the up-to-date default branch |
| 2 | Explore | What exists already and what can be reused |
| 3 | Plan | Plan file with checkable acceptance criteria |
| 4 | Challenge | An independent reviewer attacks the plan; the plan is revised |
| 5 | Build | Code plus unit, integration and end-to-end tests, worked from a task checklist |
| 6 | Prove | Checks pass, result compared with the plan, app walked through in a browser |
| 7 | Publish | Open PR with the evidence in the description |
| 8 | Contest | Open-source projects only: a reviewer on the strongest available model attacks the open PR; the PR is revised |

Until the last gate passes, the agent reports progress, not "done". If a gate is
blocked, it opens a draft PR and says what is missing.

## Install

Any supported agent, with the [skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add Nael-Nathanael/ship-pr          # this project
npx skills add Nael-Nathanael/ship-pr -g       # all your projects
```

Or copy `skills/ship-pr/` into your agent's skills directory:
`.agents/skills/` for most agents, `.claude/skills/` for Claude Code.

## Use

```
/ship-pr add a tip field to the checkout form
/ship-pr fix #142
```

That is `/ship-pr <task>` in Claude Code, Cursor and Antigravity, and
`$ship-pr <task>` in Codex. The task can be a sentence, an issue number or URL,
or a pasted ticket. Agents also pick the skill up on their own for build, fix
and refactor requests.

## What the agent needs

The skill checks these itself before starting (`scripts/preflight.sh`). If a
required tool is missing, the agent stops, shows the install command, and asks
before installing anything. To check your machine yourself, run this from any
repo:

```bash
bash ~/.agents/skills/ship-pr/scripts/preflight.sh --ui
```

The path depends on where your agent keeps skills; `.claude/skills/` for Claude Code.

- git, and a forge CLI that is logged in: `gh` for GitHub, `glab` or an API
  token for GitLab.
- `gh` 2.99.0 or later to attach screenshots and video to a GitHub PR. Older
  versions fall back to a workaround described in
  [`references/evidence.md`](skills/ship-pr/references/evidence.md).
- Playwright and ffmpeg for UI evidence. Without them the agent says so in the PR.

## Files

```
skills/ship-pr/
  SKILL.md                     the workflow
  references/
    origin.md                  the original one-paragraph brief
    plan-template.md           gate 3
    design-principles.md       gate 3
    challenge-brief.md         gate 4
    testing.md                 gate 5
    evidence.md                gates 6 and 7
    pr-template.md             gate 7
    contest-brief.md           gate 8
  evals/evals.json             test prompts for improving the skill
```

The repository's own `AGENTS.md`, `CONTRIBUTING.md` and PR template take
priority over this skill.

## License

MIT
