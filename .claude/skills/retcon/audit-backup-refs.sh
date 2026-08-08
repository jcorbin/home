#!/usr/bin/env bash
# audit-backup-refs.sh — mechanize the containment proof that says a
# `refs/backup/**` ref is safe to retire.  Doing this by hand over a dozen refs
# costs a full session, almost all of it spent PROVING deletion safe rather than
# deleting.
#
# The recovery ARENA is `refs/backup/**` (candidates) and `refs/rescue/**`
# (retired), neither of which is a tag or a branch — see mint-anchor.sh's header
# for the two constraints that pin that.
#
# For each backup ref it computes the EXACT set of objects that deleting the ref
# would orphan, then classifies the residue by PATH:
#
#   CLEAN   zero unique objects — every commit/tree/blob is reachable from a
#           durable ref, so deleting orphans nothing and parking it would add
#           nothing.  Delete outright.
#   SUPER   unique objects exist, but every unique BLOB sits on a path a tip ref
#           still holds — i.e. it is an older revision of a live file, which is
#           precisely what a retcon collapses.  Park at `refs/rescue/<name>`,
#           then delete.
#   REVIEW  anything else: unique blobs on paths with no counterpart anywhere.
#           Never retired automatically — a human decides.
#   PINNED  a tracked file says `recovered_from: <this ref>` or
#           `evidence_ref: <this ref>`, i.e. the tree holds a written statement
#           that this ref is load-bearing.  Never retired, at any age, under any
#           of the above.  See "the pins" below.
#
# TWO TRAPS THIS ENCODES, both hit by hand:
#
#   1. `git rev-list --objects B --not <refs>` OVERSTATES uniqueness.  It marks
#      trees UNINTERESTING lazily, so it will report a blob as unique to a backup
#      ref when that blob is the SAME OBJECT a durable ref already holds.  Use an
#      exact `comm -23` set difference.  Do not "simplify" it back.
#
#   2. One deletion candidate must not vouch for another.  Every `refs/backup/**`
#      ref is excluded from the durable set, as is `refs/stash` (worktree-local,
#      and shared across all worktrees of the repo — never a durability
#      guarantee).  Pass `--ephemeral <regex>` for any other ref class the repo
#      reaps routinely (short-lived task/PR branches, for instance):
#      reachability through a ref that gets deleted is not durable reachability.
#      Excluding more refs shrinks the durable set, so verdicts can only move
#      TOWARD review — the safe direction.
#
# Dry-run by default; `--apply` performs the park-then-delete for CLEAN and SUPER
# refs only.
#
# See SKILL.md §"Anchor lifecycle".

# NOTE: `-e` is deliberately omitted.  This classifies ref-by-ref and must carry
# on past one that faults, and non-zero exits from `grep`/`comm` are load-bearing
# signals here, not errors.
set -uo pipefail

APPLY=0
OLDER_THAN=
INCLUDE_ANCHOR=0
USE_PINS=1
declare -a WANT_REFS=()
declare -a TIPS=()
declare -a EPHEMERAL=()
declare -a IGNORE_PATH=()

# Frontmatter keys by which a tracked file claims a backup ref is load-bearing.
# Both are statements a HUMAN wrote into the tree; they differ only in what they
# assert:
#
#   recovered_from:  "I pulled content OUT of this ref" — the act.
#   evidence_ref:    "this ref IS the evidence; keep it" — the judgement, for the
#                    reviewer who accounted for a ref's residue, concluded it is
#                    load-bearing, and recovered nothing.
#
# Both only ever WITHHOLD retirement, which is why a coarse ref-name key is safe
# for them and would not be for a record that GRANTS it — see "the pins".
PIN_KEYS='recovered_from|evidence_ref'

die() {
  printf 'audit-backup-refs: %s\n' "$*" >&2
  exit 1
}

