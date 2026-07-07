#!/usr/bin/env bash
#
# Find CVEs removed from the CISA Known Exploited Vulnerabilities (KEV)
# catalog history that are still absent from the current KEV list.
#
# Usage:
# Clone the kev-data repository:
#   git clone https://github.com/cisagov/kev-data.git /path/to/cloned/kev-data
#
# Run the script:
#   ./kev-removals.sh /path/to/cloned/kev-data
#
# Arguments:
#   /path/to/kev-data   Path to a local git checkout of the kev-data repository
#
# Example:
#   ./kev-removals.sh ~/src/kev-data
#
# The script expects:
#   - A git repository
#   - A "develop" branch containing known_exploited_vulnerabilities.csv

set -euo pipefail

FILE="known_exploited_vulnerabilities.csv"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/kev-data" >&2
    exit 1
fi

REPO="$1"

if [[ ! -d "$REPO/.git" ]]; then
    echo "Error: not a git repository: $REPO" >&2
    exit 1
fi

cd "$REPO"

CURRENT_COMMIT=$(git rev-parse develop)
CURRENT_DATE=$(git show -s --format=%cs "$CURRENT_COMMIT")

echo "Current KEV reference: $CURRENT_COMMIT ($CURRENT_DATE)"

declare -A current

echo "Reading current KEV list..."

while read -r cve; do
    current["$cve"]=1
done < <(
    git show "develop:$FILE" |
    cut -d, -f1 |
    grep '^CVE-' |
    sort -u
)

echo "Finding removed CVEs..."

declare -a removals

while read -r old new; do
    date=$(git show -s --format=%cs "$new")

    while read -r cve; do
        removals+=("$date|$new|$cve")
    done < <(
        comm -23 \
            <(git show "$old:$FILE" 2>/dev/null | cut -d, -f1 | grep '^CVE-' | sort) \
            <(git show "$new:$FILE" 2>/dev/null | cut -d, -f1 | grep '^CVE-' | sort)
    )

done < <(
    git rev-list --reverse develop |
    awk 'NR>1 { print prev, $1 } { prev=$1 }'
)

for removal in "${removals[@]}"; do
    IFS='|' read -r date commit cve <<< "$removal"

    short_commit=$(git rev-parse --short=8 "$commit")

    if [[ -z "${current[$cve]:-}" ]]; then
        echo "$date: $cve removed ($short_commit), still absent"
    else
        echo "$date: $cve removed ($short_commit), but present in current (git topology weirdness)"
    fi
done | sort -u