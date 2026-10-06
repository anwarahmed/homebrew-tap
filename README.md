# Homebrew tap

Formulae for software by [anwarahmed](https://github.com/anwarahmed).

## typeshelf

[typeshelf](https://github.com/anwarahmed/typeshelf) — practice typing in the terminal
by retyping classic books. Works with Homebrew on macOS and Linux.

```sh
brew install anwarahmed/tap/typeshelf
```

Update with `brew upgrade typeshelf`; remove with `brew uninstall typeshelf`.

## wordl

[wordl](https://github.com/anwarahmed/wordl) — a Wordle-style word game for the
terminal. Works with Homebrew on macOS and Linux.

```sh
brew install anwarahmed/tap/wordl
```

Update with `brew upgrade wordl`; remove with `brew uninstall wordl`.

## funchess

[funchess](https://github.com/anwarahmed/funchess) — chess for the terminal: against
the computer, two players at one keyboard, or two computers over the network. Works
with Homebrew on macOS and Linux.

```sh
brew install anwarahmed/tap/funchess
```

Update with `brew upgrade funchess`; remove with `brew uninstall funchess`.

## How this repo works

The formulae in `Formula/` are generated, not written by hand. The "Update formula"
workflow runs `scripts/render.sh` every few hours (and on demand), which reads each
project's latest release and its checksums and rewrites a formula if a new version is
out. The same workflow then installs every formula on macOS and Linux as a check.

To pick up a release immediately instead of waiting for the schedule:

```sh
gh workflow run update.yml --repo anwarahmed/homebrew-tap
```

GitHub pauses scheduled workflows in repositories with no activity for 60 days. If a
formula stops following releases, re-enable the workflow under Actions, or run the
command above.
