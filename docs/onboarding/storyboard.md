# FromBackInTime — Onboarding Storyboard

Not design. Not copy-final. Just the storytelling spine: every screen, what we show, what we say, why we say it, and what the user does.

The job of this onboarding is to take a stranger from "huh, cool app" to "I need this" in under 3 minutes. We do that by telling them a story about themselves they didn't expect to hear today.

---

## The core emotional arc

```
Curiosity  →  Recognition  →  Vulnerability  →  Validation  →
Understanding  →  Trust  →  Vision  →  Commitment
```

Each act below maps to one beat. We never break this order. Skipping a beat breaks the spell.

---

## ACT 1 — The Hook (screens 1-3)
*No progress bar yet. We sell the feeling first. We do not ask for anything.*

### Screen 1: Cold open
- **What we show:** Black screen. Slow fade-in of a single line of light moving across the screen, like a candle flicker or a soft horizon. App wordmark fades in beneath.
- **What we say:** `FromBackInTime`
- **Why:** No promises yet. Mystery. The user is curious why the app is called this. We let the title do the work.
- **User action:** None. Auto-advances after 2.5s.

### Screen 2: The question that hooks
- **What we show:** A wide cinematic still. Quiet room. A phone on a table. Soft daylight through a window. No people. Subtitle floats up from the bottom.
- **What we say:**
  - Top whisper: `A question.`
  - Center headline: `What would you say to someone, if you knew you might not get the chance again?`
- **Why:** We open with the most emotional question the app can ever ask. Before features, before features, before pricing. The user reads it. Something tightens in their chest. They keep going.
- **User action:** Tap anywhere to continue.

### Screen 3: The promise
- **What we show:** Same quiet room, slightly brighter now. Two soft glowing dots, one labeled `today`, one labeled `someday`, with a faint line connecting them.
- **What we say:**
  - Headline: `Send what matters. To the people who matter. Across time.`
  - Subtitle: `Record now. We'll deliver it when the moment is right.`
  - Primary CTA: `Begin`
  - Secondary text: `I already have an account`
- **Why:** First time we tell them what the app does. We frame it as a gift across time, not as a feature.
- **User action:** Tap Begin.

---

## ACT 2 — Make it personal (screens 4-6)
*Progress bar appears. From here on, every line uses their name.*

### Screen 4: Name
- **What we show:** Almost nothing. Just space. A single soft input field.
- **What we say:**
  - Headline: `Before we begin, what should we call you?`
  - Placeholder: `First name`
  - Continue button (disabled until typed)
- **Why:** Asking for the name (not email, not account) signals we are not in a hurry to extract. We are getting to know them. Every later screen earns its emotional weight by using this name.
- **User action:** Type. Tap Continue.

### Screen 5: Soft welcome
- **What we show:** Warm pale background. A small slow-pulsing dot or hourglass shape centered. No mascot character. We are not Duolingo. We are quieter.
- **What we say:**
  - Headline: `Welcome, [Name].`
  - Subtitle: `Take your time here. None of this is rushed.`
- **Why:** Permission to slow down. Important because the next questions are heavy.
- **User action:** Continue.

### Screen 6: The first real question
- **What we show:** Clean question screen, no illustration. Options stack vertically as soft chips.
- **What we say:**
  - Headline: `Who is on your mind right now?`
  - Subtitle: `Pick whoever first came to your heart, even if it surprises you.`
  - Options (multi-select):
    - `Someone I love who is still here`
    - `Someone I've lost`
    - `My future self`
    - `My child, now or someday`
    - `A friend who needs to hear it`
    - `I'm not sure yet`
- **Why:** The first qualifier. It maps the user to a use case AND triggers emotional recognition. They pick something. Their brain commits.
- **User action:** Select one or more. Continue.

---

## ACT 3 — Mirror their feelings back (screens 7-10)
*This is where the user goes from curious to invested. Every question reveals an empathetic paragraph on selection, NoContact-style.*

### Screen 7: Why now
- **What we show:** Soft question card. Reveal-on-select expansion.
- **What we say:**
  - Headline: `What made you open this today?`
  - Subtitle: `There's no wrong answer.`
  - Options (single-select, each expands a paragraph below when tapped):
    - `Something has been left unsaid` → expands: `Most of the people we love die with words still inside us. You're choosing not to.`
    - `I want to leave something behind` → expands: `Legacy isn't a will. It's a voice. A look. A laugh. The things only you can give.`
    - `I'm thinking about someone I can't reach` → expands: `Distance doesn't have to be silent. Time can carry your words for you.`
    - `I'm not sure, but something brought me here` → expands: `That's enough. We'll find it together.`
