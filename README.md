# Homebrew tap

Formulae for software by [anwarahmed](https://github.com/anwarahmed).

## typeshelf

[typeshelf](https://github.com/anwarahmed/typeshelf) — practice typing in the terminal
by retyping classic books. Works with Homebrew on macOS and Linux.

```sh
brew install anwarahmed/tap/typeshelf
```

Update with `brew upgrade typeshelf`; remove with `brew uninstall typeshelf`.

## How this repo works

`Formula/typeshelf.rb` is generated, not written by hand. The "Update formula" workflow
runs `scripts/render.sh` every few hours (and on demand), which reads the latest
typeshelf release and its checksums and rewrites the formula if a new version is out.
The same workflow then installs the formula on macOS and Linux as a check.

To pick up a release immediately instead of waiting for the schedule:

```sh
gh workflow run update.yml --repo anwarahmed/homebrew-tap
```

GitHub pauses scheduled workflows in repositories with no activity for 60 days. If the
formula stops following releases, re-enable the workflow under Actions, or run the
command above.
