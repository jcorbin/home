#!/usr/bin/env bash
# Resolve the LORE corpus directory for the current working directory.
#
# Resolution order (first hit wins):
#   1. $CLAUDE_LORE_DIR                 — explicit override, always honoured
#   2. <repo root>/LORE/                — project corpus
#   3. $HOME/LORE/                      — cross-project corpus (portable lessons)
#
# Prints the resolved absolute path on stdout. With -v, prints the reason on
# stderr. Exits 1 if nothing exists and --create was not given.
#
# This script is the single implementation of corpus resolution; both
# `lore-capture` and `lore-recall` call it rather than each re-deriving the
# rule. Two copies of a lookup rule with nothing enforcing agreement drift.
set -uo pipefail

create=0
verbose=0
scope=auto

usage() {
	cat >&2 <<'EOF'
usage: lore-dir.sh [--create] [--scope auto|project|user] [-v]

  --create   create the directory (and an INDEX.md stub) if none exists
  --scope    auto (default) | project (never fall back to $HOME/LORE)
                            | user (go straight to $HOME/LORE)
  -v         explain the choice on stderr
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--create) create=1 ;;
	--scope)
		shift
		scope="${1:-auto}"
		;;
	--scope=*) scope="${1#--scope=}" ;;
	-v | --verbose) verbose=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "lore-dir.sh: unknown argument: $1" >&2
		usage
		exit 2
		;;
	esac
	shift
done

say() {
	if [ "$verbose" -eq 1 ]; then echo "lore-dir: $*" >&2; fi
}

user_lore="$HOME/LORE"

emit() {
	say "$2"
	printf '%s\n' "$1"
	exit 0
}

seed_index() {
	local dir="$1"
	if [ -e "$dir/INDEX.md" ]; then return 0; fi
	mkdir -p "$dir" || return 1
	cat >"$dir/INDEX.md" <<'EOF'
# LORE index

One row per entry: the slug (which states the lesson as a claim), a one-line
gist, and its tags. Scan the section matching what you are about to touch.

**The gist's lead sentence is the whole message.** Anything that reads only the
lead — a person skimming, a context stamp that truncates — must not be
misdirected by it. Append later *incidents* to the tail; fold *corrections*
into the lead and leave the retired wording below it, marked
`Superseded (<ref>):`.

## General

| Lore | Gist | Tags |
| --- | --- | --- |
EOF
	say "seeded $dir/INDEX.md"
}

if [ -n "${CLAUDE_LORE_DIR:-}" ]; then
	if [ -d "$CLAUDE_LORE_DIR" ]; then
		emit "$CLAUDE_LORE_DIR" "CLAUDE_LORE_DIR is set"
	elif [ "$create" -eq 1 ]; then
		seed_index "$CLAUDE_LORE_DIR" && emit "$CLAUDE_LORE_DIR" "CLAUDE_LORE_DIR is set (created)"
		echo "lore-dir.sh: could not create $CLAUDE_LORE_DIR" >&2
		exit 1
	else
		echo "lore-dir.sh: CLAUDE_LORE_DIR=$CLAUDE_LORE_DIR does not exist (pass --create)" >&2
		exit 1
	fi
fi

if [ "$scope" = user ]; then
	if [ -d "$user_lore" ]; then
		emit "$user_lore" "--scope user"
	elif [ "$create" -eq 1 ]; then
		seed_index "$user_lore" && emit "$user_lore" "--scope user (created)"
		echo "lore-dir.sh: could not create $user_lore" >&2
		exit 1
	else
		echo "lore-dir.sh: $user_lore does not exist (pass --create)" >&2
		exit 1
	fi
fi

root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$root" ] && [ -d "$root/LORE" ]; then
	emit "$root/LORE" "project corpus at repo root"
fi

if [ "$scope" != project ] && [ -d "$user_lore" ]; then
	emit "$user_lore" "no project corpus here; cross-project fallback"
fi

if [ "$create" -eq 1 ]; then
	if [ -n "$root" ] && [ "$scope" = project ]; then
		seed_index "$root/LORE" && emit "$root/LORE" "created project corpus"
		echo "lore-dir.sh: could not create $root/LORE" >&2
		exit 1
	fi
	seed_index "$user_lore" && emit "$user_lore" "created cross-project corpus"
	echo "lore-dir.sh: could not create $user_lore" >&2
	exit 1
fi

echo "lore-dir.sh: no lore corpus found (pass --create to make one)" >&2
exit 1
