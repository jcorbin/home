#!/usr/bin/env bash
# mint-anchor.sh — mint this retcon's `refs/backup/pre-retcon-<branch>-<id>`
# anchor, retiring any previous anchor FOR THE SAME BRANCH to
# `refs/rescue/<name>` in the same breath.  Replaces a bare `git branch` at
# step 1 of the retcon procedure.
#
# NEITHER A TAG NOR A BRANCH.  Recovery scaffolding lives in its own ref arena,
# and two independent constraints pin that:
#
#   NOT refs/tags/**   — that is the RELEASE namespace.  `git tag --list` should
#                        answer "which versions exist"; interleaving recovery
#                        scaffolding there makes it answer nothing.
#   NOT refs/heads/**  — anything parked under refs/heads is visible to every
#                        piece of branch-walking machinery in the repo (branch
#                        listings, sweeps, CI ref filters, `git branch --contains`
#                        noise) whether or not you want it.  Measured hazard, not
#                        a stylistic preference.
#
# `refs/backup/**` and `refs/rescue/**` are ordinary refs: objects stay
# reachable, `git update-ref -d` still deletes, `git for-each-ref refs/rescue/`
# still enumerates.  They are simply invisible to the two namespaces that have
# machinery attached.
#
# THE INVARIANT: at most ONE `pre-retcon-<branch>-*` anchor per branch at any
# moment.  Creation performs retirement, so the pile cannot rebuild.
#
# Why an invariant and not an age heuristic.  An anchor is often load-bearing
# well after its retcon — the dependent-branch re-pointing that consumes it can
# happen a day later, inside almost any plausible N-day window.  Here an anchor
# lives until the NEXT retcon of the same branch, which is always strictly later
# than the re-pointing that consumes it.  The window closes because it was
# superseded, never because a clock ran out.
#
# The predecessor moves to `refs/rescue/<same-name>` rather than being deleted:
# objects stay reachable, and undoing a wrong deletion costs far more than
# deleting a surplus ref later.
#
# The rescue ref is an ANNOTATED TAG OBJECT parked outside refs/tags, minted with
# `git mktag`.  The annotation names what superseded the ref, which is the only
# record of why it stopped being live; a bare commit ref would discard it.
# `git mktag` rather than `git tag -a` because the latter can only write to
# refs/tags, and a name that transits the release namespace — even for one
# command — is a name someone's `git tag --list` or `git push --tags` can catch.
#
# Unlike its dry-run-by-default sibling (audit-backup-refs.sh) this script ACTS
# by default.  Its only mutation is re-parking a ref at an identical commit,
# verified equal before the old name is dropped — lossless.  Pass --dry-run to
# look first.
#
# See SKILL.md §"Anchor lifecycle".

# NOTE: `-e` omitted deliberately; every fatal path goes through die().
set -uo pipefail

BR=
ID=
DRY=0

die() {
  printf 'mint-anchor: %s\n' "$*" >&2
  exit 1
}

usage() {
  sed -n '2,/^set -uo/p' "$0" | sed 's/^# \{0,1\}//; $d'
  cat <<'EOF'

usage: mint-anchor.sh [--branch <branch>] [--id <id>] [--dry-run]

  --branch <branch>  branch being retconned (default: the current branch)
  --id <id>          anchor suffix, conventionally a date (default: today)
  --dry-run          report what would happen; change nothing

Prints the anchor ref name on stdout so the caller can capture it:

  ANCHOR=$(mint-anchor.sh --branch feature/thing | tail -1)
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --branch)
      BR=${2:?--branch needs a value}
      shift 2
      ;;
    --id)
      ID=${2:?--id needs a value}
      shift 2
      ;;
    --dry-run)
      DRY=1
      shift
      ;;
    -h | --help) usage ;;
    *) die "unknown argument: $1" ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"

[ -n "$ID" ] || ID=$(date +%F)
[ -n "$BR" ] || BR=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
[ -n "$BR" ] || die "HEAD is detached; pass --branch"

git rev-parse --verify -q "$BR^{commit}" >/dev/null || die "no such branch: $BR"

# Full ref names throughout.  A short name in the recovery arena would be
# ambiguous against a same-named branch or tag, and `git rev-parse` would prefer
# the wrong one silently.
NAME="pre-retcon-$BR-$ID"
ANCHOR="refs/backup/$NAME"

git check-ref-format "$ANCHOR" ||
  die "branch name yields an invalid ref: $ANCHOR"

printf 'branch : %s (%s)\n' "$BR" "$(git rev-parse --short "$BR")"
printf 'anchor : %s\n' "$ANCHOR"
printf 'mode   : %s\n\n' "$([ "$DRY" = 1 ] && echo 'DRY-RUN' || echo APPLY)"

rgit() {
  if [ "$DRY" = 1 ]; then
    printf '  would: git %s\n' "$*" >&2
    return 0
  fi
  git "$@"
}

# mkrescue <dest-ref> <src-ref> <message> — park <src-ref>'s commit at <dest-ref>
# as an ANNOTATED tag object carrying <message>.  See the header for why mktag
# and not `git tag -a`.
mkrescue() {
  local dest=$1 src=$2 msg=$3 sha obj
  sha=$(git rev-parse "$src^{commit}") || return 1
  if [ "$DRY" = 1 ]; then
    printf '  would: git mktag -> %s (annotated, at %s)\n' "$dest" "${sha:0:9}" >&2
    return 0
  fi
  # `git var GIT_COMMITTER_IDENT` gives an fsck-valid `Name <email> ts tz` line;
  # mktag runs a strict fsck and rejects anything malformed, so a bad identity
  # fails here rather than producing an unreadable object.
  obj=$(printf 'object %s\ntype commit\ntag %s\ntagger %s\n\n%s\n' \
    "$sha" "${dest#refs/}" "$(git var GIT_COMMITTER_IDENT)" "$msg" |
    git mktag) || return 1
  rgit update-ref "$dest" "$obj" || return 1
}

