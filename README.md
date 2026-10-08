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

## fungeo

[fungeo](https://github.com/anwarahmed/fungeo) — a geography quiz for children, in the
terminal: every right answer lays a plank of a bridge.

```sh
brew install anwarahmed/tap/fungeo
```

Update with `brew upgrade fungeo`; remove with `brew uninstall fungeo`.

## funkitty

[funkitty](https://github.com/anwarahmed/funkitty) — fun time with Pink Kitty: little
reading and typing games for young children, in the terminal.

```sh
brew install anwarahmed/tap/funkitty
```

Update with `brew upgrade funkitty`; remove with `brew uninstall funkitty`.

## funwordl

[funwordl](https://github.com/anwarahmed/funwordl) — a playful Wordle-style word game
for the terminal, made for children: hints, stars, confetti and a collection of words
learned. Works with Homebrew on macOS and Linux.

```sh
brew install anwarahmed/tap/funwordl
```

Update with `brew upgrade funwordl`; remove with `brew uninstall funwordl`.

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
