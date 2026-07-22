#!/usr/bin/env bash
#
# upload-testflight.sh — archive + upload to TestFlight, fully automated.
#
# Uses Xcode's signed-in Apple account (automatic signing). It does NOT need
# and will NOT ask for an App Store Connect API key or issuer ID. The only
# manual step that can ever be required is a one-time re-login in
# Xcode → Settings → Accounts if the account session expires.
#
# It does NOT bump the build number — ship whatever version/build the project
# currently has. (Bump explicitly yourself if you want a new build number.)
#
# Usage:
#   scripts/upload-testflight.sh [SCHEME] [TEAM_ID]
#   SCHEME=MyApp TEAM_ID=ABCDE12345 scripts/upload-testflight.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCHEME="${1:-${SCHEME:-}}"
TEAM_ID="${2:-${TEAM_ID:-${DEVELOPMENT_TEAM:-}}}"

# Auto-detect the scheme if not given (first shared scheme).
if [[ -z "$SCHEME" ]]; then
  SCHEME="$(xcodebuild -list -json 2>/dev/null | /usr/bin/python3 -c \
    'import json,sys; d=json.load(sys.stdin); p=d.get("project") or d.get("workspace") or {}; s=p.get("schemes",[]); print(s[0] if s else "")')"
fi
[[ -z "$SCHEME" ]] && { echo "❌ Could not detect a scheme. Pass it: scripts/upload-testflight.sh <Scheme>"; exit 1; }

# Auto-detect the team from the project if not given.
if [[ -z "$TEAM_ID" ]]; then
  TEAM_ID="$(grep -m1 -oE 'DEVELOPMENT_TEAM = [A-Z0-9]+' *.xcodeproj/project.pbxproj 2>/dev/null | awk '{print $3}' || true)"
fi

ARCHIVE="/tmp/${SCHEME}.xcarchive"
EXPORT_DIR="/tmp/${SCHEME}-export"
PLIST="/tmp/${SCHEME}-ExportOptions.plist"

echo "▶︎ Scheme: $SCHEME    Team: ${TEAM_ID:-<from project>}"

# 1. Archive (Release).
echo "▶︎ Archiving…"
rm -rf "$ARCHIVE"
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE" \
  -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates \
  ${TEAM_ID:+DEVELOPMENT_TEAM="$TEAM_ID"} \
  | tail -3

# 2. ExportOptions — App Store Connect, automatic signing, upload destination.
#    No authenticationKey* keys → uses the Xcode-signed-in account.
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key><string>app-store-connect</string>
    <key>destination</key><string>upload</string>
    <key>signingStyle</key><string>automatic</string>
    <key>uploadSymbols</key><true/>
    ${TEAM_ID:+<key>teamID</key><string>$TEAM_ID</string>}
</dict>
</plist>
PLIST

# 3. Export + upload.
echo "▶︎ Uploading to TestFlight…"
rm -rf "$EXPORT_DIR"
set +e
OUT="$(xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$PLIST" \
  -exportPath "$EXPORT_DIR" \
  -allowProvisioningUpdates 2>&1)"
CODE=$?
set -e
echo "$OUT" | tail -6

if [[ $CODE -ne 0 ]]; then
  if echo "$OUT" | grep -q "Failed to Use Accounts\|App Store Connect access"; then
    cat <<'MSG'

⚠️  Xcode's Apple account session expired (lost App Store Connect access).
    This is the ONLY manual step — fix it once, then re-run this script:

      Xcode → Settings (⌘,) → Accounts → select your Apple ID
      → re-enter password + complete 2FA.

    Do NOT switch to an App Store Connect API key / issuer ID — the auto
    account flow is what we use. Re-login is the fix.
MSG
  fi
  exit $CODE
fi

echo "✅ Uploaded $SCHEME to TestFlight (build number unchanged). Processing in App Store Connect."