# ------------------------------------------------------- retire the predecessor
#
# Scoped to THIS branch's anchors.  A `refs/backup/pre-retcon-*` glob would be
# wrong in a repo where several branches get retconned: it would retire another
# branch's live rollback point.  Enumerating `refs/backup/**` and prefix-matching
# in the shell rather than globging in for-each-ref, because for-each-ref
# patterns do not let `*` cross a `/` and branch names routinely contain one.
mapfile -t OLD < <(
  git for-each-ref --format='%(refname)' 'refs/backup/**' |
    while IFS= read -r r; do
      case "${r#refs/backup/}" in
        "pre-retcon-$BR-"*) [ "$r" = "$ANCHOR" ] || printf '%s\n' "$r" ;;
      esac
    done
)

for old in "${OLD[@]:-}"; do
  [ -n "$old" ] || continue
  rescue="refs/rescue/${old#refs/backup/}"
  old_sha=$(git rev-parse "$old^{commit}")

  if git rev-parse --verify -q "$rescue" >/dev/null; then
    # Same commit already preserved => the rescue ref IS the retirement; just
    # drop the anchor.  Different commit => a name collision we must not paper
    # over.
    have=$(git rev-parse "$rescue^{commit}")
    [ "$have" = "$old_sha" ] ||
      die "$rescue exists at $have but $old is at $old_sha — resolve by hand"
    printf 'RETIRE  %-52s (%s already present)\n' "$old" "$rescue"
  else
    mkrescue "$rescue" "$old" "retired retcon anchor $old, superseded by $ANCHOR" ||
      die "failed to park $old at $rescue"
    # Verify the rescue ref resolves to the same commit BEFORE dropping the
    # anchor.  Without this the failure mode is silent and total.
    if [ "$DRY" = 0 ] && [ "$(git rev-parse "$rescue^{commit}")" != "$old_sha" ]; then
      die "$rescue != $old ($old_sha) — refusing to delete the anchor"
    fi
    printf 'RETIRE  %-52s -> %s\n' "$old" "$rescue"
  fi

  rgit update-ref -d "$old" >/dev/null || die "failed to delete $old"
done

[ "${#OLD[@]}" -gt 0 ] && [ -n "${OLD[0]}" ] ||
  printf 'RETIRE  (none — no predecessor anchor for %s)\n' "$BR"

# ------------------------------------------------------------- mint the new one

if git rev-parse --verify -q "$ANCHOR" >/dev/null; then
  # Re-running on the same day is fine so long as it already points where it
  # should; pointing elsewhere means a retcon is mid-flight and this would
  # destroy its rollback.
  have=$(git rev-parse "$ANCHOR^{commit}")
  want=$(git rev-parse "$BR^{commit}")
  [ "$have" = "$want" ] ||
    die "$ANCHOR already exists at $have but $BR is at $want.
That anchor is another retcon's rollback point. Pass a distinct --id."
  printf 'MINT    %-52s (already at %s)\n' "$ANCHOR" "$(git rev-parse --short "$BR")"
else
  # The anchor itself is a LIGHTWEIGHT ref straight at the commit: it is a live
  # rollback point, not a historical record, so there is no provenance message to
  # carry and `git diff $ANCHOR $BR` should read as plainly as possible.
  #
  # --create-reflog is load-bearing, not decoration.  git only auto-logs
  # refs/heads, refs/remotes, refs/notes and HEAD, so an arena ref would have no
  # reflog — and audit-backup-refs.sh derives ref AGE from the oldest reflog
  # entry precisely because the fallback (creatordate = the tip COMMIT's date)
  # over-estimates it, which is what would let `--older-than` retire a
  # freshly-minted anchor that happens to point at an old commit.
  rgit update-ref --create-reflog "$ANCHOR" "$(git rev-parse "$BR^{commit}")" >/dev/null ||
    die "failed to create $ANCHOR"
  printf 'MINT    %-52s -> %s\n' "$ANCHOR" "$(git rev-parse --short "$BR")"
fi

# Assert the invariant we exist to maintain, so a regression is loud.
if [ "$DRY" = 0 ]; then
  # Same prefix-match-in-the-shell as the retirement loop above: a for-each-ref
  # glob cannot express "this branch's anchors" when the branch name has a `/`,
  # and building a grep pattern out of a branch name needs escaping nobody gets
  # right twice.
  n=$(
    git for-each-ref --format='%(refname)' 'refs/backup/**' |
      while IFS= read -r r; do
        case "${r#refs/backup/}" in
          "pre-retcon-$BR-"*) printf 'x\n' ;;
        esac
      done | wc -l
  )
  [ "$n" = 1 ] || die "INVARIANT VIOLATED: $n anchor refs survive for $BR, expected exactly 1"
  # The arena move is only real if the old homes stay empty.  A stray anchor
  # branch is the phantom-sweep hazard walking back in.
  stray=$(git for-each-ref --format='%(refname)' \
    'refs/heads/backup/**' 'refs/tags/rescue/**' 'refs/tags/backup/**')
  [ -z "$stray" ] || die "recovery refs found outside the arena:
$stray"
fi

printf '\n%s\n' "$ANCHOR"
