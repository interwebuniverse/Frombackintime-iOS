#!/usr/bin/env bash
#
# One-command Maestro runner for FromBackInTime.
#
#   ./maestro/run.sh                 # build Mock, install, run the whole suite
#   ./maestro/run.sh --no-build      # skip the xcodebuild step (reuse installed app)
#   ./maestro/run.sh flows/07_create_voice_e2e.yaml   # run a single flow
#   ./maestro/run.sh --tags e2e      # run only flows tagged e2e
#
# Requires: Xcode, a booted iOS simulator, Java (openjdk), and Maestro in ~/.maestro.
#
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

SCHEME="FromBackInTime-Mock"
BUNDLE_ID="com.frombackintime.app"
# Preferred simulator; falls back to the first booted device.
DEVICE_NAME="${FBIT_SIM:-iPhone 17 Pro}"
DERIVED="build/dd"

# --- Java (Maestro is a JVM CLI) -------------------------------------------
if [ -z "${JAVA_HOME:-}" ]; then
  if command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix)/opt/openjdk" ]; then
    export JAVA_HOME="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
  fi
fi
export MAESTRO_CLI_NO_ANALYTICS=1
MAESTRO="${MAESTRO:-$HOME/.maestro/bin/maestro}"

# --- Arg parsing ------------------------------------------------------------
BUILD=1; TARGET="maestro/flows"; TAGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --no-build) BUILD=0; shift ;;
    --tags) TAGS="$2"; shift 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done
# Allow flow paths relative to the maestro/ dir.
[ -f "maestro/$TARGET" ] && TARGET="maestro/$TARGET"

# --- Pick a booted simulator ------------------------------------------------
UDID="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1 || true)"
if [ -z "$UDID" ]; then
  echo ">>> Booting '$DEVICE_NAME'"
  UDID="$(xcrun simctl list devices available | grep "$DEVICE_NAME (" | grep -Eo '[0-9A-F-]{36}' | head -1)"
  xcrun simctl boot "$UDID"
  open -a Simulator
  sleep 5
fi
echo ">>> Simulator: $UDID"

# --- Build + install --------------------------------------------------------
if [ "$BUILD" -eq 1 ]; then
  echo ">>> Building $SCHEME"
  xcodebuild -project FromBackInTime.xcodeproj -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" -derivedDataPath "$DERIVED" \
    build | tail -2
fi
# The Mock scheme builds the "Mock" configuration -> Mock-iphonesimulator (NOT
# Debug-iphonesimulator). Find the product instead of hardcoding the path.
APP="$(find "$DERIVED/Build/Products" -maxdepth 2 -name 'FromBackInTime.app' -path '*imulator*' | head -1)"
echo ">>> Installing $APP"
xcrun simctl install "$UDID" "$APP"

# --- Pre-grant media permissions so no system dialog interrupts -------------
for svc in microphone camera photos; do
  xcrun simctl privacy "$UDID" grant "$svc" "$BUNDLE_ID" 2>/dev/null || true
done

# --- Run --------------------------------------------------------------------
# When running the whole folder, execute each flow in its own `maestro test`
# invocation. A single folder run keeps one long-lived driver session, and if
# that XCTest connection drops mid-run ("Failed to connect to 127.0.0.1") every
# later flow fails; a fresh session per flow is far more reliable on the sim.
echo ">>> Running: $TARGET ${TAGS:+(tags: $TAGS)}"
if [ -n "$TAGS" ]; then
  exec "$MAESTRO" --device "$UDID" test --include-tags "$TAGS" "$TARGET"
elif [ -d "$TARGET" ]; then
  fails=0
  for flow in "$TARGET"/*.yaml; do
    name="$(basename "$flow")"
    if "$MAESTRO" --device "$UDID" test "$flow" >/tmp/maestro_$$.log 2>&1; then
      echo "  PASS  $name"
    else
      echo "  FAIL  $name"
      grep -iE "Assertion is false|Element not found|Failed to connect" /tmp/maestro_$$.log | head -1 | sed 's/^/        /'
      fails=$((fails + 1))
    fi
  done
  rm -f /tmp/maestro_$$.log
  echo ">>> $fails flow(s) failed"
  exit $((fails > 0 ? 1 : 0))
else
  exec "$MAESTRO" --device "$UDID" test "$TARGET"
fi
