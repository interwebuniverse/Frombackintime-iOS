# Superwall hard paywall

The app is hard-gated after onboarding: a user who finishes onboarding but isn't
subscribed is shown the Superwall paywall and can't reach the app until they pay.
The check runs at the end of onboarding **and** on every launch.

## What's wired (code)

- **SDK**: `SuperwallKit` (Superwall-iOS, SPM, up to next major from 4.0.0), added
  to the app target.
- **`FromBackInTime/App/Config/SuperwallConfig.swift`** — the API key + the gate
  placement name.
- **`FromBackInTime/Paywall/PaywallManager.swift`** — configures Superwall,
  mirrors entitlement status into `isSubscribed`, and presents the gate.
- **`FromBackInTime/Paywall/PaywallGateView.swift`** — the locked screen that
  presents the paywall.
- **`FromBackInTimeApp.swift`** — configures Superwall at launch and calls
  `identify(userId:)` once a session exists.
- **`RootView.swift`** — the gate:
  - not finished onboarding → onboarding
  - finished onboarding, entitlement still resolving → brief sky + spinner
  - finished onboarding, **subscribed** → the app (tab bar)
  - finished onboarding, **not subscribed** → the hard paywall

How the gate holds: the paywall is registered on the `onboarding_complete`
placement. With a **Gated** campaign the app only unlocks when the user is (or
becomes) entitled; a purchase/restore flips `subscriptionStatus` to `.active`,
which swaps RootView to the tab bar. If the user closes the paywall without
paying, `PaywallManager` re-presents it — there's no way in without subscribing.

The **Mock scheme runs as a subscribed test user** (`#if MOCK`), so the Maestro
suite and demos aren't blocked. Only real (live) builds gate.

## What you must do (2 things)

### 1. Set the API key
In `SuperwallConfig.swift`, replace the placeholder with your publishable key
(Superwall dashboard → Settings → Keys, starts with `pk_`). It's a client-public
key, safe to ship — same idea as the Supabase anon key.

### 2. Create the Gated campaign in the Superwall dashboard
1. New campaign.
2. Add the placement/trigger **`onboarding_complete`** (must match
   `SuperwallConfig.gatePlacement`).
3. Attach your paywall and set it to **Gated**.
4. For a true hard gate, design the paywall **without a close button** (the code
   re-presents on dismiss as a backstop, but non-dismissible is cleaner).
5. Add your products/entitlement in App Store Connect + Superwall so purchases
   grant an entitlement (this is what flips `isSubscribed`).

Until both are done, a live build will sit on the gate (fail-closed). The Mock
scheme is unaffected.

## Changing the gate

- Placement name → `SuperwallConfig.gatePlacement`.
- To gate individual features later instead of the whole app, call
  `Superwall.shared.register(placement: "...") { /* feature */ }` at those call
  sites and configure separate campaigns.
