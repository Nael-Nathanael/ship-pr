# Design principles

Five principles, each with what it means while planning, and how it goes wrong.
They pull against each other in places; the last section says which wins.

## YAGNI: you aren't gonna need it

Build for the requirement in front of you. Speculative code costs twice: once
to write, and again when the real requirement arrives and does not match the
guess.

Leave out, until something needs them:
- configuration flags with one value in use
- an interface with one implementation
- parameters no caller passes
- generic handling for cases that cannot currently occur

YAGNI is about features and abstractions. It is not a reason to skip error
handling, validation at system boundaries, tests, or security. Those are part
of building the current requirement properly.

## Reuse first: do not reinvent the wheel

Before writing something new, stop at the first of these that solves it:

1. Code already in this codebase
2. The language's standard library
3. The platform or framework already in use
4. A dependency already installed
5. A new, well-maintained dependency
6. New code

Search for it during exploration, by behaviour and not only by the name you
would have chosen. Look at how open-source projects solved the same problem
before designing your own shape.

A new dependency is a cost: something to audit, update and debug. Add one when
it replaces real complexity, not to save ten lines.

## DRY: don't repeat yourself

Every piece of knowledge (a rule, a format, a constant, a calculation) has one
authoritative home. When it changes, it changes in one place.

DRY is about knowledge, not about text. Two blocks that look alike but encode
different rules, and would change for different reasons, are not duplication.
Merging them couples things that should move independently. Wait until the
shared rule is clear; the third occurrence is usually the time.

## High cohesion, low coupling

Cohesion: everything in a module serves one purpose. If describing a module
needs the word "and", it may be two.

Coupling: a module depends on as little of other modules as possible, and
only through their public surface. Signs of too much: a change in one place
forces edits in many, a module reaches into another's internals, a test needs
half the system set up.

In practice:
- Put code next to the thing it changes with.
- Pass in what a function needs, not a large object it picks from.
- Keep I/O at the edges and logic in the middle, so the logic tests without mocks.
- Depend in one direction; no cycles.

Modularity serves these two goals. Splitting code into more files does not by
itself make it modular.

## Right tool for the job

Use what the stack already offers for the problem: the database for filtering
and joining, the framework's router for routing, the type system for
invariants, the schema library already present for validation, a migration
tool for schema changes.

Also at the level of process: a script for a repeated mechanical task, the
project's generator for boilerplate, the debugger or a failing test in place
of guesswork.

Check current documentation for the installed version before relying on an
API. Memory of a library is often a version behind.

## When they conflict

- **YAGNI beats reuse-by-abstraction.** Do not build a shared abstraction for
  one caller. Reuse what exists; do not pre-build for reuse.
- **Clarity beats DRY** when removing duplication needs flags and special
  cases that make the shared code harder to read than two copies.
- **The codebase's existing pattern beats your preferred one.** Consistency is
  worth more to the next reader than a locally better design. Propose a
  pattern change separately.

Record the trade-off in the plan's Approach section, so the reviewer sees it
was a decision.