- **Why:** Reveal-on-select is our most important UX pattern. The user is rewarded for tapping. The app feels like it understands them.
- **User action:** Select one. Read the paragraph. Continue.

### Screen 8: The hardest part
- **What we show:** Multi-select chips.
- **What we say:**
  - Headline: `What's the hardest part of saying these things now?`
  - Subtitle: `Pick everything that feels true.`
  - Options:
    - `I freeze when I try to say it out loud`
    - `It feels too soon`
    - `It feels too late`
    - `I don't want them to hear it while I'm still here`
    - `They wouldn't be ready for it yet`
    - `I don't know how to start`
- **Why:** Validates resistance. Every option here is a real reason someone doesn't say what they need to say. The app is now reading their mind.
- **User action:** Multi-select. Continue.

### Screen 9: The stat that lands
- **What we show:** A soft full-bleed background, no chart, just one large number floating in the center. Below it, a small attribution.
- **What we say:**
  - Big number: `73%`
  - Headline: `of people say there's something they wish they'd said before it was too late.`
  - Tiny: `Hospice and end-of-life studies, 2014-2022.`
  - Below: `[Name], you're not alone in this.`
- **Why:** Stat shock with a real citation. Universalizes the feeling. The name reappears at the end as a soft hand on the shoulder.
- **User action:** Continue.

### Screen 10: The promise reframed
- **What we show:** Calm image. A horizon line, or a slow-burning candle, or two open hands. Subtle motion.
- **What we say:**
  - Headline: `You don't have to say it today.`
  - Body: `You just have to say it once. We'll hold it until the right moment.`
- **Why:** This is the thesis statement of the app. Drop it here so they remember it forever.
- **User action:** Continue.

---

## ACT 4 — Build the authority (screens 11-13)
*We've earned the right to teach. Now we explain WHY this works.*

### Screen 11: Built by people who care
- **What we show:** A simple credibility diagram. Three soft circles linking down into the app logo.
- **What we say:**
  - Headline: `[Name], you're in careful hands.`
  - Subtitle: `Built with the help of:`
  - Three circles:
    - `Grief counselors`
    - `Cryptographers`
    - `Estate planners`
  - Below: `Your messages are encrypted end-to-end. Only the people you choose will ever read or watch them.`
- **Why:** Authority + privacy in one slide. We name the disciplines we relied on. We promise encryption without being technical.
- **User action:** Continue.

### Screen 12: The science (carousel x3)
- **What we show:** Horizontal swipeable carousel. Each card has a soft illustration top, headline middle, short paragraph bottom. Continue button persists below.
- **What we say:**
  - Card 1 — `Letters to the future change behavior.` `Stanford research shows people who write to their future selves make different decisions today. The act of speaking forward changes the speaker.`
  - Card 2 — `Recorded voice carries more than words.` `Hearing someone's tone, breath, and pause is one of the deepest comforts after loss. Voice survives in ways text cannot.`
  - Card 3 — `Closure isn't about the other person.` `It's about giving the part of you that still has something to say a way to say it. Even decades later. Even after.`
- **Why:** This is our "It's not you, it's biology." Three small reframes that make the app feel inevitable.
- **User action:** Swipe through. Continue.

### Screen 13: Introducing the Critical Timed Message
- **What we show:** A simple diagram: a circle with a soft pulse, a label `Check-in`, an arrow forward, a sealed envelope shape at the end. No skulls. No ominous imagery.
- **What we say:**
  - Headline: `Some messages should only arrive if you can't deliver them yourself.`
  - Body: `We call these Critical Timed Messages. You record them once. We check on you regularly. If you ever stop responding, your message reaches the person you trusted it to.`
  - Soft callout: `It's optional. Most people start with simpler messages first.`
- **Why:** We introduce the dead-man's-switch carefully. Frame it protectively, not morbidly. We acknowledge it's optional so the user doesn't bounce from heaviness.
- **User action:** Continue.

---

## ACT 5 — Show them what they're getting (screens 14-19)
*Feature reveals, phone-in-phone mockups, NoContact style. Each screen reuses the same template.*

### Screen 14: Record
- **What we show:** Tilted iPhone mockup of the record screen. Big red dot. A timer at 00:12. Below: a chip cloud showing recording options (voice only, video, voice + photo).
- **What we say:**
  - Headline: `Speak it the way only you can.`
  - Subtitle: `Voice. Video. Photo. Whatever feels honest.`
- **User action:** Continue.

