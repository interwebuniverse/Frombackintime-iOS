#!/usr/bin/env bash
#
# record-demo.sh — drives a UITest-based walkthrough on the iOS
# simulator and saves a screen recording to ~/Documents/.
#
# See skills/demo/SKILL.md for the full design.
#
# Usage:
#   scripts/record-demo.sh                    # default test + simulator
#   scripts/record-demo.sh <simulator-udid>   # specific simulator
#   TEST_ID=... scripts/record-demo.sh        # override the -only-testing id

set -euo pipefail

# ------------------------ PROJECT CONFIG ---------------------------------
SCHEME="FromBackInTime"
BUNDLE_ID="com.frombackintime.app"
DEFAULT_UDID=""                                             # set to a booted iPhone UDID or leave empty to auto-detect
DEFAULT_TEST_ID="FromBackInTimeUITests/ExampleDemoRecorder/testRecordExampleWalkthrough"
# -------------------------------------------------------------------------

UDID="${1:-$DEFAULT_UDID}"
TEST_ID="${TEST_ID:-$DEFAULT_TEST_ID}"

if [[ -z "$UDID" ]]; then
  UDID="$(xcrun simctl list devices booted -j | /usr/bin/python3 -c '
import json, sys
data = json.load(sys.stdin)
for booted in data.get("devices", {}).values():
    for d in booted:
        if d.get("state") == "Booted":
            print(d["udid"]); sys.exit(0)
')"
fi

if [[ -z "$UDID" ]]; then
  echo "error: no booted simulator found. Pass a UDID or boot one first." >&2
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$(ls "$PROJECT_DIR"/*.xcodeproj 2>/dev/null | head -n 1)"

if [[ -z "$PROJECT_FILE" ]]; then
  echo "error: no .xcodeproj found at $PROJECT_DIR" >&2
  exit 1
fi

DEST="platform=iOS Simulator,id=$UDID"
OUT_DIR="$HOME/Documents"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_PATH="$OUT_DIR/${SCHEME}Demo-$STAMP.mov"

mkdir -p "$OUT_DIR"

echo "==> Using simulator $UDID"
open -a Simulator

echo "==> Terminating any running $BUNDLE_ID instance"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

echo "==> Starting screen recording → $OUT_PATH"
xcrun simctl io "$UDID" recordVideo --codec=h264 --mask=black "$OUT_PATH" &
REC_PID=$!

sleep 2

cleanup() {
  if kill -0 "$REC_PID" 2>/dev/null; then
    echo "==> Stopping recording"
    kill -INT "$REC_PID" 2>/dev/null || true
    wait "$REC_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "==> Running UITest walkthrough"
xcodebuild test \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DEST" \
  -parallel-testing-enabled NO \
  -disable-concurrent-destination-testing \
  -only-testing:"$TEST_ID" \
  COMPILER_INDEX_STORE_ENABLE=NO

sleep 2

cleanup
trap - EXIT

echo ""
echo "==> Done. Demo saved to: $OUT_PATH"
open -R "$OUT_PATH"
