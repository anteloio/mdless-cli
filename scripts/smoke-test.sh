#!/bin/sh
# Smoke test for the published package. It does what a user does:
# pack the package, install the tarball in an empty folder, run the CLI.
# Run it with `bun run smoke`. CI runs it before every release.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

fail() {
  echo "✗ $*" >&2
  exit 1
}

echo "→ npm pack"
TARBALL=$(cd "$ROOT" && npm pack --silent --pack-destination "$WORK" | tail -n 1)
TARBALL="$WORK/$TARBALL"
[ -f "$TARBALL" ] || fail "npm pack did not create a tarball"

# The tarball must hold only what the CLI needs at runtime.
CONTENTS=$(tar -tzf "$TARBALL")
for f in package/dist/index.js package/src/agents/prompts/orchestrator.md package/assets/lets-go.mp3; do
  echo "$CONTENTS" | grep -qx "$f" || fail "$f is missing from the tarball"
done
if echo "$CONTENTS" | grep -E 'package/(bin\.mjs|src/.*\.ts|assets/.*\.png)$'; then
  fail "the tarball holds development files (listed above)"
fi

echo "→ npm install <tarball>"
mkdir -p "$WORK/install"
(cd "$WORK/install" && npm init -y >/dev/null && npm install --silent --no-audit --no-fund "$TARBALL")
INSTALLED=$(ls "$WORK/install/node_modules")
[ "$INSTALLED" = "@mdless" ] || fail "the package pulled extra dependencies: $INSTALLED"
MDLESS="$WORK/install/node_modules/.bin/mdless"

# Fake `claude` and audio players, so the test spends nothing and plays no sound.
FAKEBIN="$WORK/fakebin"
mkdir -p "$FAKEBIN"
cat > "$FAKEBIN/claude" <<'SH'
#!/bin/sh
echo "$@" > "$MDLESS_SMOKE_LOG/claude-args"
echo '{"type":"system","subtype":"init","session_id":"smoke-test","tools":[]}'
echo '{"type":"assistant","message":{"content":[{"type":"text","text":"hello from fake claude"}]}}'
echo '{"type":"result","num_turns":1,"duration_ms":10,"total_cost_usd":0}'
SH
for player in afplay mpg123; do
  printf '#!/bin/sh\necho "$1" > "$MDLESS_SMOKE_LOG/sound"\n' > "$FAKEBIN/$player"
done
chmod +x "$FAKEBIN"/*
export MDLESS_SMOKE_LOG="$WORK"
export PATH="$FAKEBIN:$PATH"

echo "→ mdless --version"
EXPECTED=$(node -p "require('$ROOT/package.json').version")
ACTUAL=$("$MDLESS" --version)
[ "$ACTUAL" = "$EXPECTED" ] || fail "mdless --version printed '$ACTUAL', expected '$EXPECTED'"

echo "→ mdless init"
PROJECT="$WORK/project"
mkdir -p "$PROJECT"
(cd "$PROJECT" && "$MDLESS" init)
[ -s "$PROJECT/.mdless/agents/orchestrator.md" ] || fail "init did not copy orchestrator.md"
grep -qx ".mdless/worktrees/" "$PROJECT/.gitignore" || fail "init did not update .gitignore"

echo "→ mdless agent orchestrator"
OUTPUT=$(cd "$PROJECT" && "$MDLESS" agent orchestrator)
echo "$OUTPUT" | grep -q "hello from fake claude" || fail "agent did not show the output of claude"
grep -q -- "--output-format stream-json" "$WORK/claude-args" || fail "agent called claude with unexpected arguments"
# The sound player starts in the background: give it a moment.
i=0
while [ ! -f "$WORK/sound" ] && [ $i -lt 20 ]; do sleep 0.1; i=$((i + 1)); done
[ -f "$WORK/sound" ] || fail "agent did not start a startup sound"
[ -f "$(cat "$WORK/sound")" ] || fail "startup sound file not found: $(cat "$WORK/sound")"

echo "→ npx <tarball> --version"
ACTUAL=$(cd "$WORK" && npx --yes --package "$TARBALL" mdless --version)
[ "$ACTUAL" = "$EXPECTED" ] || fail "npx mdless --version printed '$ACTUAL', expected '$EXPECTED'"

echo "✓ smoke test passed ($EXPECTED)"
