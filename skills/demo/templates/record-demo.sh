#!/usr/bin/env bash
#
# record-demo.sh — drives a full flow walkthrough on the iOS simulator
# and saves a screen recording to ~/Documents/.
#
# Flow:
#   1. Terminate the app so the simulator sits on the springboard.
#   2. Start `simctl io recordVideo` in the background — this gives
#      the recording a ~2s opening of the iOS home screen.
#   3. Run the UITest (which launches the app + walks the flow).
#   4. Stop the recording cleanly, move the .mov into ~/Documents/,
#      and reveal it in Finder.
#
# Usage:
#   scripts/record-demo.sh                    # default test + simulator
#   scripts/record-demo.sh <simulator-udid>   # specific simulator
#   TEST_ID=...UITests/Foo/bar scripts/record-demo.sh
#
# Edit the DEFAULT_UDID / DEFAULT_TEST_ID / SCHEME / BUNDLE_ID below
# when adopting this script in a new project.

set -euo pipefail

# ------------------------ PROJECT CONFIG ---------------------------------
SCHEME="<<SCHEME>>"                                # e.g. "OrbaHealth"
BUNDLE_ID="<<BUNDLE_ID>>"                          # e.g. "com.orbahealth.app"
DEFAULT_UDID="<<DEFAULT_SIMULATOR_UDID>>"          # iPhone 17 Pro simulator UDID
DEFAULT_TEST_ID="<<UITESTS_TARGET>>/<<TEST_CLASS>>/<<TEST_METHOD>>"
# Example:
#   DEFAULT_TEST_ID="OrbaHealthUITests/OnboardingDemoRecorder/testRecordFullOnboardingWalkthrough"
# -------------------------------------------------------------------------

UDID="${1:-$DEFAULT_UDID}"
TEST_ID="${TEST_ID:-$DEFAULT_TEST_ID}"
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

echo "==> Booting simulator $UDID (if needed)"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator

echo "==> Terminating any running $BUNDLE_ID instance"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
sleep 1

echo "==> Starting screen recording → $OUT_PATH"
xcrun simctl io "$UDID" recordVideo --codec=h264 --mask=black "$OUT_PATH" &
REC_PID=$!

# Give the springboard a beat so the recording opens on the home screen
# before the app launches.
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

# Tail so the recording catches the final tap / screen.
sleep 2

cleanup
trap - EXIT

echo ""
echo "==> Done. Demo saved to: $OUT_PATH"
open -R "$OUT_PATH"
