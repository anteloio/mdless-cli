#!/bin/sh
# Checks that a pull-request title follows conventional commits, and prints
# the release it will give after a squash merge.
# Usage: sh scripts/check-pr-title.sh "feat: add --every"
# CI runs it on every pull request (.github/workflows/pr-title.yml).
set -eu

TITLE=${1:-}

fail() {
  cat >&2 <<MSG
✗ $1
  title: "$TITLE"

  The title must look like "<type>: <description>" or "<type>(<scope>): <description>",
  in lowercase. Add "!" before ":" for a breaking change.
    fix: ... / perf: ...                          -> patch release
    feat: ...                                     -> minor release
    feat!: ...                                    -> major release
    chore / docs / refactor / test / build / ci / style -> no release
  To undo a released change, use "fix: revert ...". The type "revert:" gives no release.
MSG
  exit 1
}

printf '%s' "$TITLE" | grep -Eq '^[a-z]+(\([a-z0-9._/-]+\))?!?: [^ ]' || fail "the title does not follow conventional commits"

TYPE=$(printf '%s' "$TITLE" | sed -E 's/^([a-z]+).*/\1/')
case "$TYPE" in
  feat) RELEASE=minor ;;
  fix | perf) RELEASE=patch ;;
  chore | docs | refactor | test | build | ci | style) RELEASE=none ;;
  revert) fail 'the type "revert:" gives no release. Use "fix: revert ..." to publish the undo' ;;
  *) fail "unknown type \"$TYPE\"" ;;
esac

if printf '%s' "$TITLE" | grep -Eq '^[a-z]+(\([^)]*\))?!:'; then
  RELEASE=major
fi

if [ "$RELEASE" = none ]; then
  echo "✓ \"$TITLE\" -> no release"
else
  echo "✓ \"$TITLE\" -> $RELEASE release"
fi
