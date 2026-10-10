# Contest brief

Give the reviewer this prompt, with the placeholders filled in. Send nothing
else: no plan, no summary of your reasoning, no hint about what you think is
solid.

## Choosing the reviewer

A subagent in a fresh context, running on Fable. In Claude Code, set
`model: "fable"` on the subagent. If Fable is not available, use the strongest
model you can reach, and name the model that reviewed in your final report.

Self-review does not pass this gate. If no independent reviewer is possible,
the gate is blocked: report it as in "When a gate cannot pass".

## The prompt

```text
Review an open pull request the way a skeptical maintainer of the project
would. Your job is to find reasons to reject it or send it back. Agreeing is
not useful.

Pull request: <PR URL>
Issue or request it answers: <issue URL, or the request verbatim>
Checked-out branch: <absolute path>, base <base branch>
Contribution rules: <paths to AGENTS.md, CONTRIBUTING.md, or "none">

Read the PR description, the full diff and the code around it. Verify every
claim against the code and, where it matters, against the source of the
dependencies it relies on; do not take claims on trust.

You are read-only. Change no files, make no commits, push nothing, and post
nothing on the forge: no comments, no reviews. <any limits on what may be
built or run on this machine>

Look for:
1. Wrong diagnosis. Is the stated cause the real cause? Does the change fix
   the issue as reported, or only part of it?
2. A better fix. Is there a simpler or more complete approach the project
   would prefer? If so, say how it would be built and what it costs.
3. Correctness. Every call site the diff touches, state it leaves out of sync,
   error paths, concurrency, and platforms or configurations whose behaviour
   changed but should not have.
4. Security and data safety, where the change handles input, files, network
   data, credentials or privileged operations.
5. Dependencies. Is each added or upgraded dependency needed, or does
   something already in the tree do the job?
6. Tests. Would they fail if the fix were reverted, or do they restate the
   implementation? What is untested that could be tested cheaply?
7. The project's rules and conventions: contribution rules, style, commit
   shape, scope. Anything in the diff the issue did not ask for.
8. The description. Is it accurate, does it overclaim, and does it tell the
   maintainer what was not tested?

Report format:
- Verdict: one of MERGEABLE, NEEDS CHANGES, WRONG APPROACH.
- Findings, most serious first, in three groups: must fix before a maintainer
  sees it; worth doing; checked and correct. For each: what is wrong, the
  evidence (file:line or a quoted source), and the concrete change to make.
- Anything you could not verify.

Only raise findings you can support with evidence. Do not pad the list with
style preferences or praise.
```

## Handling the report

Save it as received. Then for each finding:

- **Fix**: a new commit on the same branch, proved again as in gate 6. Update
  the PR description if the fix changes what it says.
- **Reject**: write the reason. "The reviewer misread X, see file:line" is a
  reason. "I disagree" is not.

A verdict of WRONG APPROACH goes to the user before anything changes: the PR
is already public, and replacing its approach is their call.
