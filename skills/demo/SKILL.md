---
name: demo
description: Record a full walkthrough of an iOS flow on the simulator and save the screen recording to ~/Documents/ as a demo .mov. Walks Claude through picking the flow, optionally patching the app's start screen, generating a UITest that drives the flow with mock data, running the recorder, and restoring the app.
---

# /demo — Record a demo video of an app flow

When the user types `/demo`, they want you to produce a polished
screen-recorded walkthrough of some flow in the iOS app, saved to
`~/Documents/<Project>Demo-<timestamp>.mov`.

The recording must:

1. Open with **a couple of seconds of the iOS home screen (springboard)**
   — so the viewer sees the simulator launch the app (feels like a real
   user opening the app).
2. Walk through the chosen flow end-to-end, driven by a UITest you
   generate. Use realistic mock data — no placeholders, no "Lorem
   Ipsum."
3. Pause ~1–2 seconds between screens so viewers can actually read
   things before they disappear.
4. Save the output to `~/Documents/<Project>Demo-<YYYYMMDD-HHMMSS>.mov`
   and reveal it in Finder (`open -R`).

## Files this skill uses

All paths are relative to the repo root.

| File | Purpose |
|---|---|
| `scripts/record-demo.sh` | Generic recorder wrapper — no need to touch per-flow. Orchestrates `simctl io recordVideo` around a UITest run. |
| `OrbaHealthUITests/<Name>DemoRecorder.swift` *(or the project's UITest target)* | The generated UITest. One file per flow. Named `<Flow>DemoRecorder.swift` (e.g. `OnboardingDemoRecorder.swift`, `CheckoutDemoRecorder.swift`). |
| `skills/demo/templates/DemoRecorder.swift.template` | Starter template for the UITest — copy, rename, fill in the steps. |

If any of those are missing in the project, copy them from
`skills/demo/templates/`.

## Interactive flow

Walk through it step by step. Don't dump all questions at once.

### 1. Ask which flow to record

Use `AskUserQuestion` with options sourced from the project's
`RouterDestination` enum + `LaunchView`. Present the destinations you
can detect as choices; leave an "Other" path for something
custom/off-router.

### 2. Ask whether the start point needs to be temporarily patched

If the flow lives behind a login / paywall / onboarding gate, offer to
temporarily edit `LaunchView.swift` (or the app's initial scene) so the
app opens directly on the target flow. **You must restore it after
recording** — commit the restore in the same change so it isn't
forgotten.

Ask the user:
- **Patch the start screen** — rewrites `LaunchView` to jump straight
  to the target flow, runs the recorder, then reverts.
- **Leave the start screen alone** — the UITest walks from whatever the
  app's natural launch is.

### 3. Ask for the mock data profile

Offer 2–3 ready-made profiles plus "Other":
- **Default happy-path** — obviously valid inputs, picks the first
  option in single-selects, "None of the above" on multi-selects,
  reasonable numbers.
- **Persona: power user** — fills fields with a more complete, realistic
  identity (full name, phone, detailed notes).
- **Persona: minimal** — does the bare minimum to advance (only
  required fields).
- **Other** — user writes the specific values they want.

Whatever they pick, **hard-code the values into the generated UITest as
`let` constants at the top of the file** so anyone reading the test
knows exactly what ran.

### 4. Generate the UITest

Copy `skills/demo/templates/DemoRecorder.swift.template` to the project's
UITest target as `<Flow>DemoRecorder.swift`. Fill it in:

- Replace `<<FLOW_NAME>>` with the flow's PascalCase name (e.g.
  `Onboarding`, `Checkout`).
- Replace `<<MOCK_DATA>>` with the profile's constants block.
- Write one `walk<Screen>(_:)` helper per screen. Keep them small and
  named after the screen. Use `sleep(animationPause)` between major
  transitions so the recording paces well.
- For tapping buttons, prefer the button's visible title:
  `app.buttons["Continue"].tap()`. For chip-style buttons where the label
  is "<emoji> <text>", use:
  `app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Male")).firstMatch.tap()`.
- For tapping non-button tappable views (e.g. cards using
  `.onTapGesture`), the view must expose `.accessibilityAddTraits(.isButton)`
  and `.accessibilityLabel(...)`. If missing, **add those modifiers to
  the app code as part of this change** — they also improve VoiceOver.

### 5. If the UITest target isn't wired up

- Check `project.pbxproj` for `TEST_TARGET_NAME = <HostApp>;` on both
  Debug and Release configs of the UITest target. If it still points
  at a stale starter name, fix it.
- Check the scheme has `OrbaHealthUITests` (or equivalent) as a test
  target.

### 6. Run the recorder

```
./scripts/record-demo.sh [simulator-udid]
```

The default simulator UDID inside the script should match whatever the
project has been using for local dev. If unsure, run
`xcrun simctl list devices booted` and pick one.

The script:
1. Terminates any running instance of the app.
2. Starts `xcrun simctl io <udid> recordVideo` in the background → this
   captures the springboard for 2 s before the app launches.
3. Runs `xcodebuild test -only-testing:<UITestTarget>/<Class>/<method>`
   with `-parallel-testing-enabled NO` so Xcode doesn't try to clone
   the device (which stalls on CI-restricted setups).
4. Stops the recording cleanly, moves the .mov into `~/Documents/`,
   and reveals it in Finder.

### 7. Restore any patches

If you touched `LaunchView.swift` (or any app code) to make the flow
start reachable, revert it now so the next build is clean. Commit the
revert alongside the skill-generated files, or stash it if the user
wants to keep the patched state for repeated recordings.

## When to decline or ask first

- If the user asks to record a flow that requires **real credentials,
  real payment processing, or sending real network traffic to
  production**, stop and ask. A demo recording should run against
  mock/local endpoints only.
- If the UITest would need to type **real secrets** (API keys,
  passwords the user actually uses), use obvious placeholder values
  and tell the user.

## What "done" looks like

- `~/Documents/<Project>Demo-<timestamp>.mov` exists and plays.
- `./scripts/record-demo.sh` is committable and runnable by another dev
  without extra setup.
- The UITest file is readable — any teammate can open it and see the
  mock values + the shape of the flow in one glance.
- The app code is back in its pre-demo state (or the patch is
  intentionally committed with a clear explanation).

## Reference implementation

See `OrbaHealth/` (the consumer project) for a full working example:
- `scripts/record-demo.sh`
- `OrbaHealthUITests/OnboardingDemoRecorder.swift`
- Accessibility helpers on the send circle + consent cards that made
  the UITest stable.
