#!/bin/sh
# Rewrites the formulae in Formula/ from each project's latest release.
#
#   render.sh              every formula that has a generator in scripts/formulae/
#   render.sh <name>...    only those
#
# Prints one line per formula: "<name> unchanged", "<name> no release", or
# "<name> <version>" when the formula was rewritten.
set -eu

here=$(dirname "$0")
if [ $# -eq 0 ]; then
    # shellcheck disable=SC2046 # one word per formula name is the point
    set -- $(for f in "$here"/formulae/*.sh; do basename "$f" .sh; done)
fi

for name in "$@"; do
    gen="$here/formulae/$name.sh"
    out="$here/../Formula/$name.rb"
    [ -f "$gen" ] || { echo "render.sh: no generator for $name" >&2; exit 1; }
    new=$(sh "$gen") || { echo "render.sh: the generator for $name failed" >&2; exit 1; }
    if [ -z "$new" ]; then
        echo "$name no release"
    elif [ -f "$out" ] && [ "$(cat "$out")" = "$new" ]; then
        echo "$name unchanged"
    else
        printf '%s\n' "$new" > "$out"
        # A formula with no explicit version takes it from the archive's name.
        version=$(printf '%s\n' "$new" | sed -n -e 's/^  version "\(.*\)"$/\1/p' -e 's|^  url ".*/releases/download/v\([^/]*\)/.*|\1|p' | head -n 1)
        echo "$name $version"
    fi
done