usage() {
  sed -n '2,/^set -uo/p' "$0" | sed 's/^# \{0,1\}//; $d'
  cat <<'EOF'

usage: audit-backup-refs.sh [options]

  --tip <ref>           a ref whose paths count as "still held" for the SUPER
                        test, and whose tracked files are scanned for pins.
                        Repeatable.  Default: the current branch.  Add the
                        integration base, or any long-lived branch, when a
                        backup ref predates content that moved.
  --ref <ref>           audit only this ref; repeatable.  Default is every
                        refs/backup/** ref.  Accepts any ref, which is how you
                        re-check an already-retired refs/rescue/** tip.
  --ephemeral <regex>   additionally exclude refs matching this ERE from the
                        durable set (e.g. '^refs/heads/wip/').  Repeatable.
  --ignore-path <regex> paths matching this ERE are never residue (editor
                        droppings, atomic-write scratch files).  Repeatable.
  --older-than <days>   consider only refs created more than N days ago.  Age is
                        a FILTER on top of the containment proof, never a
                        predicate on its own: a REVIEW ref is never retired no
                        matter how old, because an anchor can be load-bearing
                        long after its retcon.
  --include-anchor      also consider live `pre-retcon-*` anchors, which are
                        otherwise always skipped — retcon owns their lifecycle
                        (see mint-anchor.sh).
  --apply               actually retire CLEAN / SUPER refs.  Without this the
                        script only reports.
  --no-pins             ignore `recovered_from:` / `evidence_ref:` pins.
                        Reproduces the un-pinned verdicts, which is how you see
                        what a pin is holding back.  Never combine with --apply
                        on a sweep: that is precisely the run that deletes the
                        evidence a recovery was drawn from.

exit status: 0 when nothing needs review and nothing errored, 1 otherwise.
PINNED is exit 0: unlike REVIEW it is not a pending question — someone already
looked and wrote the finding into the tree.
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tip)
      TIPS+=("${2:?--tip needs a value}")
      shift 2
      ;;
    --ref)
      WANT_REFS+=("${2:?--ref needs a value}")
      shift 2
      ;;
    --ephemeral)
      EPHEMERAL+=("${2:?--ephemeral needs a value}")
      shift 2
      ;;
    --ignore-path)
      IGNORE_PATH+=("${2:?--ignore-path needs a value}")
      shift 2
      ;;
    --older-than)
      OLDER_THAN=${2:?--older-than needs a value}
      shift 2
      ;;
    --include-anchor)
      INCLUDE_ANCHOR=1
      shift
      ;;
    --apply)
      APPLY=1
      shift
      ;;
    --no-pins)
      USE_PINS=0
      shift
      ;;
    -h | --help) usage ;;
    *) die "unknown argument: $1" ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git worktree"

if [ ${#TIPS[@]} -eq 0 ]; then
  t=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  [ -n "$t" ] || die "HEAD is detached; pass --tip"
  TIPS=("$t")
fi
for t in "${TIPS[@]}"; do
  git rev-parse --verify -q "$t^{commit}" >/dev/null || die "no such tip ref: $t"
done

if [ -n "$OLDER_THAN" ]; then
  case "$OLDER_THAN" in
    '' | *[!0-9]*) die "--older-than takes a whole number of days, got: $OLDER_THAN" ;;
  esac
fi

TMP=$(mktemp -d) || die "mktemp failed"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------- the ref set

if [ ${#WANT_REFS[@]} -eq 0 ]; then
  # NOTE the `**`: `refs/backup/*` does NOT match nested names such as
  # `backup/conflict-2026-07-25/some-branch`.  Auditing with a single `*` silently
  # misses every nested ref.
  mapfile -t WANT_REFS < <(git for-each-ref --format='%(refname)' 'refs/backup/**')
fi

if [ ${#WANT_REFS[@]} -eq 0 ]; then
  printf 'no refs/backup/** refs — nothing to audit.\n'
  exit 0
fi

# --------------------------------------------------------- the durable object set

# Durable = every ref EXCEPT the backup refs themselves (all candidates for
# deletion, so one cannot vouch for another), the stash, and whatever the caller
# named as ephemeral.
DURABLE_EXCLUDE='^(refs/backup/|refs/stash)'
for e in "${EPHEMERAL[@]:-}"; do
  [ -n "$e" ] || continue
  DURABLE_EXCLUDE="$DURABLE_EXCLUDE|($e)"
done

git for-each-ref --format='%(refname)' |
  grep -Ev "$DURABLE_EXCLUDE" >"$TMP/durable_refs"

[ -s "$TMP/durable_refs" ] || die "no durable refs found — refusing to call everything unique"

git rev-list --objects --stdin <"$TMP/durable_refs" |
  awk '{print $1}' | LC_ALL=C sort -u >"$TMP/durable_objs"

# Every path the tips currently hold — the SUPER test.  A unique blob whose path
# still exists is simply an older revision of a live file.
: >"$TMP/held_paths"
for t in "${TIPS[@]}"; do
  git ls-tree -r --name-only "$t" >>"$TMP/held_paths"
done
LC_ALL=C sort -u -o "$TMP/held_paths" "$TMP/held_paths"

# ------------------------------------------------------------------- the pins
#
# The SUPER arm accepts a unique blob on the strength of its PATH alone.  That is
# right for an ordinary superseded revision and wrong for a recovery, because a
# recovery lands the ref's own content — so the ref comes to vouch for itself
# through its own rescue:
#
#   1. a silent drop strands content, and the backup ref is the only copy — the
#      paths are gone from the tips, so the ref correctly reads REVIEW;
#   2. REVIEW is never auto-retired, which is how anyone finds out at all;
#   3. someone recovers the content FROM THAT REF because of the refusal;
#   4. the recovery restores the paths — so the ref now reads SUPER;
#   5. the evidence becomes retirable one repair after the repair.
#
# The break is the recovery's own record.  A file carrying `recovered_from: <ref>`
# is a statement, written into the tree by whoever did the recovery, that <ref> is
# load-bearing.  `evidence_ref: <ref>` is its twin for a reviewer who kept a ref
# without recovering anything.
#
# THERE IS DELIBERATELY NO VERDICT STORE.  Every objection to one — where does it
# live, a ref name is too coarse, it becomes a stale allowlist, it needs an expiry
# — bites only a record that can GRANT retirement.  None survives contact with a
# record that can only WITHHOLD it: it cannot be stale in the dangerous direction
# (worst case, a ref kept too long), cannot be too coarse (a pinned ref that also
# holds unaccounted paths still reads REVIEW and still lists them), and needs no
# expiry because it lives in a file a human maintains and this output names on
# every run.  So "keep this ref" is recordable and "I accounted for this residue"
# is not; close a REVIEW by making the underlying fact true, or by retiring the
# ref by hand with the accounting written into the rescue annotation.
#
# Three properties keep the arm narrow:
#   * only STRUCTURED frontmatter-style lines on tracked files count.  A ref
#     merely mentioned in prose is not thereby load-bearing.
#   * a pin changes the ACTION and the LABEL, never the classification.  The
#     residue analysis still runs, and a pinned ref that also holds unaccounted
#     paths still reads REVIEW and still lists them.  Hiding that would suppress
#     exactly the signal that exposed this class.
#   * a pin can only ever WITHHOLD retirement — it can never make a REVIEW ref
#     retirable — so the arm is one-way safe by construction.
: >"$TMP/pins"
if [ "$USE_PINS" = 1 ]; then
  for t in "${TIPS[@]}"; do
    # `git grep -l <rev>` prints `<rev>:<path>`.  Re-reading each hit with
    # `git show` keeps value extraction independent of that parse, and pins are
    # rare enough that the extra process per hit does not matter.
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      p=${hit#*:}
      git show "$t:$p" 2>/dev/null |
        sed -n -E "s#^[[:space:]]*($PIN_KEYS):[[:space:]]*(refs/[^[:space:]]+)[[:space:]]*\$#\\2 \\1#p" |
        while read -r r k; do printf '%s\t%s\t%s\n' "$r" "$p" "$k"; done
    done < <(git grep -l -I -E "^[[:space:]]*($PIN_KEYS):[[:space:]]*refs/" "$t" 2>/dev/null)
  done >>"$TMP/pins"
  LC_ALL=C sort -u -o "$TMP/pins" "$TMP/pins"
fi

# Wall clock, NOT any tip's commit date: a quiet repo must not make every backup
# ref look a day older each day it idles.
NOW=$(date +%s)

printf 'tips    : %s\n' "$(printf '%s ' "${TIPS[@]}")"
printf 'durable : %s refs, %s objects\n' \
  "$(wc -l <"$TMP/durable_refs")" "$(wc -l <"$TMP/durable_objs")"
printf 'held    : %s paths\n' "$(wc -l <"$TMP/held_paths")"
printf 'mode    : %s\n\n' "$([ "$APPLY" = 1 ] && echo APPLY || echo 'DRY-RUN (pass --apply to retire)')"

# ---------------------------------------------------------------- ref age

# Ref CREATION time, from the oldest reflog entry.  Deliberately not
# `creatordate`: that is the tip COMMIT's date, which for a backup ref
# over-estimates the ref's age — it would let an age sweep retire a freshly-minted
# ref that happens to point at an old commit.  Falls back to creatordate only when
# no reflog exists (git auto-logs only refs/heads, refs/remotes, refs/notes and
# HEAD, which is why the creation sites pass `--create-reflog`).  Two residual
# cases keep the fallback honest: refs/rescue/** tag objects, whose creatordate is
# the TAGGER date and so is the true retirement time; and refs migrated by hand,
# which read as older than they are — and since age is only ever a FILTER on top
# of the containment proof, reading too old can only admit a ref to an audit it
# still has to pass.
ref_created_at() {
  local ref=$1 stamp=
  stamp=$(git log -g --date=unix --format='%gd' "$ref" 2>/dev/null |
    tail -1 | sed -E 's/^.*@\{([0-9]+)\}$/\1/')
  case "$stamp" in
    '' | *[!0-9]*) git for-each-ref --format='%(creatordate:unix)' "$ref" ;;
    *) printf '%s\n' "$stamp" ;;
  esac
}

# ---------------------------------------------------------------- retirement

# retire <ref> <keep|"">.  Parks the ref at refs/rescue/<name> first when asked,
# then drops it from refs/backup/**.  Park-first, delete-second is not stylistic:
# undoing a wrong deletion costs far more than deleting a surplus ref later.  Both
# ends stay in the recovery arena — never refs/heads/** and never refs/tags/**.
#
# The rescue ref is an ANNOTATED tag object, minted with `git mktag` because
# `git tag -a` can only write under refs/tags.  The annotation is the only record
# of WHY the ref stopped being live, so a bare commit ref would lose it — and that
# cuts both ways: a backup ref may ITSELF be an annotated tag whose message
# carries the real forensics, so peeling straight to `^{commit}` would leave the
# incoming annotation reachable from nothing.  Carry it forward.
retire() {
  local ref=$1 mode=$2 name rescue sha obj msg prior
  name=${ref#refs/backup/}
  rescue="refs/rescue/$name"
  if [ "$mode" = keep ]; then
    if git rev-parse --verify -q "$rescue" >/dev/null; then
      printf '          ! %s already exists — leaving %s alone\n' "$rescue" "$ref"
      return 1
    fi
    sha=$(git rev-parse "$ref^{commit}") || return 1
    msg="retired backup ref $ref (audit-backup-refs.sh)"
    if [ "$(git cat-file -t "$ref" 2>/dev/null)" = tag ]; then
      prior=$(git for-each-ref --format='%(contents)' "$ref")
      if [ -n "${prior%%[[:space:]]}" ]; then
        msg="$msg

was, verbatim from the retired tag object $(git rev-parse "$ref"):

$prior"
      fi
    fi
    obj=$(printf 'object %s\ntype commit\ntag %s\ntagger %s\n\n%s\n' \
      "$sha" "rescue/$name" "$(git var GIT_COMMITTER_IDENT)" "$msg" |
      git mktag) || return 1
    git update-ref --create-reflog "$rescue" "$obj" >/dev/null || return 1
    # Verify the rescue ref resolves to the same commit BEFORE dropping it.
    if [ "$(git rev-parse "$rescue^{commit}")" != "$sha" ]; then
      printf '          ! %s != %s — refusing to delete\n' "$rescue" "$ref"
      return 1
    fi
    printf '          -> parked at %s\n' "$rescue"
  fi
  git update-ref -d "$ref" >/dev/null || return 1
  [ "$mode" = keep ] || printf '          -> deleted (objects durable elsewhere)\n'
  return 0
}

# ---------------------------------------------------------------- the audit

n_clean=0 n_super=0 n_review=0 n_skip=0 n_err=0 n_retired=0 n_pin=0

for REF in "${WANT_REFS[@]}"; do
  [ -n "$REF" ] || continue

  if ! git rev-parse --verify -q "$REF^{commit}" >/dev/null; then
    printf 'ERROR   %-58s no such ref\n' "$REF"
    n_err=$((n_err + 1))
    continue
  fi
  SHORT=$(git rev-parse --short "$REF^{commit}")

  case "${REF#refs/backup/}" in
    pre-retcon-*)
      if [ "$INCLUDE_ANCHOR" = 0 ]; then
        printf 'ANCHOR  %-58s %s  live retcon anchor — skipped (see mint-anchor.sh)\n' "$REF" "$SHORT"
        n_skip=$((n_skip + 1))
        continue
      fi
      ;;
  esac

  if [ -n "$OLDER_THAN" ]; then
    created=$(ref_created_at "$REF")
    age_days=$(((NOW - created) / 86400))
    if [ "$age_days" -lt "$OLDER_THAN" ]; then
      printf 'YOUNG   %-58s %s  %sd old < %sd — skipped\n' "$REF" "$SHORT" "$age_days" "$OLDER_THAN"
      n_skip=$((n_skip + 1))
      continue
    fi
  fi

  # Computed before the classification but applied after it: the residue analysis
  # still runs in full, because a pinned ref that ALSO holds unaccounted paths has
  # to keep saying so.
  PINNED_BY=$(LC_ALL=C awk -F'\t' -v r="$REF" '$1 == r {print $2}' "$TMP/pins" | paste -sd, -)
  PINNED_VIA=$(LC_ALL=C awk -F'\t' -v r="$REF" '$1 == r {print $3}' "$TMP/pins" |
    LC_ALL=C sort -u | paste -sd/ -)

  # EXACT set difference.  See trap 1 in the header: never `rev-list --not`.
  git rev-list --objects "$REF" >"$TMP/ref_named" || {
    printf 'ERROR   %-58s rev-list faulted\n' "$REF"
    n_err=$((n_err + 1))
    continue
  }
  awk '{print $1}' "$TMP/ref_named" | LC_ALL=C sort -u >"$TMP/ref_objs"
  LC_ALL=C comm -23 "$TMP/ref_objs" "$TMP/durable_objs" >"$TMP/uniq"

  n_uniq=$(wc -l <"$TMP/uniq")
  if [ "$n_uniq" -eq 0 ]; then
    if [ -n "$PINNED_BY" ]; then
      printf 'PINNED  %-58s %s  0 unique objects, but %s: in %s\n' \
        "$REF" "$SHORT" "$PINNED_VIA" "$PINNED_BY"
      n_pin=$((n_pin + 1))
      continue
    fi
    printf 'CLEAN   %-58s %s  0 unique objects\n' "$REF" "$SHORT"
    n_clean=$((n_clean + 1))
    [ "$APPLY" = 1 ] && retire "$REF" "" && n_retired=$((n_retired + 1))
    continue
  fi

  git cat-file --batch-check='%(objectname) %(objecttype)' <"$TMP/uniq" >"$TMP/uniq_typed"
  n_cm=$(awk '$2 == "commit"' "$TMP/uniq_typed" | wc -l)
  n_tr=$(awk '$2 == "tree"' "$TMP/uniq_typed" | wc -l)
  awk '$2 == "blob" {print $1}' "$TMP/uniq_typed" | LC_ALL=C sort -u >"$TMP/uniq_blobs"
  n_bl=$(wc -l <"$TMP/uniq_blobs")

  # Map unique blobs back to the paths they occupy in this ref's history.
  LC_ALL=C sort -k1,1 "$TMP/ref_named" >"$TMP/ref_named_sorted"
  LC_ALL=C join -j 1 -o 2.2 "$TMP/uniq_blobs" "$TMP/ref_named_sorted" |
    LC_ALL=C sort -u >"$TMP/uniq_paths"

  # The path still EXISTS on a tip: the unique blob is an older revision of a
  # live file, which is precisely what a retcon collapses.  Nothing to explain.
  LC_ALL=C comm -23 "$TMP/uniq_paths" "$TMP/held_paths" >"$TMP/gone_paths"

  # The path is GONE.  That is residue a human accounts for — unless the caller
  # named it ignorable (scratch/atomic-write droppings).
  : >"$TMP/residue"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    skip=0
    for ig in "${IGNORE_PATH[@]:-}"; do
      [ -n "$ig" ] || continue
      if printf '%s\n' "$p" | grep -Eq "$ig"; then
        skip=1
        break
      fi
    done
    [ "$skip" = 1 ] && continue
    printf '%s\n' "$p" >>"$TMP/residue"
  done <"$TMP/gone_paths"

  n_res=$(wc -l <"$TMP/residue")
  if [ "$n_res" -eq 0 ]; then
    # The PIN OVERRIDE.  "Every path is still held" is exactly the verdict a
    # recovery MANUFACTURES: it writes the ref's own content back into the tree,
    # which restores the paths, which empties the residue.  Without this branch
    # the repair certifies its own evidence as disposable.
    if [ -n "$PINNED_BY" ]; then
      printf 'PINNED  %-58s %s  %s/%s/%s cm/tr/blob, all paths held ONLY because %s says %s: this ref\n' \
        "$REF" "$SHORT" "$n_cm" "$n_tr" "$n_bl" "$PINNED_BY" "$PINNED_VIA"
      n_pin=$((n_pin + 1))
      continue
    fi
    printf 'SUPER   %-58s %s  %s/%s/%s cm/tr/blob, all paths still held\n' \
      "$REF" "$SHORT" "$n_cm" "$n_tr" "$n_bl"
    n_super=$((n_super + 1))
    [ "$APPLY" = 1 ] && retire "$REF" keep && n_retired=$((n_retired + 1))
  else
    # No pin branch here on purpose: REVIEW already withholds retirement, and the
    # unaccounted-path list is the signal that exposed this class in the first
    # place.  A pin only ever adds context to it.
    printf 'REVIEW  %-58s %s  %s/%s/%s cm/tr/blob, %s unaccounted path(s):\n' \
      "$REF" "$SHORT" "$n_cm" "$n_tr" "$n_bl" "$n_res"
    sed 's/^/          · /' "$TMP/residue"
    [ -n "$PINNED_BY" ] &&
      printf '          (also pinned: %s: this ref in %s)\n' "$PINNED_VIA" "$PINNED_BY"
    n_review=$((n_review + 1))
  fi
done

printf '\nsummary: %d clean, %d superseded, %d pinned, %d need review, %d skipped, %d errored' \
  "$n_clean" "$n_super" "$n_pin" "$n_review" "$n_skip" "$n_err"
[ "$APPLY" = 1 ] && printf ' — %d retired' "$n_retired"
printf '\n'

if [ "$n_pin" -gt 0 ]; then
  printf '\nThe PINNED refs would otherwise have been retired, but a tracked file names\n'
  printf 'them in a recovered_from: field (someone recovered work FROM them, which is\n'
  printf 'exactly what makes their content look superseded) or an evidence_ref: field\n'
  printf '(someone reviewed them and judged them load-bearing without recovering).\n'
  printf 'Re-run with --no-pins to see the verdict the pin is holding back.\n'
fi

if [ "$n_review" -gt 0 ]; then
  printf '\nThe REVIEW refs hold unique blobs on paths with no counterpart on any tip.\n'
  printf 'That is not proof of loss — a deliberate removal looks identical. It IS the\n'
  printf 'point where a human has to look. Do not retire them blind. Widening --tip\n'
  printf 'often resolves them: a path that moved to another long-lived branch is not\n'
  printf 'lost, it is just not on the tip you audited against.\n'
  printf '\nThere is deliberately no way to record "I looked and it is fine" — that would\n'
  printf 'be a stored switch a later run could trip. CLOSE the review instead: make the\n'
  printf 'underlying fact true so the verdict changes honestly (recover what is lost, or\n'
  printf 'point --tip at the store that holds it), or retire the ref by hand with the\n'
  printf 'accounting written into the refs/rescue/ tag annotation. To KEEP one as\n'
  printf 'evidence, put evidence_ref: <ref> in a tracked file and it reads PINNED.\n'
fi

[ "$n_review" = 0 ] && [ "$n_err" = 0 ]
