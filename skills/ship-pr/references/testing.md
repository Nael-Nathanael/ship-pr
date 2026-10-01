# Testing

Tests are part of the change, not a follow-up. They are also the cheapest
evidence: a reviewer trusts a test that would fail without the change.

## First, learn the repo's setup

- Which frameworks are installed for each level, and where tests live.
- The commands, from the manifest or CI config.
- Existing helpers: factories, fixtures, test database setup, page objects,
  authenticated-session helpers. Use them.

If the repo has no tests at a level the change needs, add the smallest setup
that follows the stack's convention and say so in the PR. If it has no test
tooling at all and adding it is a project of its own, raise that with the user
before the build; do not silently skip.

## Which levels apply

| Level | Covers | Applies when | Does not apply when |
|-------|--------|--------------|---------------------|
| Unit | One function or module, no I/O | New or changed logic: branches, calculations, parsing, validation, state transitions | Pure wiring, config, markup or copy with no logic |
| Integration | Units working together across a real boundary | The change touches a database query, HTTP endpoint, queue, file system, external API client, or the contract between modules | The change stays inside one pure module |
| End-to-end | A user flow through the real interface | A user-visible behaviour is added or changed: UI flow, CLI command, public API used as a product | Internal refactor with no behaviour change (existing e2e tests must still pass) |

Most changes need more than one level. A new form field with validation that
is saved to a database touches all three.

For every level marked not applicable, the PR states the reason.

## Writing each level

**Unit**
- Test behaviour through the public function, not private internals.
- Cover the normal case, each boundary, and each error path.
- No network, database or clock; inject them or keep the logic pure.

**Integration**
- Use the real dependency where the repo's setup allows (a test database, a
  local container), because mocks prove only that your code calls the mock.
- Mock what you do not own and cannot run: third-party APIs.
- Assert on the effect: the row written, the response body and status, the
  message published.
- Cover authorisation: the wrong user gets refused.

**End-to-end**
- Drive the interface a user drives, including the setup. Create the data by
  clicking through the screens that create it, not by seeding it through an
  API or a script. A seeded fixture proves the path you already believed in;
  clicking through setup finds the broken one.
- Select elements the way a user finds them: role, label, visible text.
- Assert on what the user sees.
- Include at least one failure path: invalid input, a denied action.
- Wait on conditions, never on fixed delays.

## What makes a test worth having

- It fails when the behaviour is broken. Check this: for a bug fix, run the
  test before the fix and see it fail. For a feature, break the code briefly
  and see the test catch it.
- It reads as a statement of behaviour: name says what, body shows how.
- It is deterministic. A flaky test gets fixed or removed, not retried.

Do not weaken, skip or delete an existing test to make the suite pass. If an
existing test is wrong because the behaviour changed on purpose, update it and
say so in the PR.

## Running

Run the new tests alone first, then the whole suite, since the change can
break something elsewhere. Paste the summary lines into the PR.