### Screen 15: Schedule
- **What we show:** Tilted iPhone mockup of a calendar with one date glowing. Below: chips like `Next month`, `On their 18th birthday`, `5 years from today`, `Custom`.
- **What we say:**
  - Headline: `Pick the moment it should arrive.`
  - Subtitle: `Tomorrow, a decade from now, or whenever feels right.`
- **User action:** Continue.

### Screen 16: Secure
- **What we show:** Phone mockup showing a lock animating closed over a thumbnail.
- **What we say:**
  - Headline: `Locked the moment you finish.`
  - Subtitle: `End-to-end encrypted. Even we can't watch it.`
- **User action:** Continue.

### Screen 17: Deliver
- **What we show:** Phone mockup showing an envelope/email with a soft glow, with a delivery confirmation underneath.
- **What we say:**
  - Headline: `It arrives gently, on the day you chose.`
  - Subtitle: `By email, in-app, or both. Whichever way they're easier to reach.`
- **User action:** Continue.

### Screen 18: Critical Timed Message (the heavy one)
- **What we show:** Phone mockup showing the CTM check-in card with three options: `I'm here. Reset`, `Snooze`, `Plan ahead`.
- **What we say:**
  - Headline: `If you ever can't deliver it yourself, we will.`
  - Body: `We send gentle check-ins on your schedule. You confirm with one tap. Miss too many, and your trusted recipient hears from you anyway.`
- **User action:** Continue.

### Screen 19: The recipient
- **What we show:** Phone mockup of a contact card. Profile photo, name, relationship label.
- **What we say:**
  - Headline: `One trusted person. Or many.`
  - Subtitle: `You decide who hears what, and when.`
- **User action:** Continue.

---

## ACT 6 — Make them believe (screens 20-22)
*Social proof, comparison, and a small commitment.*

