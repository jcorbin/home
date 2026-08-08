#!/usr/bin/env bash
# verify.sh — assert the ONE load-bearing property of a retcon: the rewritten
# branch's tree is byte-identical to the pre-retcon tree, so
# `git diff <base>..<branch>` is unchanged.  Only the commit grouping moved.
#
# Three checks, in order of decisiveness:
#
#   1. `git diff <anchor> <branch>` is EMPTY.  Same tree, therefore same net
#      diff against any base.  This is the check; the rest is hygiene.
#   2. `git status --porcelain` is EMPTY.  A leftover unstaged or untracked file
#      is unbucketed SUBSTANCE that never made it into a commit — the failure
#      mode that ends with `git add -A` sweeping real source changes into a
#      lockfile commit.  Note this can pass check 1 and still be wrong: an
#      untracked file was never in the anchor's tree either.
#   3. Prints `git diff --stat <base>..<branch>` for eyeball comparison against
#      the pre-retcon stat, and the commit list the reviewer will actually see.
#
# A failure here is NOT something to patch up.  Roll back and start over:
#
#   git reset --hard <anchor>
#
# See SKILL.md §"Verify — and roll back if it fails".

set -uo pipefail

ANCHOR=
BR=
BASE=

die() {
  printf 'verify: %s\n' "$*" >&2
  exit 1
}

usage() {
  sed -n '2,/^set -uo/p' "$0" | sed 's/^# \{0,1\}//; $d'
  cat <<'EOF'

usage: verify.sh --anchor <ref> [--branch <branch>] [--base <ref>]

  --anchor <ref>     the pre-retcon anchor (refs/backup/pre-retcon-...).
                     Defaults to the sole anchor for --branch, if exactly one.
  --branch <branch>  the rewritten branch (default: current branch)
  --base <ref>       integration base, for the informational stat

exit status: 0 when the tree is identical and nothing is unbucketed, 1 otherwise.
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --anchor)
      ANCHOR=${2:?--anchor needs a value}
      shift 2
      ;;
    --branch)
      BR=${2:?--branch needs a value}
      shift 2
      ;;
    --base)
      BASE=${2:?--base needs a value}
      shift 2
      ;;
    -h | --help) usage ;;
    *) die "unknown argument: $1" ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git worktree"

[ -n "$BR" ] || BR=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
[ -n "$BR" ] || die "HEAD is detached; pass --branch"
git rev-parse --verify -q "$BR^{commit}" >/dev/null || die "no such branch: $BR"

if [ -z "$ANCHOR" ]; then
  # Same prefix-match rationale as mint-anchor.sh: for-each-ref globs will not
  # let `*` cross a `/`, and branch names routinely contain one.
  mapfile -t FOUND < <(
    git for-each-ref --format='%(refname)' 'refs/backup/**' |
      while IFS= read -r r; do
        case "${r#refs/backup/}" in
          "pre-retcon-$BR-"*) printf '%s\n' "$r" ;;
        esac
      done
  )
  case "${#FOUND[@]}" in
    1) ANCHOR=${FOUND[0]} ;;
    0) die "no anchor found for $BR; pass --anchor" ;;
    *) die "several anchors for $BR (invariant violated); pass --anchor:
$(printf '  %s\n' "${FOUND[@]}")" ;;
  esac
fi
git rev-parse --verify -q "$ANCHOR^{commit}" >/dev/null || die "no such anchor: $ANCHOR"

fail=0

printf 'anchor : %s (%s)\n' "$ANCHOR" "$(git rev-parse --short "$ANCHOR^{commit}")"
printf 'branch : %s (%s)\n' "$BR" "$(git rev-parse --short "$BR")"
[ -n "$BASE" ] && printf 'base   : %s (%s)\n' "$BASE" "$(git rev-parse --short "$BASE")"
printf '\n'

# ------------------------------------------------- 1. the tree must be identical
if git diff --quiet "$ANCHOR" "$BR"; then
  printf 'PASS    net diff invariant — %s and %s have the same tree\n' "$ANCHOR" "$BR"
else
  printf 'FAIL    NET DIFF CHANGED — %s and %s differ:\n\n' "$ANCHOR" "$BR"
  git diff --stat "$ANCHOR" "$BR" | sed 's/^/          /'
  printf '\n        Roll back: git reset --hard %s\n' "$ANCHOR"
  fail=1
fi

# ------------------------------------------- 2. nothing left unbucketed on disk
dirty=$(git status --porcelain)
if [ -z "$dirty" ]; then
  printf 'PASS    working tree clean — every path landed in a commit\n'
else
  printf 'FAIL    UNBUCKETED CONTENT — these never made it into a commit:\n\n'
  printf '%s\n' "$dirty" | sed 's/^/          /'
  printf '\n        Do NOT `git add -A` this into the last commit. Find the\n'
  printf '        feature each path belongs to and stage it there.\n'
  fail=1
fi

# --------------------------------------------------------- 3. informational
if [ -n "$BASE" ]; then
  if git rev-parse --verify -q "$BASE^{commit}" >/dev/null; then
    if git merge-base --is-ancestor "$BASE" "$BR"; then
      printf '\n--- %s..%s (%s commits) ---\n' "$BASE" "$BR" \
        "$(git rev-list --count "$BASE..$BR")"
      git log --oneline --no-decorate "$BASE..$BR" | sed 's/^/  /'
      printf '\n--- net diff stat vs %s ---\n' "$BASE"
      git diff --stat "$BASE..$BR" | tail -1 | sed 's/^/  /'
    else
      printf '\nWARN    %s is not an ancestor of %s — the base moved, or the\n' "$BASE" "$BR"
      printf '        branch lags it. Integrate the base before retconning.\n'
    fi
  else
    printf '\nWARN    no such base: %s\n' "$BASE"
  fi
fi

exit "$fail"
