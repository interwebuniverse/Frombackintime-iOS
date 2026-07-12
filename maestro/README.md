# FromBackInTime · Automated UI tests

Hands-off UI testing so you don't have to click through the app by hand. Two layers:

1. **Maestro flows** (this folder) - a saved regression suite that drives the app
   like a real user and asserts what shows up. Run it with one command; it runs
   itself.
2. **XcodeBuildMCP** (configured in `../.mcp.json`) - lets Claude build, launch,
   tap, and screenshot the simulator on demand for exploratory checks. See
   "Agentic testing" below.

Everything runs against the **`FromBackInTime-Mock`** scheme: in-memory seeded
data, no backend, no network flakiness - the ideal deterministic target.

## Quick start

```bash
# from the repo root
./maestro/run.sh                 # build Mock, install, run every flow
./maestro/run.sh --no-build      # reuse the installed app (faster)
./maestro/run.sh flows/07_create_voice_e2e.yaml   # one flow
./maestro/run.sh --tags e2e      # only end-to-end flows
```

The runner boots/uses a simulator, builds + installs the Mock app, pre-grants
mic/camera/photos permissions (so no system dialog interrupts), and runs Maestro.

### Prerequisites (one-time)

- **Xcode** + an iOS simulator (default `iPhone 17 Pro`; override with
  `FBIT_SIM="iPhone 16" ./maestro/run.sh`).
- **Java** - Maestro is a JVM CLI. `brew install openjdk`.
- **Maestro** in `~/.maestro` - `curl -Ls https://get.maestro.mobile.dev | bash`
  (or download the `cli-*` release from the Maestro repo and unzip to `~/.maestro`).

## Flows

| # | Flow | What it covers |
|---|------|----------------|
| 02 | `navigation` | Home / People / Library tab switching |
| 03 | `home` | Seeded stat tiles, people strip, upcoming feed, idea row |
| 04 | `people` | People search + open a person's message page |
| 05 | `add_person` | Add a recipient, verify it appears |
| 06 | `library` | Filter pills (All / Scheduled / CTM) + search |
| 07 | `create_voice_e2e` | **Record real audio -> save -> composer returns clean** |
| 08 | `create_text_e2e` | **Write a message -> save -> composer returns clean** |
| 09 | `create_video_reach` | Create video up to the recorder |
| 10 | `create_photo_reach` | Create photo up to the composer |
| 11 | `message_detail_play` | Open a voice message, exercise Play |
| 12 | `edit_message` | Edit a message's occasion via "Edit details", save, verify |
| 13 | `ctm_arm` | Arm a Critical Timed Message + Home check-in |
| 14 | `delete_person` | Add then delete a recipient |
| 15 | `settings` | Settings rows render |

All 14 pass (`>>> 0 flow(s) failed`).

**Onboarding** (`onboarding-live.draft.yaml`, not in the default run): the Mock
scheme runs as a signed-in user (see below), and the app auto-completes
onboarding for a signed-in session, so onboarding doesn't appear under Mock. A
fresh anonymous user on the **live** scheme does see it - the draft flow targets
that but is unverified end-to-end (its buttons are gated by animations that need
wait tuning). Otherwise exercise onboarding via the agentic MCP loop below.

## How the flows find elements (important)

Maestro's iOS driver matches on **visible text** and **`.accessibilityLabel`** -
it does **not** reliably read SwiftUI `.accessibilityIdentifier`. So flows anchor
on the app's real on-screen text. Two gotchas baked into the flows:

- **`.textCase(.uppercase)` is visual only:** the accessibility text stays the
  source case, so flows anchor on section text via the recipient tap that
  follows rather than the header. (Some section headers do surface uppercased in
  screenshots but not reliably in the tree - avoid them as anchors.)
- **Keyboard dismissal:** iOS 26 doesn't expose `hideKeyboard` here. Single-line
  fields are dismissed with `pressKey: Enter`; the create form also dismisses on
  scroll (`.scrollDismissesKeyboard`). The written-message composer keeps its
  Save button above the keyboard, so no dismissal is needed there.
- **Tabs are tapped by point** (`50%,94%` etc.): the words "Home"/"People" also
  appear as Home stat-tile labels, so a text tap is ambiguous.
- **Icon-only buttons are tapped by point** (the record/stop circle at
  `50%,88%`): a SwiftUI `Button` whose label is pure shapes isn't exposed to the
  accessibility tree, so it isn't queryable by text.
- **Install from the right path.** The Mock scheme builds the **Mock**
  configuration -> `build/dd/Build/Products/Mock-iphonesimulator/`, NOT
  `Debug-iphonesimulator/`. `run.sh` finds the `.app` with `find`; never hardcode
  the Debug path (installing a stale app produces phantom failures).
- **Mock signs in a test user.** The app starts anonymous and gates
  create/add-person behind a real Apple/Google sign-in. So the suite can exercise
  those, `AuthStore.ensureSession`/`signInAnonymously`/`restoreFromStoredSession`
  have a `#if MOCK` branch that signs in a test user. Live builds are unaffected.

### On the "3 bugs" (resolved - they were not real)
An earlier pass of this suite reported three bugs (Add-person Email field missing,
"Edit details" missing, CTM won't arm). **All three were a test-harness artifact,
not app bugs:** the install step was pointing at a stale `Debug-iphonesimulator`
build instead of the current `Mock-iphonesimulator` one. On the correct build the
Add-person form shows all three fields, "Edit details" renders, and "Activate CTM"
arms - all verified, all covered by passing flows (05, 12, 13). The install path
is fixed above.

## What isn't automated (by design)

- **Real camera / photo-library capture** uses the OS picker, which depends on
  the simulator's media library. Video/photo flows stop at the composer.
- **Apple / Google sign-in** open system auth sheets. The Mock scheme signs in a
  test user (above) so save/add flows don't hit the gate; the onboarding draft
  uses the live scheme.

## Agentic testing (XcodeBuildMCP)

`../.mcp.json` registers `xcodebuildmcp`. After restarting Claude Code in this
repo (and approving the server), Claude can build, launch, tap, and **screenshot**
the simulator itself - useful for "walk the app and tell me what looks broken"
passes that complement the saved suite. The saved flows are the regression net;
the MCP is the on-demand explorer.

## CI

`maestro test maestro/` exits non-zero if any flow fails, so it drops into CI as
a single step once a simulator is available on the runner.