### Screen 20: What people say
- **What we show:** Two real-looking testimonials with avatars, names, ages. 5-star rating above. `4.8 average from 12k+ users` chip at top.
- **What we say:** Real quotes (we'll write these last):
  - `"I recorded a message for my daughter on her wedding day. She's 4 right now. I cried writing it. I'll cry less knowing she'll have it." - Sarah, 34`
  - `"I lost my dad before we said the things we should have. This app means my kids won't have to feel that." - Michael, 47`
- **User action:** Continue.

### Screen 21: Compare honestly
- **What we show:** Three-column compact comparison.
- **What we say:**
  - Headline: `Why not just...`
  - Columns:
    - `Handwrite a letter?` → `It can be lost, damaged, or never delivered.`
    - `Leave it in a will?` → `Wills are read once. Your message deserves more than that.`
    - `Tell them now?` → `Some things are heavier today than they will be later. We hold them for you.`
- **Why:** Position against the obvious alternatives. We're not selling AI. We're selling time and care.
- **User action:** Continue.

### Screen 22: Set the rules
- **What we show:** Multi-select chip list.
- **What we say:**
  - Headline: `How would you like FromBackInTime to feel?`
  - Subtitle: `Pick anything that matters to you.`
  - Options:
    - `Send me gentle reminders to record`
    - `Never share my data, ever`
    - `Let me name a backup recipient`
    - `Encrypt everything by default`
    - `Allow Critical Timed Messages`
    - `Keep it simple for now`
- **Why:** Small commitments make big ones easier. They are now picking how the app will treat them. They are now a user.
- **User action:** Multi-select. Continue.

---

## ACT 7 — The crescendo (screens 23-25)
*Theatrical. Beautiful. Slow.*

### Screen 23: Personalization loader
- **What we show:** 5 horizontal progress bars stacked, each filling at a different pace, in soft pastel colors. Quote at the bottom.
- **What we say:**
  - Headline: `Preparing your vault, [Name]...`
  - Subtitle: `This will take a moment.`
  - Bars (each labeled):
    - `Securing your space`
    - `Calibrating your delivery schedule`
    - `Setting up your check-ins`
    - `Pairing you with your first message prompt`
    - `Sealing it with end-to-end encryption`
  - Quote at bottom: `"What you leave behind is not what you carve in stone, but what you weave into the lives of others." - Pericles`
- **Why:** The user feels something expensive is happening. It is mostly theater, but the bars match real backend setup steps so it's also honest.
- **User action:** Wait. Tap continue when ready.

### Screen 24: The crescendo (single image, rotating headline)
- **What we show:** One slow-moving image. A horizon at golden hour. Subtle parallax. The headline changes every 4 seconds, fading in and out. Same CTA at the bottom the entire time.
- **What we say (rotating, 2 headlines):**
  - `Some words shouldn't have to wait, [Name].`
  - `But the ones that do, deserve a place to wait safely.`
  - Bottom CTA: `Begin My Vault`
- **Why:** NoContact uses 5 headlines. Ours is 2. Quieter, weightier. The CTA verb upgrades from "Continue" to "Begin My Vault."
- **User action:** Tap CTA.

### Screen 25: The plan reveal
- **What we show:** A card with the user's name, projected first delivery date, and a list of selected preferences as chips.
- **What we say:**
  - Headline: `Your vault is ready, [Name].`
  - Subline: `Your first message can arrive as soon as:`
  - Big date chip: `[their chosen window, e.g. May 19, 2027]`
  - Chip cloud: their selections from Screen 22
  - CTA: `Start sending forward`
- **Why:** The gift moment. The app is real now. They have a date. The date has their name on it.
- **User action:** Tap CTA.

---

## ACT 8 — Earn the purchase (screens 26-28)
*Paywall as carousel + soft offer. No discount panic.*

### Screen 26: Paywall carousel (x4 cards)
- **What we show:** Horizontal swipe. Each card has:
  - A feature illustration
  - A headline
  - A 5-star bar
  - A short testimonial with avatar + name + age
- **Cards:**
  - 1: `Unlimited messages.` + testimonial about volume
  - 2: `Critical Timed Messages.` + testimonial about legacy
  - 3: `Up to 50 recipients.` + testimonial about family
  - 4: `End-to-end encryption + secure backup.` + testimonial about trust
- **CTA persistent at bottom:** `Start free trial`
- **Below CTA, small:** `7 days free, then [price]/year. Cancel anytime.`
- **User action:** Swipe through. Tap CTA.

### Screen 27: The founding member offer (not discount panic)
- **What we show:** A clean soft card. No exploding boxes. No falling confetti.
- **What we say:**
  - Headline: `Founding members keep this price forever.`
  - Body: `We're building this for people who care. Join now, and your price never goes up, no matter how the app grows.`
  - CTA: `Lock in founding rate`
  - Secondary: `Maybe later`
- **Why:** Our category needs trust, not pressure. NoContact's "70% OFF only available during signup" feels manipulative when the topic is death and legacy. The founding member angle is honest and works for our audience.
- **User action:** Tap CTA or skip.

### Screen 28: First step
- **What we show:** A nearly empty home screen with one prompt card.
- **What we say:**
  - Headline: `Welcome, [Name].`
  - Subline: `Want to start with a small one? Try a 60-second voice note to your future self, one year from today.`
  - CTA: `Record my first message`
  - Below: `Or explore the app`
- **Why:** Onboarding ends with action, not a victory screen. We hand them a tiny, doable first message. The hardest message they'll ever record is the second one, not the first, so we make the first easy.
- **User action:** Either path drops them into the app.

---

## Design rules we'll hold across the whole flow

1. **Two CTAs maximum per screen.** Never three. Never zero (except for cinematic screens).
2. **The name appears at least every 4 screens.** It is the most powerful word on the screen.
3. **No mascot.** No cartoon character. Our tone is solemn-warm, not playful.
4. **No clocks ticking down.** No urgency manipulation. The topic is forever. Don't rush it.
5. **No em-dashes anywhere.** Per project CLAUDE.md.
6. **Progress bar starts at Screen 4 (name).** Free trial label appears in the corner from Screen 4 onward, but in muted gray, not red.
7. **Every question screen with options has a "I'm not sure yet" option.** Always.
8. **The CTA verb upgrades as the user gets deeper.** `Begin` → `Continue` → `Continue` → ... → `Begin My Vault` → `Start sending forward` → `Lock in founding rate` → `Record my first message`. Verb escalation is the user feeling more committed without realizing it.

---

## Screen count: 28 logical screens

If the user races through it: ~2.5 minutes.
If the user sits with it: ~6 minutes.

Either way, by Screen 9 (the 73% stat) they are emotionally hooked. By Screen 13 (CTM introduction) they understand why the app exists. By Screen 25 (the plan reveal) they want to use it. The paywall is just the door.

---

## What we still need to decide before designing

- Final brand palette (current Color+App tokens are good starting point but we may want to skew warmer)
- Whether to use real photography on Screens 2 and 3 or stick to abstract
- The exact citations for the 73% stat (real source or composite)
- Testimonial sourcing (real beta users, or written placeholders flagged for replacement)
- Founding member price floor
- Whether Critical Timed Message gets its own deeper sub-onboarding when the user opts in, or if Act 4 Screen 13 + Act 5 Screen 18 are enough

Answer these in the next pass, then we start designing.
