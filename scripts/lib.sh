# shellcheck shell=sh
# Shared by the generators in scripts/formulae/. Sourced, not run.

# latest_tag <owner/repo> -> the tag of the latest release, or nothing if there is none.
# The latest release's page redirects to .../releases/tag/<tag>; following it needs no
# API token.
latest_tag() {
    curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" | sed -n 's|.*/releases/tag/||p'
}

# sum_of <SHA256SUMS text> <file name> -> the checksum; fails loudly if it is missing.
sum_of() {
    sum=$(printf '%s\n' "$1" | awk -v f="$2" '$2 == f || $2 == "*" f { print $1 }')
    [ -n "$sum" ] || { echo "the release has no checksum for $2" >&2; exit 1; }
    echo "$sum"
}
