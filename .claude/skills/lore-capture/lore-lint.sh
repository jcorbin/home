#!/usr/bin/env bash
# Structural lint for a LORE corpus. Read-only.
#
#   ERROR  — mechanically wrong; fix before considering the entry landed
#   WARN   — convention violation worth a human look
#
# Checks:
#   E1  entry has YAML frontmatter
#   E2  frontmatter carries a non-empty `sources:` (the provenance/trust chain)
#   E3  frontmatter carries `created:`
#   E4  entry has an H1 title line
#   E5  entry is linked from INDEX.md
#   E6  every INDEX.md link resolves to a file that exists
#   W1  slug is not snake_case
#   W2  a gist's *lead sentence* carries `Superseded` (the retired version
#       would be delivered as the whole message)
#   W3  `Corrected by` sits in a gist's tail, not its lead (a reader who stops
#       at the lead keeps the wrong version)
#
# usage: lore-lint.sh [corpus-dir]     (default: whatever lore-dir.sh resolves)
set -uo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dir="${1:-}"
if [ -z "$dir" ]; then
	dir=$("$here/lore-dir.sh") || exit 1
fi
if [ ! -d "$dir" ]; then
	echo "lore-lint: not a directory: $dir" >&2
	exit 1
fi

index="$dir/INDEX.md"
errors=0
warns=0
err() {
	errors=$((errors + 1))
	printf 'ERROR %s\n' "$*"
}
warn() {
	warns=$((warns + 1))
	printf 'WARN  %s\n' "$*"
}

shopt -s nullglob
entries=("$dir"/*.md)
count=0

if [ ! -f "$index" ]; then
	err "no INDEX.md in $dir"
fi

for f in "${entries[@]}"; do
	slug=$(basename "$f" .md)
	if [ "$slug" = INDEX ]; then continue; fi
	count=$((count + 1))

	case "$slug" in
	*[!a-z0-9_]*) warn "$slug: slug is not snake_case" ;;
	esac

	if [ "$(head -n1 "$f")" != "---" ]; then
		err "$slug: no YAML frontmatter"
	else
		fm=$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$f")
		# sources: may be a flow list on the key line, or a block list below it.
		src=$(printf '%s\n' "$fm" | awk '
			/^sources:/ {
				rest = $0; sub(/^sources:[[:space:]]*/, "", rest)
				if (rest != "" && rest != "[]") { print "ok"; exit }
				inblock = 1; next
			}
			inblock && /^[[:space:]]+-[[:space:]]*[^[:space:]]/ { print "ok"; exit }
			inblock && /^[^[:space:]]/ { exit }
		')
		if [ "$src" != ok ]; then
			err "$slug: empty or missing sources: (no provenance)"
		fi
		if ! printf '%s\n' "$fm" | grep -q '^created:'; then
			err "$slug: missing created:"
		fi
	fi

	if ! grep -qE '^# .' "$f"; then
		err "$slug: no H1 title line"
	fi

	if [ -f "$index" ] && ! grep -qF "$slug" "$index"; then
		err "$slug: not linked from INDEX.md (entry and index are a dual write)"
	fi
done

if [ -f "$index" ]; then
	# E6: every markdown link target in the index must exist. Process
	# substitution, not a pipe — a `| while` runs in a subshell and its
	# err()/warn() increments would be discarded at the end of the pipeline.
	while read -r target; do
		case "$target" in
		/*) p="$target" ;;
		*) p="$dir/$target" ;;
		esac
		if [ ! -e "$p" ]; then
			err "INDEX.md links a missing entry: $target"
		fi
	done < <(grep -oE '\]\([^)]+\.md\)' "$index" | tr -d ']()' | sort -u)

	# W2/W3: lead-sentence discipline inside each gist table cell.
	while read -r code slug; do
		case "$code" in
		W2) warn "$slug: 'Superseded' in the gist LEAD — the retired version is the whole message" ;;
		W3) warn "$slug: 'Corrected by' in the gist TAIL — a lead-only reader keeps the wrong version" ;;
		esac
	done < <(awk -F'|' '
		function lead(s,   i, n, ch, nxt, pre) {
			n = length(s)
			for (i = 2; i < n; i++) {
				ch = substr(s, i, 1)
				if (ch != ".") continue
				nxt = substr(s, i + 1, 1)
				if (nxt != " ") continue
				pre = tolower(substr(s, i - 2, 2))
				if (pre == "e.g" || pre == "i.e") continue
				if (tolower(substr(s, i - 2, 3)) == "vs.") continue
				if (tolower(substr(s, i - 3, 3)) == "etc") continue
				return substr(s, 1, i)
			}
			return s
		}
		/^\|/ && NF >= 4 {
			slug = $2; gsub(/^[[:space:]]*\[|\].*$/, "", slug)
			gist = $3
			if (slug == "Lore" || slug ~ /^[[:space:]]*-+[[:space:]]*$/ || slug == "") next
			l = lead(gist)
			tail = substr(gist, length(l) + 1)
			if (index(l, "Superseded") > 0) printf "W2 %s\n", slug
			if (index(tail, "Corrected by") > 0 && index(l, "Corrected by") == 0) printf "W3 %s\n", slug
		}
	' "$index")
fi

printf '\n%s: %d entries, %d errors, %d warnings\n' "$dir" "$count" "$errors" "$warns"
[ "$errors" -eq 0 ]
