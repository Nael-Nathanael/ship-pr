# Evidence

Evidence lets a reviewer see the change work without checking out the branch.
Capture it from the final code, and attach it so it renders inside the PR.

Contents: [What to capture](#what-to-capture) ·
[Capturing in a browser](#capturing-in-a-browser) ·
[Making a GIF](#making-a-gif) · [Attaching: GitHub](#attaching-github) ·
[Attaching: GitLab](#attaching-gitlab) ·
[Attaching: Bitbucket and others](#attaching-bitbucket-and-others) ·
[Confirm it renders](#confirm-it-renders)

## What to capture

| Change | Evidence |
|--------|----------|
| UI flow added or changed | A recording of the whole flow, plus a screenshot of each key state |
| Visual change | Before and after screenshots at the same viewport, side by side |
| Bug fix with visible symptom | Recording or screenshot of the bug on the default branch, and of the fix |
| Responsive or themed UI | Screenshots at the widths and themes the change affects |
| API, CLI, job, library | Terminal output: the command and what it printed, as a fenced code block |
| Performance | The measurement before and after, with the command that produced it |

Every acceptance criterion in the plan should point at one piece of evidence.

Keep it honest and safe:
- Capture after the last code change. If you change code afterwards, capture again.
- Use test data. No real customer data, secrets, tokens or personal details in
  frame; check the URL bar, the terminal scrollback and the network panel.
- Keep recordings short: the flow, not the waiting. Under a minute.
- Save everything to `$WORK/evidence/` with names that say what they show:
  `01-empty-state.png`, `02-validation-error.png`, `flow.webm`.

## Capturing in a browser

Start the app locally using the repo's run command and wait until it answers
before driving it.

**With Playwright MCP tools.** Navigate, act and take screenshots with the
browser tools your harness exposes. Some versions also expose video tools
(start and stop recording); use them if present. If not, record with a script.

**With a script.** This works anywhere Playwright is installed. Prefer the
repo's own Playwright install and config if it has one.

```javascript
// walkthrough.mjs — run with: node walkthrough.mjs
import { chromium } from 'playwright';

const out = process.env.EVIDENCE_DIR;
const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: 1280, height: 800 },
  recordVideo: { dir: out, size: { width: 1280, height: 800 } },
});
const page = await context.newPage();

await page.goto('http://localhost:3000/');
await page.screenshot({ path: `${out}/01-start.png` });
// … drive the flow as a user would, screenshot each key state …

await context.close(); // the video file is written on close
await browser.close();
```

Newer Playwright versions also have `page.screencast.start({ path })` and
`page.screencast.stop()` for recording only part of a session. Check the
installed version's docs before using it.

If the repo already has an end-to-end test for the flow, running it with video
turned on (`video: 'on'` in the Playwright config, or the equivalent flag)
gives a recording for free.

Look at each screenshot before using it. A screenshot of a loading spinner, an
error overlay or the wrong page is worse than none.

If no browser can run in your environment, say so in the PR and give the
strongest substitute you have: end-to-end test output, HTTP responses.

## Making a GIF

GitHub plays an uploaded WebM or MP4 directly, so convert only when you need a
GIF: when the forge will not play video, or when the file is embedded by URL.

```bash
ffmpeg -y -i flow.webm -vf "fps=10,scale=960:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a" -loop 0 flow.gif
```

Aim for under 10 MB. To shrink: lower `fps` to 8, lower `scale` to 720, or trim
with `-ss <start> -t <seconds>` before `-i`.

## Attaching: GitHub

Check what your `gh` supports before choosing a method:

```bash
gh --version
gh pr create --help | grep -- --attach
```

### Method 1: `gh --attach` (gh 2.99.0 and later)

Reference each file by its local path in the body, and pass the same path to
`--attach`. `gh` uploads the file and rewrites the reference to the hosted URL.

```bash
gh pr create --base "$DEFAULT" --title "…" --body-file "$WORK/pr-body.md" \
  --attach "$WORK/evidence/01-start.png#Start screen" \
  --attach "$WORK/evidence/flow.webm"
```

- In the body: `![Start screen](<same path as passed to --attach>)`.
- Alt text goes after `#` on images; quote the argument so the shell keeps it.
- Put a video reference alone on its own line so it becomes a player.
  Videos take no alt text.
- Files not referenced in the body are appended at the end.
- Types: png, jpg, gif, webp, svg, mp4, mov, webm. It needs push access to the
  repo and does not work with `--web`.
- To add evidence later: `gh pr edit <n> --body-file … --attach …` or
  `gh pr comment <n> --attach …`.

This is the method to prefer: nothing is committed, and it renders in private
repos for anyone who can see the repo.

### Method 2: older `gh`

First choice is to upgrade `gh`; tell the user the installed version and that
2.99.0 adds `--attach`. Do not upgrade system packages yourself without asking.

If upgrading is not possible now, embed by commit-pinned URL:

1. Convert recordings to GIF, since a video linked by URL shows as a plain link.
2. Commit the evidence files on the PR branch under one directory, push, and
   note that commit's full SHA.
3. Remove the files in a following commit and push, so the PR's net diff has no
   media. The pinned commit stays reachable through the PR. If the repo merges
   with merge commits rather than squash, the media stays in history for good;
   ask the user before using this method there.
4. Reference each file in the body as
   `![alt](https://github.com/<owner>/<repo>/blob/<sha>/<path>?raw=true)`.

This is reliable on public repos. On private repos rendering has been reported
as inconsistent, so the render check below decides. If it fails there, open the
PR as a draft, list the evidence files and their local paths in the body, tell
the user they need to be attached, and report the work as not done.

Avoid browser-cookie upload extensions. They need your full session cookie.

## Attaching: GitLab

Upload each file to the project, then paste the returned Markdown into the
merge request description.

```bash
curl --silent --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --form "file=@$WORK/evidence/01-start.png" \
  "https://<host>/api/v4/projects/<url-encoded-project-path>/uploads"
```

The response has a `markdown` field ready to paste. Create the MR with
`glab mr create --description "$(cat "$WORK/pr-body.md")"`. GitLab plays
uploaded video inline.

## Attaching: Bitbucket and others

If the forge has no upload route you can script, use the commit-pinned method
above with that forge's raw file URL, or attach through the web UI with
browser automation if you have an authenticated session available. If neither
works, the PR lists the evidence files and the user attaches them; report the
work as not done until they are in the PR.

## Confirm it renders

After the PR exists, check that the evidence is really there.

```bash
gh pr view <n> --json body --jq .body          # every local path was rewritten to a URL
gh api "repos/<owner>/<repo>/pulls/<n>" -H "Accept: application/vnd.github.full+json" --jq .body_html
```

In the rendered HTML, each image should be an `<img>` and each video a
`<video>`. Then request each media URL and expect HTTP 200:

```bash
curl -sIL -o /dev/null -w '%{http_code}\n' -H "Authorization: token $(gh auth token)" "<url>"
```

Where you have a logged-in browser session, opening the PR page and taking a
screenshot of it is the most direct check. A broken image means fix it and
check again before reporting anything.
