#!/usr/bin/env bash
# Citation census for a LORE corpus — the counter-pressure against abundance.
#
# For each entry, count how many files outside the corpus mention its slug,
# split two ways:
#
#   auto     — the mention sits under a `## Relevant LORE` heading, i.e. some
#              tool or recall pass *handed* the entry over. Not evidence anyone
#              used it.
#   genuine  — the mention is anywhere else: prose, a design note, a session
#              recap, a commit message body. Somebody actually reached for it.
#
# Many auto and zero genuine is the sharp signal: the machine keeps offering it
# and nobody ever uses it. That is a retirement-REVIEW candidate, never an
# automatic delete.
#
# Entries younger than the grace window (default 30 days, by `created:`) are
# reported separately as too new to judge.
#
# usage: lore-cite.sh [-d corpus-dir] [-r search-root] [-g grace-days]
#   search-root defaults to the git repo root, else the corpus's parent.
set -uo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dir=""
root=""
grace=30

while [ "$#" -gt 0 ]; do
	case "$1" in
	-d)
		shift
		dir="${1:-}"
		;;
	-r)
		shift
		root="${1:-}"
		;;
	-g)
		shift
		grace="${1:-30}"
		;;
	-h | --help)
		sed -n '2,22p' "${BASH_SOURCE[0]}" >&2
		exit 0
		;;
	*)
		echo "lore-cite.sh: unknown argument: $1" >&2
		exit 2
		;;
	esac
	shift
done

if [ -z "$dir" ]; then
	dir=$("$here/lore-dir.sh") || exit 1
fi
if [ -z "$root" ]; then
	root=$(git rev-parse --show-toplevel 2>/dev/null || true)
	if [ -z "$root" ]; then root=$(dirname -- "$dir"); fi
fi

slugs=$(mktemp)
files=$(mktemp)
tally=$(mktemp)
trap 'rm -f "$slugs" "$files" "$tally"' EXIT

shopt -s nullglob
for f in "$dir"/*.md; do
	s=$(basename "$f" .md)
	if [ "$s" = INDEX ]; then continue; fi
	created=$(awk -F': *' '/^created:/ {gsub(/["\x27]/, "", $2); print $2; exit}' "$f")
	printf '%s\t%s\n' "$s" "${created:-unknown}" >>"$slugs"
done

if [ ! -s "$slugs" ]; then
	echo "lore-cite: no entries in $dir" >&2
	exit 1
fi

# Candidate citing files: text under the search root, excluding the corpus
# itself and the usual machine-generated noise.
find "$root" \
	-type d \( -name .git -o -name node_modules -o -name vendor -o -name target -o -name dist \) -prune -o \
	-type f \( -name '*.md' -o -name '*.txt' -o -name '*.go' -o -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.rs' \) -print 2>/dev/null |
	grep -vF "$dir/" >"$files"

# xargs, not `awk $(cat files)`: an unquoted expansion breaks on spaces and
# blows past ARG_MAX on a big tree. xargs may split the list across several awk
# invocations, so each emits its own partial counts and the second awk sums them.
xargs -a "$files" -d '\n' awk -v slugfile="$slugs" '
	BEGIN {
		while ((getline line < slugfile) > 0) {
			split(line, p, "\t")
			slugs[++n] = p[1]
			created[p[1]] = p[2]
		}
	}
	FNR == 1 { inrel = 0; rellevel = 0 }
	/^#+[[:space:]]/ {
		lvl = 0
		while (substr($0, lvl + 1, 1) == "#") lvl++
		if (tolower($0) ~ /relevant lore/) { inrel = 1; rellevel = lvl }
		else if (inrel && lvl <= rellevel) { inrel = 0 }
	}
	{
		for (i = 1; i <= n; i++) {
			if (index($0, slugs[i]) > 0) {
				if (inrel) auto[slugs[i]]++; else genuine[slugs[i]]++
			}
		}
	}
	END {
		for (i = 1; i <= n; i++) {
			s = slugs[i]
			printf "%d\t%d\t%s\t%s\n", genuine[s] + 0, auto[s] + 0, created[s], s
		}
	}
' 2>/dev/null |
	awk -F'\t' '
		{ g[$4] += $1; a[$4] += $2; c[$4] = $3 }
		END { for (s in g) printf "%d\t%d\t%s\t%s\n", g[s], a[s], c[s], s }
	' | sort -n -k1,1 -k2,2r >"$tally"

today=$(date +%s)
printf '%-7s %-5s %-11s %s\n' GENUINE AUTO CREATED ENTRY
printf '%s\n' "---------------------------------------------------------------"
newish=""
while IFS=$'\t' read -r g a c s; do
	age=""
	if [ "$c" != unknown ]; then
		cs=$(date -d "$c" +%s 2>/dev/null || echo "")
		if [ -n "$cs" ]; then age=$(((today - cs) / 86400)); fi
	fi
	if [ -n "$age" ] && [ "$age" -lt "$grace" ]; then
		newish="$newish$(printf '  %-40s created %s (%sd old)\n' "$s" "$c" "$age")"
		continue
	fi
	flag=""
	if [ "$g" -eq 0 ] && [ "$a" -eq 0 ]; then flag="  <- never cited"; fi
	if [ "$g" -eq 0 ] && [ "$a" -gt 0 ]; then flag="  <- auto-only, never genuine"; fi
	printf '%-7s %-5s %-11s %s%s\n' "$g" "$a" "$c" "$s" "$flag"
done <"$tally"

if [ -n "$newish" ]; then
	printf '\nToo new to judge (< %s days), reported separately:\n%s' "$grace" "$newish"
fi

cat <<'EOF'

Retirement is a decision on review, never automatic. Read a flagged entry and
its citing context before recommending anything: an uncited entry may be a
lesson nobody has needed yet, or one whose slug nobody could guess.
EOF
