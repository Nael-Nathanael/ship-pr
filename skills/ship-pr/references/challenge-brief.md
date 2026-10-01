# Challenge brief

Give the reviewer this prompt, with the placeholders filled in. Send nothing
else: no summary of your reasoning, no hint about what you think is solid.

## Choosing the reviewer

In order of preference:

1. A subagent in a fresh context, on the same model or a stronger one.
2. A different agent CLI or model in non-interactive mode, pointed at the repo.
3. A new session of the same agent, started with only this brief.
4. Self-review against this brief. Not independent; say so in the PR.

A weaker model as reviewer tends to miss design problems and raise style
points, so do not step down.

## The prompt

```text
You are reviewing an implementation plan before any code is written. Your job
is to find what is wrong with it. Agreeing is not useful; a missed problem
costs far more to fix after the code exists.

Repository: <absolute path>
Plan: <absolute path to plan.md>
Original request: <the user's request, verbatim>

Read the plan, then read the code it touches. Verify its claims against the
repository; do not take them on trust. You are read-only: change nothing.

Look for:
1. Wrong premises. Does the plan misread the request or the existing code?
   Check each claim in "Findings" against the files it cites.
2. Missed reuse. Does the codebase, standard library or an installed
   dependency already do something the plan proposes to write?
3. Over-building. Anything not needed by the request: options, layers,
   abstractions, speculative cases.
4. Under-building. Failure modes, edge cases, concurrency, permissions,
   migrations, backwards compatibility, or callers the plan does not handle.
5. Coupling and cohesion. Does the change put code in the wrong place, or make
   modules depend on each other's internals?
6. Tests. Would the planned tests fail if the feature were broken? Is a level
   (unit, integration, end-to-end) missing or wrongly marked not applicable?
7. Acceptance criteria. Is each one observable and checkable? Could all of
   them pass while the request is still not met?
8. A simpler route. Is there a materially cheaper way to meet the request?

Report format:
- Verdict: one of PROCEED, PROCEED WITH CHANGES, RETHINK.
- Objections, most serious first. For each: what is wrong, the evidence
  (file:line or the plan section), and what to do instead.
- Claims you checked and found correct, briefly.
- Anything you could not verify.

Only raise objections you can support with evidence from the repo or the
request. Do not pad the list with style preferences.
```

## Handling the report

Save it as received. Then for each objection:

- **Accept**: change the plan, note what changed.
- **Reject**: write the reason. "The reviewer misread X, see file:line" is a
  reason. "I disagree" is not.

A verdict of RETHINK means go back to gate 3, and run the challenge again on
the new plan. If an objection turns on something only the user can decide, ask
the user before building.
