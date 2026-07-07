#!/usr/bin/env bash

set -euo pipefail

REPO="${1:-$HOME/git/todb/kev-data}"
FILE="known_exploited_vulnerabilities.csv"

if [[ ! -d "$REPO/.git" ]]; then
    echo "Error: not a git repository: $REPO" >&2
    exit 1
fi

cd "$REPO"

declare -A current

echo "Reading current KEV list..."

while read -r cve; do
    current["$cve"]=1
done < <(
    git show develop:$FILE |
    cut -d, -f1 |
    grep '^CVE-' |
    sort -u
)

declare -A removed

echo "Finding historical removals..."

git rev-list --reverse develop |
while read old; do
    read new || break

    date=$(git show -s --format=%cs "$new")

    comm -23 \
        <(git show "$old":$FILE 2>/dev/null | cut -d, -f1 | grep '^CVE-' | sort) \
        <(git show "$new":$FILE 2>/dev/null | cut -d, -f1 | grep '^CVE-' | sort) |
    while read cve; do
        echo "$date $new $cve"
    done

done |
while read date commit cve; do
    if [[ -z "${current[$cve]:-}" ]]; then
        echo "$date $commit $cve"
    fi
done |
sort -u