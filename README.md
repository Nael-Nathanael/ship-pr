# ship-pr

[![skills.sh](https://skills.sh/b/Nael-Nathanael/ship-pr)](https://skills.sh/Nael-Nathanael/ship-pr)

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
| 2 | Explore | Open PRs or issues already doing the work, and code that can be reused |
| 3 | Plan | Plan file with checkable acceptance criteria |
| 4 | Challenge | An independent reviewer attacks the plan; the plan is revised |
| 5 | Build | Code plus unit, integration and end-to-end tests, worked from a task checklist |
| 6 | Prove | Checks pass, result compared with the plan, app walked through in a browser |
| 7 | Publish | Open PR with the evidence in the description |
| 8 | Contest | Open-source projects you do not maintain: a reviewer on the strongest available model attacks the open PR; the PR is revised |

Until the last gate passes, the agent reports progress, not "done". If a gate is
blocked, it opens a draft PR and says what is missing.

## Why these gates

Each gate targets a measured way that agent work fails or a PR stalls.

| Gate | Finding | Source |
|------|---------|--------|
| 2 Explore | Duplicates are 23% of rejected agent PRs, second only to PRs nobody reviews | [Ehsani et al., MSR 2026](https://arxiv.org/abs/2601.15195) |
| 3 Plan | Writing a plan before the code raises Pass@1 by up to 25.4% over generating the code directly | [Jiang et al., TOSEM](https://arxiv.org/abs/2303.06689) |
| 4, 8 Challenge, Contest | Models reviewing their own reasoning often make it worse; on code, outside feedback fixes 52.6% of failing programs against 33.3% with the model's own | [Huang et al., ICLR 2024](https://arxiv.org/abs/2310.01798); [Olausson et al., ICLR 2024](https://arxiv.org/abs/2306.09896) |
| 5, 6 Build, Prove | Choosing a patch by running reproduction tests solves 32% of SWE-bench Lite against 25.7% without tests | [Xia et al., FSE 2025](https://arxiv.org/abs/2407.01489) |
| 6 Prove | Each failed CI check lowers an agent PR's merge odds by about 15% | [Ehsani et al., MSR 2026](https://arxiv.org/abs/2601.15195) |
| 7 Publish | Small changes get reviewed in under an hour at Google, very large ones in about five | [Sadowski et al., ICSE-SEIP 2018](https://sback.it/publications/icse2018seip.pdf) |
| 7 Publish | PR descriptions that say what feedback is wanted are 64–72% more likely to be merged | [Pirouzkhah et al., MSR 2026](https://arxiv.org/abs/2602.14611) |

Agent PRs that include tests are not merged more often
([Haque et al., MSR 2026](https://arxiv.org/abs/2601.03556)), so the tests are
there for correctness. No study yet measures screenshots in PRs; the evidence
gate rests on reviewers being able to check a claim without running the code.

## Install

Any supported agent, with the [skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add Nael-Nathanael/ship-pr          # this project
npx skills add Nael-Nathanael/ship-pr -g       # all your projects
```

Or copy `skills/ship-pr/` into your agent's skills directory. Each agent has
its own; the skills CLI lists them under
[supported agents](https://github.com/vercel-labs/skills#supported-agents).

## Use

```
/ship-pr add a tip field to the checkout form
/ship-pr fix #142
```

That is `/ship-pr <task>` in Claude Code, Cursor and Antigravity, and
`$ship-pr <task>` in Codex. In any agent you can also just describe the task:
agents pick the skill up on their own for build, fix and refactor requests.
The task can be a sentence, an issue number or URL, or a pasted ticket.

## What the agent needs

The skill checks these itself before starting (`scripts/preflight.sh`). If a
required tool is missing, the agent stops, shows the install command, and asks
before installing anything. To check your machine yourself, run this from any
repo:

```bash
bash <skills-dir>/ship-pr/scripts/preflight.sh --ui
```

`<skills-dir>` is where your agent keeps skills, for example `~/.claude/skills`
for Claude Code or `~/.agents/skills` for Codex.

- git, and a forge CLI that is logged in: `gh` for GitHub, `glab` or an API
  token for GitLab.
- `gh` 2.99.0 or later to attach screenshots and video to a GitHub PR. Older
  versions only warn, and fall back to a workaround described in
  [`references/evidence.md`](skills/ship-pr/references/evidence.md).
- Playwright and ffmpeg for UI evidence. Without them the agent says so in the PR.

## Files

```
skills/ship-pr/
  SKILL.md                     the workflow
  references/
    plan-template.md           gate 3
    design-principles.md       gate 3
    challenge-brief.md         gate 4
    testing.md                 gate 5
    evidence.md                gates 6 and 7
    pr-template.md             gate 7
    contest-brief.md           gate 8
  scripts/preflight.sh         gate 0 dependency check
```

The repository's own `AGENTS.md`, `CONTRIBUTING.md` and PR template take
priority over this skill.

## License

MIT
