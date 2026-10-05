# homebrew-tap

The Homebrew tap for Anwar's projects: [typeshelf](https://github.com/anwarahmed/typeshelf)
and [wordl](https://github.com/anwarahmed/wordl). Users run
`brew install anwarahmed/tap/<name>`. The repository name must start with `homebrew-`
for that short form to work.

`README.md` is for users. This file is for whoever maintains the tap: how it works, what
has gone wrong, and how to fix it. Everything under "What has gone wrong" was seen for
real on 2026-10-04, during the releases of typeshelf 0.2.1 to 0.2.3.

## How it works

- Every file in `Formula/` is generated. Never edit one by hand; the next run
  overwrites it.
- Each formula has a generator, `scripts/formulae/<name>.sh`, that prints the formula
  for its project's latest release (or nothing when there is no release). It follows
  `releases/latest` to find the tag and downloads that release's `SHA256SUMS`;
  `scripts/lib.sh` holds the helpers for both.
- `scripts/render.sh` runs every generator (or the ones named as arguments), rewrites
  the formulae that changed, and prints one line each: `<name> unchanged`,
  `<name> no release`, or `<name> <version>`.
- `.github/workflows/update.yml` ("Update formula") runs `render.sh`, commits changed
  formulae to `main` as `github-actions[bot]` (the commit message is the changed lines,
  e.g. `wordl 0.1.1`), then installs and tests **every** formula with Homebrew on macOS
  and Linux runners, one job per formula and platform.
- The workflow starts in three ways: on a schedule (`17 */3 * * *`, UTC), by hand
  (`workflow_dispatch`), and on a push to `main` that touches `scripts/**` or
  `.github/workflows/**`. A push that only touches docs or a formula starts nothing.

## Adding a formula

1. Write `scripts/formulae/<name>.sh`; the file name is the formula name. Both existing
   ones are for one bare executable per platform; copy `wordl.sh` if the program
   updates itself. For a single archive that is the same on every platform, see
   `wordl.sh` as it was before 0.2.0 (`git log -- scripts/formulae/wordl.sh`): one
   `url`, no `version` line, files installed into `libexec`.
2. Add checks that only make sense for that formula as a step in the `test` job with
   `if: matrix.formula == '<name>'`. Nothing else in the workflow names formulae.
3. Add the project to `README.md` and to "What the tap depends on" below.
4. In the project: a release step that runs this workflow and waits for
   `Formula/<name>.rb` to show the new version, and a `TAP_TOKEN` secret (see "The
   formula trails a release").

## Working here

- Local layout: a bare clone at `~/Developer/GitHub/anwarahmed/homebrew-tap` with the
  `main` worktree beside it, the same as typeshelf.
- `main` takes direct pushes (the "Main" ruleset only blocks force-pushes and deletion),
  because the bot commits the formula there.
- The bot pushes after every release, so the local `main` is usually behind. Run
  `git pull --ff-only` before changing anything.
- Actions are pinned to commit hashes with the version in a trailing comment; Dependabot
  proposes newer pins monthly. Pin any action you add the same way.

## What the tap depends on in each project

Changing any of these in a project breaks its formula, so change its generator in step.

In typeshelf:

- Release assets are bare executables named `typeshelf-<rust target>`, for these four
  targets: `aarch64-apple-darwin`, `x86_64-apple-darwin`, `aarch64-unknown-linux-musl`,
  `x86_64-unknown-linux-musl`. `render.sh` fails if a checksum for one is missing.
- Each release has a `SHA256SUMS` file in `sha256sum` format.
- Tags are `v<version>`, and `typeshelf --version` prints that version (the formula's
  `test` block checks it).
- **typeshelf must never update a Homebrew copy itself.** See the first incident below.

In wordl (a Rust program since 0.2.0; 0.1.x was a bash script shipped as one archive):

- Release assets are bare executables named `wordl-<rust target>`, for the same four
  targets as typeshelf. `scripts/formulae/wordl.sh` fails if a checksum for one is
  missing. A release with no binaries at all (0.1.x) leaves the formula untouched.
- Each release has a `SHA256SUMS` file in `sha256sum` format.
- Tags are `v<version>`, and `wordl --version` prints that version.
- **wordl must never update a Homebrew copy itself.** wordl updates itself on start
  unless a package owns the copy. It looks for a marker file at
  `../share/wordl/managed-by` from the real directory of its binary; the formula writes
  it (`share/"wordl/managed-by"`, one line: `Homebrew; use brew upgrade wordl`), and
  `wordl update` then prints "installed with Homebrew; use brew upgrade wordl". If
  wordl moves or renames what it looks for, the formula must follow. wordl also checks
  its real path for `Cellar` as a fallback. The workflow's last wordl step proves the
  refusal on both platforms after every render.

Any new formula for a program that updates itself needs the same two things: the switch
set at install time, and a test through the linked name.

## Commands

```sh
# Update the formula now instead of waiting for the schedule
gh workflow run update.yml --repo anwarahmed/homebrew-tap

# Which version a formula is at
gh api repos/anwarahmed/homebrew-tap/contents/Formula/typeshelf.rb -q .content | base64 -d | grep version
gh api repos/anwarahmed/homebrew-tap/contents/Formula/wordl.rb -q .content | base64 -d | grep version

# Recent runs, and what started each one
gh run list --repo anwarahmed/homebrew-tap --workflow update.yml --limit 10 --json event,conclusion,createdAt

# Render locally (rewrites Formula/*.rb in the working tree); name one to render only it
scripts/render.sh
scripts/render.sh wordl
```

`gh run list` straight after `gh workflow run` can still show the previous run. Wait a
few seconds, or check the run's creation time, before trusting its result.

## What has gone wrong

### `brew upgrade` fails with "Could not symlink bin/typeshelf"

```
Error: The `brew link` step did not complete successfully
Could not symlink bin/typeshelf
Target /opt/homebrew/bin/typeshelf already exists.
```

Cause: typeshelf has a self-updater that replaces its own binary. It is meant to skip
Homebrew copies by looking for `Cellar` in its own path. Homebrew installs the real file
in `Cellar/typeshelf/<version>/bin/` and puts a symlink to it in `/opt/homebrew/bin`. On
macOS a program started through that symlink is told the symlink's path, not the real
one (Linux reports the real one), so the check saw no `Cellar`, and the updater replaced
the symlink with a regular file. Homebrew then refused to link over a file it did not
create. Fixed in typeshelf 0.2.3, which resolves symlinks first.

What to know when it happens:

- The upgrade itself worked: the new version is in the Cellar. Only the link is missing.
- Until it is repaired, `typeshelf` runs the stray file, which is the old, buggy version.
- The repair, on the affected machine:

  ```sh
  brew link --overwrite typeshelf
  ```

- Running `brew upgrade` again does not repair it; the stray file is still there.
- Copies of typeshelf 0.2.2 or older on macOS still have the bug. If one is started
  before `brew upgrade`, it updates itself and breaks the link again. Upgrade first.
- The check that the fix holds: on a Homebrew install, `typeshelf update` must print
  "this copy can't update itself: installed with Homebrew; use brew upgrade typeshelf".
- It cannot be reproduced on Linux, and `brew test` does not catch it: that runs the
  binary by its Cellar path, not through the link. The workflow's last step does: it
  runs `typeshelf update` by its linked name on both runners and fails unless it refuses.

The general rule: a program installed by a package manager must not rewrite its own
files, and must resolve symlinks before deciding how it was installed.

### The formula trails a release

After typeshelf 0.2.1, 0.2.2 and 0.2.3 the formula stayed on the old version until the
workflow was run by hand. Two causes:

- Nothing told the tap. typeshelf's release workflow has a step that starts this
  workflow, but it needs a `TAP_TOKEN` secret in the typeshelf repository, and that was
  not set. Without it the step passes and only leaves a "Homebrew tap not notified"
  warning on the release run.
- The schedule is slower than it looks. This repository was created at 03:32 UTC; the
  06:17 and 09:17 slots never ran, and the first scheduled run started at 12:29, twelve
  minutes late. GitHub drops and delays scheduled runs, most of all on new or quiet
  repositories. Treat "every three hours" as a best case.

To make releases reach Homebrew at once, set `TAP_TOKEN` in the project (typeshelf has
it since 2026-10-04; each project needs its own copy of the secret, and GitHub never
shows a stored secret again, so keep the token or create another):

1. Create a fine-grained personal access token limited to this repository, with the
   repository permission "Actions: read and write".
2. `gh secret set TAP_TOKEN --repo anwarahmed/<project>`

With the token set, typeshelf's release run starts this workflow, waits up to ten
minutes for the formula to show the new version, and fails if it does not. Until then,
the first command under "Commands" is a required step after every release (it is in
typeshelf's `RELEASING.md`).

GitHub also disables scheduled workflows after 60 days without repository activity.
Re-enable the workflow under Actions if the schedule stops.

## Not done

- The token path (`TAP_TOKEN`, and the ten-minute wait in typeshelf's release run) has
  never run for real.
